# Setting up with Ansible

Start by getting ansible on your host:

http://docs.ansible.com/ansible/intro_installation.html#installing-the-control-machine

Add some ansible galaxy packages (may require sudo to install on your machine)

    ansible-galaxy install netzwirt.bind
    ansible-galaxy install geerlingguy.apache
    ansible-galaxy install andreaswolf.letsencrypt
    ansible-galaxy install williamyeh.prometheus

Make sure the `fosdem_hosts` file is up to date

Setup the ENV if you want to operate outside of the repo:

    export FOSDEM_REPO="$(git rev-parse --show-toplevel)"
    export ANSIBLE_CONFIG="${FOSDEM_REPO}/ansible/fosdem_ansible.cfg"
    export ANSIBLE_INVENTORY="${FOSDEM_REPO}/ansible/fosdem_hosts"
    ls -l "${ANSIBLE_CONFIG}" "${ANSIBLE_INVENTORY}"

Check the connectivity

    ansible all -m ping 

Deploy

    ansible-playbook site.yml
