# Video deployment

## Video boxes (video-box role)

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

For the bmd-streamer process to work at all, you will need the BlackMagic
firmware. You will need to drop those files here:

    playbooks/roles/videobox/files/bmd/bmd-h264prorecorder.bin
    playbooks/roles/videobox/files/bmd/bmd-atemtvstudio.bin

Use the `update-private-files.sh` script to manage them.

See [fabled/bmd-tools](https://github.com/fabled/bmd-tools) for more
information.

### Controlling the video boxes

These are some useful commands which you might need to run on all video boxes
simultaneously.

Start recording:

    ansible video-box -a "systemctl start video-recorder.service"

Stop recording:

    ansible video-box -a "systemctl stop video-recorder.service"

Erase all recordings:

    ansible video-box -a "/bin/sh -c 'rm /mnt/ssd/video-recording/log.*'"

Shutting down:

    ansible video-box -a "shutdown -h now"

### Erasing all data

If you ever want to erase all data (for example after the event is over), you
can add `--extra-vars '{"destroy_all_something_data": True}'` when running the
playbook:

    --extra-vars '{"destroy_all_videobox_data": True}'
    --extra-vars '{"destroy_all_streambackend_data": True}'
    --extra-vars '{"destroy_all_streamdump_data": True}'

Be careful. :)

### Controlling the Lenkeng scalers

As soon as all boxes have been equipped with an IR transmitter hooked up to
their analog sound output, we will be able to control the Lenkeng scalers
remotely.

Each box has a `lenkeng` command which will open a simple interface. It prints
some useful hints on startup. Running this command will allow you to control
the Lenkeng scaler using your keyboard.


## Vocto laptops (video-voctop role)

### Controlling the voctops

Checking if they are all on AC power:

    ansible video-voctop -a "cat /sys/class/power_supply/AC/online"

Checking the battery charge level:

    ansible video-voctop -a "cat /sys/class/power_supply/BAT0/capacity"

### Stream background image

If you have a new background image, it needs to be 1280x720, and to be
converted to a raw one. It's done by using ffmpeg, like this:

`ffmpeg -i background.png -c:v rawvideo -pix_fmt:v yuv420p -c:v rawvideo -pix_fmt yuv420p -frames 1 -f rawvideo background.raw`

This needs to go in `playbooks/roles/video-voctop/files/config/`.


## Streamer backends

### Controlling the streamer backends

Restarting nginx:

    ansible video-streamer-backend -a "systemctl restart nginx.service"

Erasing video dumps:

    ansible video-streamer-backend -a "find /var/www/dump/ \( -name \*.mp4 -o -iname \*.flv \) -exec rm {} \;"
    ansible video-streamer-backend -a "systemctl restart nginx.service"

## Streamer frontends

### Controlling the streamer frontends

Restarting nginx:

    ansible video-streamer-frontend -a "systemctl restart nginx.service"
