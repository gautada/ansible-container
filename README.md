# ansible-container

Ansible delivers simple IT automation that ends repetitive tasks and frees up DevOps teams for more strategic work.


## Node

- Create ansible user on the node
- Give ansible user the sudo privileges
- Add ansible to `sudo usermod -a -G microk8s ansible` microk8s group
- setup ~/.kube file


sudo snap refresh microk8s --channel=1.25/stable
