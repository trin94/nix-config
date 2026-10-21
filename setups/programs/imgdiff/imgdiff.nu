# What changed between Fedora Atomic images. Usage lives in help.txt: nu answers --help itself,
# so the wrapper in default.nix prints it before nu sees the arguments.

const KINDS = [added removed upgraded downgraded]

def store [] {
  $env.XDG_STATE_HOME? | default ($env.HOME | path join ".local/state") | path join "imgdiff"
}

def deployments [] { rpm-ostree status --json | from json | get deployments }

# --format=json is ignored unless both commits are given explicitly
def pkgdiff [from: string, to: string] {
  rpm-ostree db diff --format=json $from $to | from json | get pkgdiff | each {|p|
    {
      name: $p.0
      kind: ($KINDS | get $p.1)
      old: ($p.2.PreviousPackage?.1? | default "")
      new: ($p.2.NewPackage?.1? | default "")
    }
  }
}

def short [v: string] { $v | str replace -r '^\d+:' '' | str replace -r '\.fc\d+$' '' }

# split where the versions start to differ, backing off to the last separator
def vsplit [old: string, new: string] {
  let o = $old | split chars
  let n = $new | split chars
  let max = [($o | length) ($n | length)] | math min
  mut i = 0
  while $i < $max and ($o | get $i) == ($n | get $i) { $i += 1 }
  let seps = $old | str substring 0..<$i | split chars | enumerate | where item in ['.' '-' ':' '^' '~' '+'] | get index
  let j = if ($seps | is-empty) { 0 } else { ($seps | last) + 1 }
  {common: ($old | str substring 0..<$j), old: ($old | str substring $j..), new: ($new | str substring $j..)}
}

def vfmt [old: string, new: string] {
  let s = vsplit $old $new
  let dim = ansi dark_gray
  let r = ansi reset
  $"($dim)($s.common)($r)(ansi red)($s.old)($r) ($dim)→($r) ($dim)($s.common)($r)(ansi green_bold)($s.new)($r)"
}

def page [lines: list<string>] {
  let text = $lines | str join "\n"
  if (is-terminal --stdout) { $text | ^less -RFX } else { print $text }
}

def status-of [checksum: string, d] {
  let i = $d | enumerate | where item.checksum == $checksum | get 0?.index
  if $i == null { "older" } else if ($d | get $i).booted { "booted" } else if $i == 0 { "pending" } else { "rollback" }
}

def upgrade-lines [u, d, w: int] {
  let st = status-of $u.to.checksum $d
  let col = match $st { pending => "yellow_bold", booted => "green_bold", _ => "dark_gray" }
  let date = $u.to.timestamp * 1_000_000_000 | into datetime | format date "%b %d"
  let counts = $KINDS | each {|k| {k: $k, n: ($u.pkgs | where kind == $k | length)} } | where n > 0
    | each {|c| $"($c.n) ($c.k)" } | str join " · "
  let head = $"(ansi $col)●(ansi reset) (ansi attr_bold)($u.to.version)(ansi reset)  (ansi $col)($st)(ansi reset)  (ansi dark_gray)($date) · from ($u.from.version) · (if $counts == '' { 'no package changes' } else { $counts })(ansi reset)"
  let body = $KINDS | each {|k|
    $u.pkgs | where kind == $k | each {|p|
      let v = match $k {
        added => $"(ansi green)+ (short $p.new)(ansi reset)"
        removed => $"(ansi red)- (short $p.old)(ansi reset)"
        _ => (vfmt (short $p.old) (short $p.new))
      }
      $"  ($p.name | fill -w $w)  ($v)"
    }
  } | flatten
  [$head] | append $body
}

def "main record" [] {
  let dir = store
  mkdir $dir
  for w in (deployments | window 2) {
    let file = $dir | path join $"($w.0.checksum).json"
    if not ($file | path exists) {
      {
        from: ($w.1 | select checksum version timestamp)
        to: ($w.0 | select checksum version timestamp)
        pkgs: (pkgdiff $w.1.checksum $w.0.checksum)
      } | to json | save $file
    }
  }
}

def main [n: int = 3] {
  main record
  let d = deployments
  let ups = glob (store | path join "*.json") | each { open } | sort-by to.timestamp -r | first $n
  let w = $ups | get pkgs | flatten | get name? | default [] | each { str length } | append 0 | math max
  page ($ups | each {|u| upgrade-lines $u $d $w | append "" } | flatten | drop)
}
