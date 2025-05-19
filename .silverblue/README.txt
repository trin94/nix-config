Fedora Silverblue Setup (WIP)
=============================

Note: All commands are to be run on the host system unless specified otherwise.

1. Install Fedora Silverblue
   - Install as usual.

2. Update System
   - rpm-ostree update
   - Reboot afterwards.

3. Install Required Packages
   - rpm-ostree install ansible python3-psutil

4. Set Hostname
   - hostnamectl hostname silverblue
   - Reboot to apply change.

5. Apply Host Configuration
   - git clone https://github.com/trin94/nix-config.git ~/.dotfiles
   - cd ~/.dotfiles/gnome-ansible/
   - ./run-host-playbook.sh

6. Prepare Nix Store Directory
   - sudo mkdir -p /var/home/nix-store/store /var/home/nix-store/var/nix/db
   - sudo chown -R "$USER:$USER" /var/home/nix-store

7. Install Distrobox
   - curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local

8. Bootstrap nix-box Container
   - ./run-1-1-nix-box-assemble.sh
   - ./run-1-2-nix-box-bootstrap-a.sh

9. Bootstrap fedora-box Container
   - ./run-2-1-fedora-box-assemble.sh
   - ./run-2-2-fedora-box-bootstrap-a.sh

10. Update .bashrc for Host
    - ./run-3-modify-host-bashrc.sh
