# Deployment with Ansible

## Videobox

The default root password is "pi", this will be changed later on.

The internal SSD in our video boxes is also managed via Ansible. The disk should
be at /dev/sda. It doens't matter if it has been partitioned or not, our
playbooks will make sure all paritions are erased and the full disk will receive
and ext4 filesystem.

If you ever want to clear the SSDs (for example after the event is over), you
can add `--extra-vars '{"destroy_all_videobox_data": True}'` when running the
playbook.

For the bmd-streamer process to work at all, you will need the BlackMagic
firmware. See ![fabled/bmd-tools](https://github.com/fabled/bmd-tools) for more
information.
