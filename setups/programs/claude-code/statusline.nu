const FALLBACK_BASE = "main"
const BASE_CANDIDATES = [main master]

# Trimmed stdout, or null when git fails (not a repo, unknown ref, ...).
def --wrapped run-git [dir: string, ...args: string] {
  let result = ^git -C $dir --no-optional-locks ...$args | complete
  if $result.exit_code == 0 { $result.stdout | str trim } else { null }
}

# Sum `git diff --numstat` output. Binary files report "-" and count as changed files only.
def numstat [output] {
  let rows = $output | default "" | lines | where ($it | str trim) != "" | each {|line|
    let cols = $line | split row "\t"
    {
      additions: (try { $cols.0 | into int } catch { 0 })
      deletions: (try { $cols.1 | into int } catch { 0 })
    }
  }
  {
    files: ($rows | length)
    additions: ($rows | get additions | prepend 0 | math sum)
    deletions: ($rows | get deletions | prepend 0 | math sum)
  }
}

# Local branch first so a stale remote does not widen the delta, remote as the fallback.
def resolve-ref [dir: string, name: string] {
  [$"refs/heads/($name)" $"refs/remotes/origin/($name)"]
  | where {|ref| (run-git $dir rev-parse --verify --quiet $ref) != null }
  | get 0?
}

# The branch point: whatever the remote calls default, else the first branch that exists.
def detect-base [dir: string] {
  let remote_head = run-git $dir symbolic-ref --quiet --short refs/remotes/origin/HEAD
  let names = if ($remote_head | is-empty) { $BASE_CANDIDATES } else { [($remote_head | str replace -r '^origin/' '')] }
  for name in $names {
    let ref = resolve-ref $dir $name
    if $ref != null { return {label: $name, ref: $ref} }
  }
  {label: $FALLBACK_BASE, ref: $FALLBACK_BASE}
}

def file-count [count: int] {
  $"($count) (if $count == 1 { 'file' } else { 'files' })"
}

def segment [label: string, stats: record] {
  [
    $"(ansi attr_dimmed)($label)(ansi reset)"
    (if $stats.additions > 0 { $"(ansi green)+($stats.additions)(ansi reset)" })
    (if $stats.deletions > 0 { $"(ansi red)-($stats.deletions)(ansi reset)" })
  ] | compact | str join " "
}

def git-line [dir: string] {
  if (run-git $dir rev-parse --git-dir) == null { return null }
  let branch_name = run-git $dir branch --show-current
  let head = if ($branch_name | is-empty) { run-git $dir rev-parse --short HEAD | default "no commits" } else { $branch_name }

  let base = detect-base $dir
  let merge_base = run-git $dir merge-base $base.ref HEAD
  let branch = if ($merge_base | is-empty) { numstat null } else { numstat (run-git $dir diff --numstat $"($merge_base)..HEAD") }
  let dirty = numstat (run-git $dir diff --numstat HEAD)

  let segments = [
    $"(ansi attr_bold)Git(ansi reset) ($head)"
    (if $branch.files > 0 {
      # Binary-only changes carry no line counts, so the file count is all that is left to show.
      let label = $"Since ($base.label):"
      segment (if $branch.additions > 0 or $branch.deletions > 0 { $label } else { $"($label) (file-count $branch.files)" }) $branch
    })
    (if $dirty.files > 0 { segment $"Uncommitted: (file-count $dirty.files)" $dirty })
  ]
  $segments | compact | str join "  "
}

# 999, 156k, 1M, 1.5M. Rounding happens before the unit pick, so 999.6k reads 1M rather than 1000k.
def token-count [tokens: int] {
  let thousands = $tokens / 1000 | math round
  if $thousands >= 1000 {
    $"($tokens / 1_000_000 | math round --precision 1 | into string)M"
  } else if $tokens >= 1000 { $"($thousands)k" } else { $"($tokens)" }
}

# Input tokens of the last API response against the window, the same count as Claude Code's
# used_percentage. current_usage is null before the first response and right after /compact.
def context-line [window] {
  if $window == null or $window.current_usage? == null { return null }
  let percent = $window.used_percentage? | default 0
  let color = if $percent >= 90 { "red" } else if $percent >= 70 { "yellow" } else { "green" }
  let used = token-count ($window.total_input_tokens | into int)
  let size = token-count ($window.context_window_size | into int)
  $"(ansi attr_bold)Context(ansi reset) (ansi $color)($used)(ansi reset)(ansi attr_dimmed)/($size)(ansi reset)"
}

# Skills loaded into this session, in first-use order: Skill tool calls that didn't fail, skills the
# user ran as a slash command, and the skills Claude Code re-attaches after a compaction.
def loaded-skills [transcript: string, skill_dirs: list<string>] {
  if ($transcript | is-empty) or not ($transcript | path exists) { return [] }
  let entries = open --raw $transcript
    | lines
    | where $it =~ '"name":"Skill"|<command-name>/|"invoked_skills"|"is_error":true'
    | each {|line| try { $line | from json } catch { null } }
    | compact

  let failed = $entries
    | where type == "user"
    | each {|entry| $entry.message?.content? | if ($in | describe) =~ '^(list|table)' { $in } else { [] } }
    | flatten
    | where {|part| $part.type? == "tool_result" and $part.is_error? == true }
    | get tool_use_id

  let is_skill = {|name| $skill_dirs | any {|dir| $dir | path join $name "SKILL.md" | path exists } }

  $entries | each {|entry|
    match $entry.type? {
      "assistant" => {
        $entry.message?.content? | default [] | where {|part|
          $part.type? == "tool_use" and $part.name? == "Skill" and $part.id? not-in $failed
        } | each {|part| $part.input?.skill? | default "" | str replace -r '^/' '' }
      }
      "user" => {
        let content = $entry.message?.content?
        let text = if ($content | describe) == "string" { $content } else {
          $content | default [] | where type? == "text" | get text? | str join "\n"
        }
        $text | parse -r '<command-name>/(?<name>[^<\s]+)</command-name>' | get name | where {|name| do $is_skill $name }
      }
      "attachment" => {
        if $entry.attachment?.type? == "invoked_skills" { $entry.attachment.skills | get name? } else { [] }
      }
      _ => []
    }
  } | flatten | compact | where ($it | is-not-empty) | uniq
}

def main [] {
  let session = $in | from json
  let dir = $session.workspace?.current_dir? | default $session.cwd? | default $env.PWD
  let project = $session.workspace?.project_dir? | default $dir
  let skill_dirs = [
    ($env.HOME | path join ".claude/skills")
    ($project | path join ".claude/skills")
    ($dir | path join ".claude/skills")
  ] | uniq

  let skills = loaded-skills ($session.transcript_path? | default "") $skill_dirs
  let lines = [
    (context-line $session.context_window?)
    (git-line $dir)
    (if ($skills | is-not-empty) {
      $"(ansi attr_bold)Skills \(($skills | length)\)(ansi reset) ($skills | str join ', ')"
    })
  ]
  $lines | compact | each {|line| print $line } | ignore
}
