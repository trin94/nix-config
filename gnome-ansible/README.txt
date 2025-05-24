Prerequisites
=============

Install Prerequisites
---------------------

On Silverblue:
  rpm-ostree install ansible python3-psutil
  reboot

On Fedora:
  sudo dnf install ansible git python3-pip

Install plugins:
  ansible-galaxy collection install community.general

Run the playbook:
  ./run-host-playbook.sh

License
-------

Unless otherwise noted in individual roles, this project is licensed under the BSD License.

Original Work by
----------------

Jim Campbell (jwcampbell@gmail.com)
https://github.com/j1mc/ansible-silverblue
