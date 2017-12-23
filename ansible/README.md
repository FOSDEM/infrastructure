# Deployment with Ansible

## Set up the vault password

Secrets are encrypted with [ansible-vault](http://docs.ansible.com/ansible/playbooks_vault.html).
To use ansible-vault transparently, create a file with the shared secret and
export it via an environment variable.

    echo "SECRET" > ~/.fosdem_vault_pass.txt
    export ANSIBLE_VAULT_PASSWORD_FILE=~/.fosdem_vault_pass.txt

## Deploying to hosts

Deploying the entire thing should be possible with just one command:

    ansible-playbook playbooks/site.yml

Usually, you will want to limit your deployment to specific host groups:

    ansible-playbook playbooks/site.yml --limit video-box
    ansible-playbook playbooks/site.yml --limit video-voctop
    ansible-playbook playbooks/site.yml --limit monitor

Note that when deploying to a local test setup, you override the DNS lookups
by specifying an IP addresses in the Ansible hosts file.

For example, if you want to test a voctop deployment to a machine with ip
192.168.178.30, change

    `voctop-h1308.video.fosdem.org`.

into

    `voctop-h1308.video.fosdem.org ansible_host=192.168.178.30`

We could consider splitting up our site.yml into multiple files, but this does
the job for the time being.

Please note that the `ansible.cfg` file disables host key checks. This should be
a temporary measure and should be re-enabled.

## Submodules

This repo includes git submodules to vendor external source. You need to update
them with this helper command.

    ./update-submodules.sh

We should switch this to use a `requirements.yml` file instead.

## Private files

Some files, such as the private keys for our certificates and the firmware for
the BlackMagic H.264 encoders live in a separate private repository. You need
these to deploy some of the roles. Use the `update-private-files.sh` script to
fetch them for you. It will copy the files into the current tree.

Note that all of these should be in your `.gitignore` file, else you risk adding
them by accident.

# More details

Some additional information is available in the `docs/` directory.

* [Video](docs/video.md)

