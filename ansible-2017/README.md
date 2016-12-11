# Deployment with Ansible

Deploying the entire thing should be possible with just one command:

    ansible-playbook playbooks/site.yml

Usually, you will want to limit your deployment to specific host groups:

    ansible-playbook playbooks/site.yml --limit videobox
    ansible-playbook playbooks/site.yml --limit voctohost
    ansible-playbook playbooks/site.yml --limit streamer-backend

We could consider splitting up our site.yml into multiple files, but this does
the job for the time being.

Please note that the `ansible.cfg` file disables host key checks. This should be
a temporary measure and should be re-enabled.

## Private files

Some files, such as the private keys for our certificates and the firmware for
the BlackMagic H.264 encoders live in a separate private repository. You need
these to deploy some of the roles. Use the `update-private-files.sh` script to
fetch them for you.

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

Use the `update-private-files.sh` script to manage them.

See ![fabled/bmd-tools](https://github.com/fabled/bmd-tools) for more
information.

## Background image

If you have a new background image, it needs to be 1280x720, and to be
converted to a raw one. It's done by using ffmpeg, like this:

`ffmpeg -i background.png -c:v rawvideo -pix_fmt:v yuv420p -c:v rawvideo -pix_fmt yuv420p -frames 1 -f rawvideo background.raw`

This needs to go in `playbooks/roles/voctohost/files/config/`.
