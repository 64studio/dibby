# hostname
echo "$CONFIG_HOSTNAME" > $ROOTFS/etc/hostname

# hosts file
echo "127.0.0.1	localhost.localdomain	localhost
127.0.1.1	${CONFIG_HOSTNAME}.localdomain	${CONFIG_HOSTNAME}" > $ROOTFS/etc/hosts

# set root password
ENCRYPTED_PASSWORD=$(mkpasswd -m sha-512 "$CONFIG_ROOT_PASSWORD")
chroot_exec usermod -p "${ENCRYPTED_PASSWORD}" root

# mount root filesystem
# TODO do this depending on board-type
# TODO boot is readonly
echo "/dev/mmcblk0p1	/boot	vfat	defaults,ro	0	0
/dev/mmcblk0p2	/	ext4	defaults,noatime	0	1" > $ROOTFS/etc/fstab

# setup wired network (dhcp)
echo "
# The loopback network interface
auto lo
iface lo inet loopback
# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp" >> $ROOTFS/etc/network/interfaces

# mount workspace inside debootstrap
# TODO: confirm cleaned up
mkdir -p "$ROOTFS/mnt/workspace"
mount --bind "$WORKSPACE" "$ROOTFS/mnt/workspace"

# setup apt repository
# TODO configure from upstream location
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ testing main contrib non-free
deb-src http://deb.debian.org/debian/ testing main contrib non-free

deb http://deb.debian.org/debian/ testing-updates main contrib non-free
deb-src http://deb.debian.org/debian/ testing-updates main contrib non-free

deb http://deb.debian.org/debian-security testing/updates main
deb-src http://deb.debian.org/debian-security testing/updates main
EOF

# do not install recommended packages
# TODO remove after?
echo "APT::Install-Recommends \"0\";
APT::Install-Suggests \"0\";" > "$ROOTFS/etc/apt/apt.conf.d/99no-install-recommends-suggests"

# update repo
chroot_exec apt-get update