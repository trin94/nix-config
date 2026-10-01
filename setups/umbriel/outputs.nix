{
  # HDR selects its own 10-bit format; do not force 10-bit SDR here.
  # Output names must match exactly; wildcards are unsupported.
  output = {
    "DP-3" = {
      mode = "3840x2160@240.000";
      scale = 1.25;
      transform = "normal";
      position = [
        0
        0
      ];

      hdr = "on";
    };
  };
}
