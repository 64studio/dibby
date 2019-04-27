# install custom packages
if [ ! -z "$CONFIG_CUSTOM_PACKAGES" ]; then
        chroot_exec apt-get install "CONFIG_CUSTOM_PACKAGES" --yes
fi

