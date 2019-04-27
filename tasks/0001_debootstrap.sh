# debootstrap a basic Debian system
# TODO check minimal packages
info "Debootstrapping system (first-stage)"
debootstrap --foreign --arch="$CONFIG_ARCH" --exclude="$CONFIG_DEBOOTSTRAP_EXCLUDE" "$CONFIG_DEBOOTSTRAP_SUITE" "$ROOTFS" "$CONFIG_DEBOOTSTRAP_MIRROR"

# TODO support multi-arch
# copy in the ARM static binary to chroot
cp /usr/bin/qemu-arm-static $ROOTFS/usr/bin/

# install the packages
info "Debootstrapping system (second-stage)"
chroot_exec /debootstrap/debootstrap --second-stage

# debug if second-stage failed
# TODO quit if a genuine failure. check debootstrap exit code?
if [ -f $ROOTFS/debootstrap/debootstrap.log ]; then
	warning "Debootstrap may have failed. See debootstrap.log in workspace."
	cp $ROOTFS/debootstrap/debootstrap.log $WORKSPACE/debootstrap.log
fi
