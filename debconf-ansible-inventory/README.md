# FOSDEM DebConf Ansible Inventory

This Ansible inventory is used for running the
[DebConf Ansible roles](https://salsa.debian.org/debconf-video-team/ansible)

It defines the configuration for the following machines:

vogol-sandbox.video.fosdem.org
jitsi-sandbox.video.fosdem.org
jibri-sandbox.video.fosdem.org

This can be run from the
[DebConf Ansible role repo](https://salsa.debian.org/debconf-video-team/ansible)
using the following command:

```
echo "SECRET" >~/.fosdem_vault_pass.txt
ansible-playbook -u root -i ../fosdem/debconf-ansible-inventory/inventory/hosts --vault-password-file ~/.fosdem_vault_pass.txt site.yml
```

To encrypt a variable using ansible vault, use the following command:

    ansible-vault encrypt_string --vault-password-file fosdem.vault 'hunter2' --name 'my_super_variable'

To decrypt a variable that uses ansible vault, use the following command:

    ansible localhost -m debug --vault-password-file fosdem.vault -a var="my_super_variable" -e "@file.yml"

To change the key used to encrypt vault secrets:

    ./rekey.py --old-vault-password-file fosdem.vault --new-vault-password-file fosdem_new.vault
