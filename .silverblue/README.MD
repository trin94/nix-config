# Install home-manager

Source: https://gist.github.com/queeup/1666bc0a5558464817494037d612f094#nix-package-manager-on-fedora-silverblue

```shell
sudo tee /etc/ostree/prepare-root.conf <<'EOL'
[composefs]
enabled = yes
[root]
transient = true
EOL
```

Then apply and reboot

```shell
rpm-ostree initramfs-etc --reboot --track=/etc/ostree/prepare-root.conf
```

Finally install home-manager (**attention**: replace *elias* with the actual username)

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
   sh -s -- install ostree \
      --no-confirm \
      --persistence=/var/lib/nix \
      --extra-conf 'trusted-users = root elias'
```

# Install dotfiles

```shell
nix-shell -p git just home-manager nh devenv direnv

git clone https://github.com/trin94/nix-config.git ~/.dotfiles
cd ~/.dotfiles

export NIX_CONFIG="experimental-features = nix-command flakes"

just silverblue-update
```

# Install Distrobox

1. Install [distrobox](https://distrobox.it/#alternative-methods)
   ```shell
   curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
   ```
   - Shell scripts are located in /var/home/elias/.local/bin
   - Manpages are located in /var/home/elias/.local/share/man/man1
