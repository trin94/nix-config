# Notes

## JetBrains IDE

```
-Dawt.toolkit.name=WLToolkit
-Dsun.awt.wl.Shadow=false
```

https://youtrack.jetbrains.com/issue/IJPL-203429/Wayland-in-WSL-Shadow-Artifacts-in-GUI

## Default applications

```shell
xdg-mime default org.chromium.Chromium.desktop x-scheme-handler/http
xdg-mime default org.chromium.Chromium.desktop x-scheme-handler/https
```

Alternative:

Edit `~/.config/mimeapps.list`

```ini
[Default Applications]
x-scheme-handler/http = org.chromium.Chromium.desktop
x-scheme-handler/https = org.chromium.Chromium.desktop
```
