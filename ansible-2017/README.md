# Deployment with Ansible

## Videobox

Bananian Linux doesn't come with python installed. You will want to install that
first:

  ansible --ask-pass -i hosts videobox -u root -m raw -a "apt-get update && apt-get install -y python-minimal python-pkg-resources"

The default root password is "pi", this will be changed later on.
