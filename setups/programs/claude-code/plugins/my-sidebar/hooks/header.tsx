// The sidebar's top lines: session title, directory, and model with effort and permission mode.

import type { Ui } from "./ui";

/** `~` for the home directory, as OpenCode's sidebar footer writes it. */
export function homeRelative(path: string, home: string | undefined): string {
    if (!home) return path;
    if (path === home) return "~";
    return path.startsWith(`${home}/`) ? `~${path.slice(home.length)}` : path;
}

/**
 * `model · effort · mode`. The effort is left out before the first request and on models that take none,
 * the mode while it is `default`.
 */
export function modelLine(model: string, level: string | null, permissionMode: string | null = null): string {
    return [model, level, permissionMode === "default" ? null : permissionMode].filter(Boolean).join(" · ");
}

export type HeaderData = {
    title: string | null;
    root: string;
    home: string | undefined;
    model: string;
    effort: string | null;
    mode: string | null;
};

export function Header({ Box, Text }: Ui, header: HeaderData) {
    return (
        <Box flexDirection="column">
            {header.title && (
                <Text bold wrap="truncate-end">
                    {header.title}
                </Text>
            )}
            <Text dimColor wrap="truncate-start">
                {homeRelative(header.root, header.home)}
            </Text>
            <Text dimColor wrap="truncate-end">
                {modelLine(header.model, header.effort, header.mode)}
            </Text>
        </Box>
    );
}
