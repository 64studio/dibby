# run postinst
if [ ! -z "$CONFIG_POSTINST" ] && [ -f "$WORKSPACE/$CONFIG_POSTINST" ]; then
	info "running postinst $CONFIG_POSTINST"
	chroot_exec "/mnt/workspace/$CONFIG_POSTINST"
fi
