# Deployment with Ansible

## Videobox

Bananian Linux doesn't come with python installed. You will want to install that
first:

  ansible --ask-pass -i hosts videobox -u root -m raw -a "apt-get update && apt-get install -y python-minimal python-pkg-resources"

The default root password is "pi", this will be changed later on.

The internal SSD in our video boxes is also managed via Ansible. The disk should
be at /dev/sda. It doens't matter if it has been partitioned or not, our
playbooks will make sure all paritions are erased and the full disk will receive
and ext4 filesystem.

If you ever want to clear the SSDs (for example after the event is over), you
can add `--extra-vars '{"destroy_all_videobox_data": True}'` when running the
playbook.
