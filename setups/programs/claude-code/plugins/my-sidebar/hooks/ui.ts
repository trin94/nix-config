// The elements the sidebar's sections draw with, as `$.ui.resolve(e)` hands them out on every surface.

import type { BoxProps, ButtonProps, ElementConstructor, TextProps } from "claude-code";

export type Ui = {
    Box: ElementConstructor<BoxProps>;
    Text: ElementConstructor<TextProps>;
    Button: ElementConstructor<ButtonProps>;
};
