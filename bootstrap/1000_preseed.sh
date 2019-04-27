# install custom preseed file
if [ ! -z "$CONFIG_PRESEED" ] && [ -f "$WORKSPACE/$CONFIG_PRESEED" ]; then
	chroot_exec apt-get install debconf-utils --yes
	info "running preseed"
	chroot_exec debconf-set-selections /mnt/workspace/$CONFIG_PRESEED
fi
