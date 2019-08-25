# Cluster Deployment Toolkit

This project aims to help ease deployment of compute clusters in which nodes are mostly identical.  The tool creates disk partition layouts, dumps given images to the disks, and then chroots into the new root to perform node-specific tasks, currently consists of the following:

- Set hostname
- Regenerate `/etc/machine-id`
- Set timezone
- Create `/etc/fstab`
- Set root password (with provided `shadow`)
- Add admin and normal users (with provided `username:shadow`)
- Update GRUB config file

## Current defects

The following two problems currently prevent a directly bootable target, but rather easy to fix:

- SELinux contexts may be incorrect for `/etc` if script ran from system that's different from the target image.
  - Fix by appending `enforcing=0` to kernel commandline at boot first, then do `restorecon`
- Some modules may be missing with default kernel
  - Boot with rescue kernel first, then use `dracut` to rebuild initramfs

## Using the tool

Configurable behaviors can be tuned via editting `settings.sh`.  The whole process is designed to be fully non-interactive for use in unattended environments; make sure to read the configuration file thoroughly before getting started.  To start the tool:

```
$ sudo ./main.sh
```

## Installation CD

A toolkit for generating bootable CDs (based on `archiso`) can be found [here](https://github.com/KireinaHoro/cluster-deploy-cd).

## Custom environment requirements

Note that the tool assumes a sane environment to run inside, including (but not limited to):

- Bash (tested with 4.2.46(2)-release from CentOS)
- A set of commands available:
   - Basic utils: `cp`, `mkdir`, `mount`, `dd`, `gzip`, `chroot`, `sed`
   - GPT manipulation: `sgdisk`
   - LVM: `{pv,vg,lv}{create,display}`
   - Filesystems: `mkfs.xfs` (for root), `zpool` (for data storage), `xfsrestore` (for unpacking root images)
   - Device discovery: `udevadm`
- Udev working properly (used to resolve complex drive names for better device identification)

The tool assumes that the target image to be a systemd-based distribution (`machine-id`) and consist of the following 3 parts:

- `esp.img.gz`: ESP image, GZip compressed
- `boot.xfsdump.gz`: boot xfsdump L0 backup, GZip compressed
- `root.xfsdump.gz`: root xfsdump L0 backup, GZip compressed

Refer to `settings.sh` for how to place the images.  A CentOS 7.6 image is tested to be working.


## License

The tool is released under Apache License 2.0.  Refer to the [LICENSE file](LICENSE) for details.

