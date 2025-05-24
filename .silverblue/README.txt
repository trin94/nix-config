Fedora Silverblue Setup (WIP)
=============================

Note: All commands are to be run on the host system unless specified otherwise.

1. Install Fedora Silverblue
   - Install as usual.

2. Update System
   - rpm-ostree update
   - reboot

3. Install Required Packages
   - rpm-ostree install ansible python3-psutil

4. Set Hostname
   - hostnamectl hostname silverblue
   - reboot

5. Apply Host Configuration
   - git clone https://github.com/trin94/nix-config.git ~/.dotfiles
   - cd ~/.dotfiles/gnome-ansible/
   - ./run-host-playbook.sh

6. Bootstrap toolbox
   - cd ~/.dotfiles/.silverblue
   - ./bootstrap-toolbox.sh

7. Update .bashrc for Host
   - cd ~/.dotfiles/.silverblue
   - ./update-host-bashrc.sh
