```            
   _     _    _  
 _| |( )| |_ | |_  _ _ 
/ . || || . \| . \| | |
\___||_||___/|___/`_. |
                   /_.'
         
```
## What is dibby?

`dibby` is the **d**ebian **i**mage **b**uilder **by** chris, a collection of shell scripts which can be used for creating minimal custom [Debian](https://www.debian.org/) images containing only the packages that you specify and any dependencies those packages need.

By default, dibby is configured to build [ARM](https://www.debian.org/ports/arm/) images for devices such as the Raspberry Pi 3 on an amd64 host using [QEMU](https://www.qemu.org/), as that is the way we use it at [64 Studio](https://64studio.com/).

## How to install dibby

You can run the scripts from a checked-out copy of the [git repository for dibby](https://github.com/64studio/dibby) or install a Debian package from the [64 Studio apt server](https://apt.64studio.net/).

The following instructions install the latest release and has been tested on Debian Stretch and Sid.

```
$ sudo apt install apt-transport-https
$ echo 'deb https://apt.64studio.net stretch main' | sudo tee /etc/apt/sources.list.d/64studio.list
$ wget -qO - https://apt.64studio.net/archive-keyring.asc | sudo apt-key add -
$ sudo apt update
$ sudo apt install dibby
```

Install from source:
```
$ cd dibby
$ dpkg-buildpackage --no-sign
$ sudo dpkg -i ../dibby_*_all.deb
```

## How to use dibby

The `dibby` script has three command line arguments, corresponding in turn to the script variables `$WORKSPACE`, `$CONFIG` and `$IMAGE`. 

1. The _workspace_ is a directory on your local system which will contain your dibby project. This directory needs to be created before you run `dibby` for the first time.

2. The _config_ file is where you set the options for the target system which will run your dibby project. It has support for Debian preseed and and postinst files, using the following format:

```
CONFIG_ARCH="armhf"
CONFIG_HOSTNAME="myhostname"
CONFIG_ROOT_PASSWORD="myrootpassword"
CONFIG_PRESEED="preseed.conf"
CONFIG_POSTINST="postinst.sh"
```

3. The _image_ is the filename of the custom Debian image you will create with dibby.

For example, from the directory where the `dibby` script is installed:

```
mkdir ~/myproject
nano ~/myproject/myconfig
(set your configuration options)
./dibby ~/myproject myconfig mydebian.img
```

By using these command line arguments, you can create a variety of custom Debian images independently of the current state of your dibby project. For example, you might wish to create a series of up-to-date Debian images which only vary in one or two aspects of configuration, such as a specific network setup or a unique root password assigned to a user. In this example, the unique images you build could be booted directly on the target devices without requiring any post-installation intervention.

### The tasks directory

Inside the _tasks_ directory (installed to `/usr/share/dibby/tasks/` when using the Debian package of dibby) you will find a number of scripts which are run from the main `dibby` script, in numerical order. These task scripts are used to shape your custom Debian image, and you can create as many of them as you need.

For example, during the development phase of your project, you might wish to include an OpenSSH server in your build for remote root access to the target device. A script called `1000_openssh-server.sh` is included in the _tasks_ directory for this purpose. If your project is ready to deploy without requiring remote access any longer, or you wish to disable remote root access only, you can modify this particular task script to comment out the parts you no longer need. This modification would normally be tracked in your project git repository, so you can approve this specific change to the build or revert it later if necessary.

## Support

dibby is at an early stage of development, but has already been used to create real-world systems here at 64 Studio. If you have any problems using dibby or have suggestions for improvements, please [file an issue](https://github.com/64studio/dibby/issues) in the GitHub project for dibby. We love pull requests!
