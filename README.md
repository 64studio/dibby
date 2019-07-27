```
   _     _    _  
 _| |( )| |_ | |_  _ _ 
/ . || || . \| . \| | |
\___||_||___/|___/ \_ |
                   /_.'       
```
## What is dibby?

`dibby` is the **d**ebian **i**mage **b**uilder **by** chris, a collection of shell scripts which can be used for creating minimal custom [Debian](https://www.debian.org/) images containing only the packages that you specify, any dependencies those packages need, and unique configurations for deployment.

By default, dibby is configured to build [ARM](https://www.debian.org/ports/arm/) images for devices such as the Raspberry Pi 3 on an amd64 host using [QEMU](https://www.qemu.org/), as that is the way we use it at [64 Studio](https://64studio.com/).

## How to install dibby

You can run the scripts from a checked-out copy of the [Git repository for dibby](https://github.com/64studio/dibby) or install a Debian amd64 package from the [64 Studio APT server](https://apt.64studio.net/). If you are interested in developing dibby or adapting it for your needs, we recommend forking the Git version.

The following instructions install the latest release of dibby from our APT server, and have been tested on Debian Stretch and Sid amd64:
```
sudo apt install apt-transport-https
echo 'deb https://apt.64studio.net stable main' | sudo tee /etc/apt/sources.list.d/64studio.list
wget -qO - https://apt.64studio.net/archive-keyring.asc | sudo apt-key add -
sudo apt update
sudo apt install dibby
```

To create your own Debian package from the Git source code and install that package locally with dependency resolution, you can use these commands:
```
cd dibby
dpkg-buildpackage --no-sign
sudo gdebi -i ../dibby_*_all.deb
```

If you are running dibby direct from this Git repository, you will need to install its dependencies manually:
```
sudo apt install debootstrap dosfstools kpartx libpwquality-tools qemu-user-static whois
```

## How to use dibby

The `dibby` script has three command line arguments, corresponding in turn to the script variables `$WORKSPACE`, `$CONFIG` and `$IMAGE`. 

1. The _workspace_ is a directory on your local system which will contain your dibby project. This directory needs to be created before you run `dibby` for the first time. The workspace directory is kept separate from dibby itself, so your workspace can be public or private, depending on your project requirements. A dibby workspace can be developed collaboratively using your own git repository, if you wish.

2. The _config_ file is where you set the options for the target systems which will boot your dibby project image. This includes the CPU architecture for your dibby project, as well as the initial hostname and root password of the target devices. This file also enables you to specify a Debian preseed file and post-installation script, a custom package selection, custom tasks and a custom package mirror, using the following format:
```
CONFIG_ARCH="armhf"
CONFIG_HOSTNAME="myhostname"
CONFIG_ROOT_PASSWORD="myrootpassword"
CONFIG_PRESEED="preseed.conf"
CONFIG_POSTINST="postinst.sh"
CONFIG_CUSTOM_PACKAGES="jackd2"
CONFIG_CUSTOM_TASKS="raspberry-pi-3"
CONFIG_CUSTOM_MIRROR="https://apt.64studio.net/"
```

You can also pass options to `debootstrap` from the dibby project config file, including the mirror to obtain the Debian packages from, the base Debian suite for your project, and any Debian packages to exclude from the build:
```
CONFIG_DEBOOTSTRAP_MIRROR="http://deb.debian.org/debian"
CONFIG_DEBOOTSTRAP_SUITE="buster"
CONFIG_DEBOOTSTRAP_EXCLUDE="tasksel, tasksel-data"
```

Please see the file [default-config](https://github.com/64studio/dibby/blob/master/default-config) for the current default options. You can set defaults for all your dibby projects in your local copy of this file, if that suits your needs.

3. The _image_ is the filename of the custom Debian image you will create with dibby.

### Your first dibby build

From the directory where the `dibby` script is installed (installed to `/usr/share/dibby/` when using the Debian package of dibby), we can create `mydebian.img` in the directory `~/myproject` using the configuration file `~/myproject/myconfig` as follows:
```
mkdir ~/myproject
nano ~/myproject/myconfig
(set any custom configuration options)
sudo ./dibby ~/myproject myconfig mydebian.img
```

Please be aware that the step _Unpacking the base system..._ can take a long time, depending on the speed of your build host.

### Creating unique images

By using different options for these command line arguments, you can create a variety of custom Debian images independently of the current state of your dibby project.

For example, you might wish to create a series of up-to-date Debian images which only vary in one or two aspects of configuration, such as a specific network setup or a unique root password assigned to a user. You can do this by altering the _config_ argument for each build. Then, the unique images you build could be booted directly on the target devices without requiring any post-installation intervention.

### The tasks directory

The purpose of tasks in dibby is to set up modular components containing Debian packages and configurations for them that work well together, without having to specify each package and configuration option every time you create a new dibby project. These tasks can be generic, for any system, or they can target specific hardware such as the Raspberry Pi 3.

Inside the _tasks_ directory (installed to `/usr/share/dibby/tasks/` when using the Debian package of dibby) you will find scripts which are run from the main `dibby` script. You can use these ready-made task scripts as they are, modify them, or create as many new tasks as you need.

For example, during the development phase of your dibby project, you might wish to include an OpenSSH server in your build with remote root access by password to the target device. A script called `openssh-server.sh` is included in the _tasks_ directory for this purpose. (This approach is a more modular alternative to using `d-i preseed/late_command` in the preseed file, one which enables you to put your hacks for a particular package in the same task script which selects that package).

If your project is ready to deploy images with `openssh-server` but you no longer require remote root access, you can modify this particular task script to comment out the parts you no longer need. This is the line of the task script which enables remote root login over SSH using a password:

`sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' $ROOTFS/etc/ssh/sshd_config`

Please note the use of the dibby variable `$ROOTFS` to ensure that the task script is modifying the filesystem of the target image, and not the build host.

When working on a dibby project collaboratively, any modification to a task script can be tracked in a git repository for your own fork of dibby, so you can approve this specific change to the build or revert it later if necessary. We welcome contributions of task scripts which would be helpful for other dibby users.

## Support

dibby is at an early stage of development, but has already been used to create real-world systems here at 64 Studio. If you have any problems using dibby or have suggestions for improvements, please [file an issue](https://github.com/64studio/dibby/issues) in the GitHub project for dibby. We love pull requests!
