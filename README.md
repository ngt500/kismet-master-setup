## Kimset Setup Helper
This tool creates a local working directory for all things related to Kismet. Called "kismet-master-setup"

 - Easily organize your Kismet logs into csv, json, pcap, stats and more using Kismet's log tools
 - Backup your current Kismet installation (bin,conf,kismet-plugins,.kismet)
 - Install and build Kismet from git
 - Install plugins and copy your custom kismet_site config
 - Backup and remove your current Kismet installation in preparation to upgrade or re-install Kismet
 

Tested on Ubuntu 18.04 and 20.04

Assumes this git is cloned to ~/

### Disclaimers
- Use at your own risk
- I am not an expert but have managed to hack my way through a cool Kismet workflow process and have learned a lot in the process.


### Install
Make sure you are in your home folder ~/

	git clone https://github.com/ngt500/kismet-master-setup.git
	cd kismet-master-setup
	chmod +x kms.sh
	

## Important Notes
- If it is your first time installing Kismet on your system you will need to add your user to the Kismet group and log out before running Kismet. See line 126 of kms.sh
- Ubuntu 18 libwebsockets you may want to configure with --disable-libwebsockets. See line 120 of kms.sh
- Depending on how much ram your system has, you may want to make with less cpu cores. make -j#number of cores. See line 123 of kms.sh By default it will use all available

### kms.sh
	USAGE: ./kms.sh -argument

	Arguments:
	-h help
	-b Backup your current kismet config
	-c Conversions and stats. Runs kismetdb_statistics,
	kismet log tools on a files found in kimset_logs/
	-d Prints debug and Kismet environment info
	-i Install Kismet. Remove ~/kismet, Git clone current release
	-p Install plugins found in plugins/ dir
	-r Backup and remove Kismet configs and binaries to prep for upgrade
	-s Copy your custom created kismet_site.conf
	-t Create custom windowed tmux session called kisdev. tmux a -t kisdev


### Kismet dependencies -- required for install ./kms -i
	sudo apt install build-essential git libwebsockets-dev pkg-config zlib1g-dev libnl-3-dev libnl-genl-3-dev libcap-dev libpcap-dev libnm-dev libdw-dev libsqlite3-dev libprotobuf-dev libprotobuf-c-dev protobuf-compiler protobuf-c-compiler libsensors4-dev libusb-1.0-0-dev python3 python3-setuptools python3-protobuf python3-requests python3-numpy python3-serial python3-usb python3-dev python3-websockets librtlsdr0 libubertooth-dev libbtbb-dev -y

### Kismet DB -- required for log features ./kms -c
	pip3 install kismetdb

### Plugins
Add your own custom plugins or get some great community built ones located at: https://kismetwireless.net/#plugins

kms.sh -p will cd to: "~/kismet-master-setup/plugins", clone any git you have added and install to Kismet

Make sure you have the three required lines per plugin

	git clone https://github.com/user/EXAMPLE-PLUGIN.git
	cd cloned_repo_name
	sudo make install

### To do
Add option to disable libwebsockets during build (Ubuntu 18 has outdated package which causes issues with install)

###	Optional dependencies for experimenting with community plugins

#### Kismet rest
	pip3 install kismet_rest

#### pcapinator
	pip3 install python-dateutil pandas
	apt install tshark

