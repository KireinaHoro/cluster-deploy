# Cluster Deployment Toolkit

This project aims to help ease deployment of compute clusters in which nodes are mostly identical.  The tool creates disk partition layouts, dumps given images to the disks, and then chroots into the new root to perform node-specific tasks, currently consists of the following:

- Set hostname
- Regenerate `/etc/machine-id`
- Set timezone
- Create `/etc/fstab`
- Set root password (with provided `shadow`)
- Add admin and normal users (with provided `username:shadow`)

## Using the tool

Configurable behaviors can be tuned via editting `settings.sh`.  The whole process is designed to be fully non-interactive for use in unattended environments; make sure to read the configuration file thoroughly before getting started.  To start the tool:

```
$ sudo ./main.sh
```

## Requirements

Note that the tool assumes a sane environment to run inside, including (but not limited to):

- Bash (tested with 4.2.46(2)-release from CentOS)
- A set of commands available:
   - Basic utils: `cp`, `mkdir`, `mount`, `dd`, `gzip`, `chroot`, `sed`
   - GPT manipulation: `sgdisk`
   - LVM: `{pv,vg,lv}{create,display}`
   - Filesystems: `mkfs.xfs` (for root), `zpool` (for data storage), `xfsrestore` (for unpacking root images)
   - Device discovery: `udevadm`
- Udev working properly (used to resolve complex drive names for better device identification)

Plans for releasing a suitable bootable environment exist, but no ETA has been scheduled yet.  The script is tested to work on a normal CentOS 7.6 system with the required packages installed.

The tool assumes that the target image to be a systemd-based distribution (`machine-id`) and consist of the following 3 parts:

- `esp.img.gz`: ESP image, GZip compressed
- `boot.xfsdump.gz`: boot xfsdump L0 backup, GZip compressed
- `root.xfsdump.gz`: root xfsdump L0 backup, GZip compressed

Refer to `settings.sh` for how to place the images.  A CentOS 7.6 image is tested to be working.


## License

The tool is released under Apache License 2.0.  Refer to the [LICENSE file](LICENSE) for details.

