# Deployment with Ansible

Deploying the entire thing should be possible with just one command:

    ansible-playbook playbooks/site.yml

Usually, you will want to limit your deployment to specific host groups:

    ansible-playbook playbooks/site.yml --limit videobox
    ansible-playbook playbooks/site.yml --limit vocothost
    ansible-playbook playbooks/site.yml --limit streamer-backend

We could consider splitting up our site.yml into multiple files, but this does
the job for the time being.

Please note that the `ansible.cfg` file disables host key checks. This should be
a temporary measure and should be re-enabled.

## Video boxes

Our video boxes run Bananian Linux for the time being. The idea is to switch to
pure Debian in the future.

To install a video box, simply insert an SD card with a vanilla Bananian Linux
install on it and deploy the videobox role. The first time you will probably
want to run it with `--ask-pass` (or `-k`). Subsequent runs can use your SSH
key.

The default root password is "pi", this will be changed later on.

The internal SSD in our video boxes is also managed via Ansible. The disk should
be at /dev/sda. It doens't matter if it has been partitioned or not, our
playbooks will make sure all paritions are erased and the full disk will receive
and ext4 filesystem.

If you ever want to clear the SSDs (for example after the event is over), you
can add `--extra-vars '{"destroy_all_videobox_data": True}'` when running the
playbook.

For the bmd-streamer process to work at all, you will need the BlackMagic
firmware. You will need to drop those files here:

    playbooks/roles/videobox/files/bmd/bmd-h264prorecorder.bin
    playbooks/roles/videobox/files/bmd/bmd-atemtvstudio.bin

See ![fabled/bmd-tools](https://github.com/fabled/bmd-tools) for more
information.
