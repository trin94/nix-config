# Prerequisites

- Install Prerequisites
  - Silverblue:
    ```shell
    rpm-ostree install ansible python3-psutil
    reboot
    ```
  - Fedora:
    ```shell
    sudo dnf install ansible git python3-pip
    ```
- Install plugins
  ```shell
  ansible-galaxy collection install community.general
  ```
- Run the playbook
  ```shell
  ./run-host-playbook.sh
  ```

## License

Unless otherwise indicated in the individual role, this project is under the BSD License.

## Original Work by

- [Jim Campbell (jwcampbell@gmail.com)](https://github.com/j1mc/ansible-silverblue)
