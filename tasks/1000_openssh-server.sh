# TODO openssh server
# TODO check if package has been selected first!


# install ssh server
chroot_exec apt-get install openssh-server --yes

# allow root logins
# TODO: accept configuration option
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' $ROOTFS/etc/ssh/sshd_config
