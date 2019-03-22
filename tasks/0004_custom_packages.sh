# TODO install the custom packages



# loop over each component in the project
#for COMPONENT in $(pdk listcomps $PDK_COMPONENT); do
#  info "installing component $COMPONENT"
#
#  # get rid of the directory seperator
#  COMPONENT=$(echo "$COMPONENT" | tr '/' '-')
#
#  chroot_exec apt-get install $COMPONENT^ --yes
#done


# install preseed
if [ ! -z "$CONFIG_PRESEED" ] && [ -f "$WORKSPACE/$CONFIG_PRESEED" ]; then
	chroot_exec apt-get install debconf-utils --yes
	info "running preseed"
	chroot_exec debconf-set-selections /mnt/workspace/$CONFIG_PRESEED
fi


# standard packages
#chroot_exec apt-get install --yes alsa-utils console-common cpufrequtils debconf-utils fake-hwclock gnupg locales ntp psmisc rfkill rt-tests sudo whois
#chroot_exec apt-get install --yes xserver-xorg xserver-xorg-input-libinput xserver-xorg-video-fbdev x11-xserver-utils
#chroot_exec apt-get install --yes lightdm lightdm-autologin-greeter
#chroot_exec apt-get install --yes openbox
#chroot_exec apt-get install --yes lxterminal