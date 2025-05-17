# Prerequisites

- Install Prerequisites
  - Silverblue:
    - Layer ansible and python3-psutil
      ```shell
      rpm-ostree install ansible python3-psutil
      ```
    - Reboot
  - Fedora:
    ```shell
    sudo dnf install ansible git python3-pip
    ```
- Install plugins
  ```shell
  ansible-galaxy collection install community.general
  ```
- Run the playbooks
  ```shell
  ansible-playbook --ask-become-pass --verbose --inventory-file hosts.ini --limit "$HOSTNAME" playbook_base.yml
  ```

## License

Unless otherwise indicated in the individual role, this project is under the BSD License.

## Original Work by

- [Jim Campbell (jwcampbell@gmail.com)](https://github.com/j1mc/ansible-silverblue)
