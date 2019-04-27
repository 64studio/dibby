# TODO standard system setup

# install standard packages
# TODO: fix gnupg & apt-key
# TODO: check if package available before running command
#chroot_exec apt-get install gnupg --yes

# install archive keyring
# TODO: fix this
#chroot_exec apt-key add /media/apt/archive-keyring.asc

# TODO: remove after testing
#chroot_exec apt-key list

# generate locales
# TODO this requires the locale package is installed
echo "en_GB.UTF-8 UTF-8" > $ROOTFS/etc/locale.gen
chroot_exec locale-gen
