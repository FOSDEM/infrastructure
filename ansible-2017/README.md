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
firmware. You will need to drop those files here:

  playbooks/roles/videobox/files/bmd/bmd-h264prorecorder.bin
  playbooks/roles/videobox/files/bmd/bmd-atemtvstudio.bin

See ![fabled/bmd-tools](https://github.com/fabled/bmd-tools) for more
information.

### Multicast

Our addressing plan is as follows:

| MAC | hostname | IP | Multicast |
|-----|----------|----|-----------|
| ? | aw1120-slides | ? | 227.0.0.1 |
| ? | aw1120-cam | ? | 227.0.0.2 |
| ? | aw1121-slides | ? | 227.0.1.1 |
| ? | aw1121-cam | ? | 227.0.1.2 |
| ? | aw1124-slides | ? | 227.0.2.1 |
| ? | aw1124-cam | ? | 227.0.2.2 |
| ? | aw1125-slides | ? | 227.0.3.1 |
| ? | aw1125-cam | ? | 227.0.3.2 |
| ? | aw1126-slides | ? | 227.0.4.1 |
| ? | aw1126-cam | ? | 227.0.4.2 |
| ? | h1301-slides | ? | 227.1.0.1 |
| ? | h1301-cam | ? | 227.1.0.2 |
| ? | h1302-slides | ? | 227.1.1.1 |
| ? | h1302-cam | ? | 227.1.1.2 |
| ? | h1308-slides | ? | 227.1.2.1 |
| ? | h1308-cam | ? | 227.1.2.2 |
| ? | h1309-slides | ? | 227.1.3.1 |
| ? | h1309-cam | ? | 227.1.3.2 |
| ? | h2213-slides | ? | 227.1.4.1 |
| ? | h2213-cam | ? | 227.1.4.2 |
| ? | h2214-slides | ? | 227.1.5.1 |
| ? | h2214-cam | ? | 227.1.5.2 |
| ? | h2215-slides | ? | 227.1.6.1 |
| ? | h2215-cam | ? | 227.1.6.2 |
| ? | janson-slides | ? | 227.2.0.1 |
| ? | janson-cam | ? | 227.2.0.2 |
| ? | k1105-slides | ? | 227.3.0.1 |
| ? | k1105-cam | ? | 227.3.0.2 |
| ? | k3201-slides | ? | 227.3.1.1 |
| ? | k3201-cam | ? | 227.3.1.2 |
| ? | k3401-slides | ? | 227.3.2.1 |
| ? | k3401-cam | ? | 227.3.2.2 |
| ? | k4201-slides | ? | 227.3.3.1 |
| ? | k4201-cam | ? | 227.3.3.2 |
| ? | k4401-slides | ? | 227.3.4.1 |
| ? | k4401-cam | ? | 227.3.4.2 |
| ? | k4601-slides | ? | 227.3.5.1 |
| ? | k4601-cam | ? | 227.3.5.2 |
| ? | ua2114-slides | ? | 227.4.0.1 |
| ? | ua2114-cam | ? | 227.4.0.2 |
| ? | ua2220-slides | ? | 227.4.1.1 |
| ? | ua2220-cam | ? | 227.4.1.2 |
| ? | ub2252a-slides | ? | 227.4.2.1 |
| ? | ub2252a-cam | ? | 227.4.2.2 |
| ? | ud2120-slides | ? | 227.4.3.1 |
| ? | ud2120-cam | ? | 227.4.3.2 |
| ? | ud2218a-slides | ? | 227.4.4.1 |
| ? | ud2218a-cam | ? | 227.4.4.2 |
