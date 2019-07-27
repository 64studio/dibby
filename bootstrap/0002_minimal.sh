# hostname
info "Setting hostname to $CONFIG_HOSTNAME"
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

# setup main apt and dibby repositories
info "Setting up APT for $CONFIG_DEBOOTSTRAP_MIRROR"
cat << EOF > $ROOTFS/etc/apt/sources.list
deb $CONFIG_DEBOOTSTRAP_MIRROR $CONFIG_DEBOOTSTRAP_SUITE main contrib non-free
deb-src $CONFIG_DEBOOTSTRAP_MIRROR $CONFIG_DEBOOTSTRAP_SUITE main contrib non-free

deb https://apt.64studio.net/dibby $CONFIG_DEBOOTSTRAP_SUITE main
deb-src https://apt.64studio.net/dibby $CONFIG_DEBOOTSTRAP_SUITE main
EOF

cat << EOF > $ROOTFS/etc/apt/preferences

     Package: *
     Pin: origin "apt.64studio.net"
     Pin-Priority: 1001
EOF

if [ $CONFIG_DEBOOTSTRAP_SUITE = "buster" ] ||
   [ $CONFIG_DEBOOTSTRAP_SUITE = "stretch" ] ||
   [ $CONFIG_DEBOOTSTRAP_SUITE = "testing" ] ||
   [ $CONFIG_DEBOOTSTRAP_SUITE = "stable" ]
then
   # setup additional Debian apt repositories
   info "Adding update and debian-security repositories"
   cat << EOF >> $ROOTFS/etc/apt/sources.list

deb $CONFIG_DEBOOTSTRAP_MIRROR $CONFIG_DEBOOTSTRAP_SUITE-updates main contrib non-free
deb-src $CONFIG_DEBOOTSTRAP_MIRROR $CONFIG_DEBOOTSTRAP_SUITE-updates main contrib non-free

deb http://deb.debian.org/debian-security $CONFIG_DEBOOTSTRAP_SUITE/updates main
deb-src http://deb.debian.org/debian-security $CONFIG_DEBOOTSTRAP_SUITE/updates main
EOF
fi

# setup custom apt repository and pin it to high priority
if [ -n "$CONFIG_CUSTOM_MIRROR" ]; then

info "Setting up APT for $CONFIG_CUSTOM_MIRROR"
cat << EOF >> $ROOTFS/etc/apt/sources.list

deb $CONFIG_CUSTOM_MIRROR $CONFIG_DEBOOTSTRAP_SUITE main
deb-src $CONFIG_CUSTOM_MIRROR $CONFIG_DEBOOTSTRAP_SUITE main
EOF

CONFIG_CUSTOM_ORIGIN=$(echo $CONFIG_CUSTOM_MIRROR | sed 's;https://;;' | sed 's;http://;;' | sed 's;ftp://;;')

cat << EOF >> $ROOTFS/etc/apt/preferences

     Package: *
     Pin: origin "$CONFIG_CUSTOM_ORIGIN"
     Pin-Priority: 1002
EOF

fi

# do not install recommended packages
# TODO remove after?
echo "APT::Install-Recommends \"0\";
APT::Install-Suggests \"0\";" > "$ROOTFS/etc/apt/apt.conf.d/99no-install-recommends-suggests"

# update repo
chroot_exec apt-get update
