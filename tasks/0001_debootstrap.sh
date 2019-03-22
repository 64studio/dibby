# debootstrap a basic Debian system
# TODO check installed packages, dont think tasksel is needed
info "Debootstrapping system (first-stage)"
MIRROR="http://deb.debian.org/debian"
EXCLUDE="tasksel, tasksel-data"
debootstrap --foreign --arch="$CONFIG_ARCH" --exclude="$EXCLUDE" buster "$ROOTFS" "$MIRROR"

# TODO support multi-arch
# copy in the ARM static binary (so we can chroot)
cp /usr/bin/qemu-arm-static $ROOTFS/usr/bin/

# actually install the packages
info "Debootstrapping system (second-stage)"
chroot_exec /debootstrap/debootstrap --second-stage

# debug if second-stage failed
# TODO check file exists & quit if so...
cp $ROOTFS/debootstrap/debootstrap.log $WORKSPACE/debootstrap.log