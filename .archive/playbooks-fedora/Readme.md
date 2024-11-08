# Post Install Scripts

```shell
mkdir ~/apps
cd ~/apps
```

## Fedora

```shell
sudo dnf install ansible git python3-pip
ansible-galaxy collection install community.general
```

**Playbooks**:

```shell
ansible-playbook --ask-become-pass 00-distribution.yml
ansible-playbook --ask-become-pass 30-apps-graphical.yml
ansible-playbook --ask-become-pass 50-utilities.yml

ansible-playbook --ask-become-pass apps-docker.yml
ansible-playbook --ask-become-pass apps-java.yml
ansible-playbook --ask-become-pass apps-node.yml
```

Gotta supply the root password.
