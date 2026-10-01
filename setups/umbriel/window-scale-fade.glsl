// Custom effects replace built-in fade/scale; samples use premultiplied RGBA.
vec4 animation(vec2 uv) {
    float progress = umbriel_clamped_progress;
    bool closing = umbriel_direction < 0.0;
    float scale = closing ? 1.0 - progress / 5.0 : 0.5 + progress / 2.0;
    float opacity = closing ? 1.0 - progress : progress;

    vec2 source = (uv - vec2(0.5)) / scale + vec2(0.5);
    return umbriel_sample(source) * opacity;
}
