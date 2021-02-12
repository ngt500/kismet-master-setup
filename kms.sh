#!/bin/bash
BACKUPDATE=`date +%F:%H:%M`
KISMET_EXISTS=`pkg-config --exists kismet`
KISMET_EXISTS_OUTPUT=`echo $?`
NEWLINE=`echo -e "\n"`

#reset getopts
OPTIND=1

while getopts "bcdhiprst" opt; do
	case "$opt" in
		h)
	echo "
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
	-t Create custom windowed tmux session called kisdev. tmux a -t kisdev"
	echo $NEWLINE
		;;
		b)
			echo 'Backing up to kismet-backups/'
			mkdir -p ~/kismet-master-setup/kismet-backups
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE/bin
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE/conf
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE/kismet-plugins
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE/.kismet

			sudo cp /usr/local/bin/kismet* ~/kismet-master-setup/kismet-backups/$BACKUPDATE/bin
			sudo cp /usr/local/etc/kismet* ~/kismet-master-setup/kismet-backups/$BACKUPDATE/conf
			sudo cp -r /usr/local/lib/kismet/* ~/kismet-master-setup/kismet-backups/$BACKUPDATE/kismet-plugins
			cp ~/.kismet/* ~/kismet-master-setup/kismet-backups/$BACKUPDATE/.kismet
			echo "Backup done. Setting permissions for current user on backup files"
			sudo chown -R $(id -u):$(id -g) kismet-backups/
			echo "Done"
		;;
		c)
			cd kismet-logs/
			mkdir -p alerts-csv
			mkdir -p datasources-csv
			mkdir -p devices-csv
			mkdir -p devices-json
			mkdir -p pcap
			mkdir -p stats
			mkdir -p stripped
			mkdir -p wigle
			if [ $2 == 'purge' ]; then
				echo "Purging previous conversions"
				rm -rf alerts-csv/*.*
				rm -rf datasources-csv/*.*
				rm -rf devices-csv/*.*
				rm -rf devices-json/*.*
				rm -rf pcap/*.*
				rm -rf stats/*.*
				rm -rf stripped/*.*
				rm -rf wigle/*.*
			fi
			counter=0
			for entry in "."/*.kismet
			do
				kismetdb_statistics --in $entry > $entry-stats.txt
				kismetdb_dump_devices --in $entry --out $entry.json
				kismetdb_strip_packets --skip-clean --in $entry --out $entry.stripped
				kismet_log_to_csv --in $entry --table devices
				kismet_log_to_csv --in $entry --table datasources
				kismet_log_to_csv --in $entry --table alerts
				kismet_log_to_pcap --in $entry --out $entry.pcap
			  LOCATION_DATA=$(grep "Location data:" $entry-stats.txt)
			  if [[ "$LOCATION_DATA" != *"Location data: None"* ]]; then
				kismetdb_to_wiglecsv --skip-clean --in $entry --out $entry.wigle.csv
			  	mv $entry.wigle.csv wigle/
			  fi
			  ((counter++))
			done
			if [ $counter -gt 0 ]; then
				#move files
				mv *kismet-stats.txt stats/
				mv *kismet.json devices-json/
				mv *kismet.stripped stripped/
				mv *kismet-devices.csv devices-csv/
				mv *kismet-datasources.csv datasources-csv/
				mv *kismet-alerts.csv alerts-csv/
				mv *kismet.pcap pcap/
			fi
		;;
		d)
			if [ $KISMET_EXISTS_OUTPUT == 0 ]; then
				echo "Kismet pkg-config variables:"
				KISMET_VARIABLES=`pkg-config --print-variables kismet`
				for entry in $KISMET_VARIABLES
				do
					echo -e "$entry\n$(pkg-config --variable=$entry kismet)\n"
				done
				echo "Kismet Version:"
				kismet -v
			else
				echo "Kismet not found"
			fi
		;;
		i)
			echo "Removing previous Kismet git clone"
			cd ~
			rm -rf kismet
			git clone --recursive https://github.com/kismetwireless/kismet.git
			cd kismet/
			git pull
			echo "Next steps: configure, make and make suidinstall"
			PROCNUM=`nproc`
			echo "Hint: use make -j$PROCNUM to utilizes all available cores"
			echo "Configure time"
			#./configure --disable-libwebsockets
			./configure
			echo "Make with -j$PROCNUM"
			make -j$PROCNUM
			echo "Make suidinstall"
			sudo make suidinstall
			#sudo usermod -aG kismet $USER
			#logout
			groups
			;;
		p)
			echo 'Setting up and installing plugins'
			cd ~/kismet-master-setup/plugins/
			#git clone https://github.com/soliforte/kismetreportgen.git
			#cd kismetreportgen
			#sudo make install
			#cd ../
			#git clone https://github.com/soliforte/foxfinder.git
			#cd foxfinder
			#sudo make install
			echo "Done"
		;;
		r)
			echo 'Backing up to kismet-backups/ and removing kismet'
			mkdir -p ~/kismet-master-setup/kismet-backups
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE/bin
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE/conf
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE/kismet-plugins
			mkdir ~/kismet-master-setup/kismet-backups/$BACKUPDATE/.kismet

			sudo mv /usr/local/bin/kismet* ~/kismet-master-setup/kismet-backups/$BACKUPDATE/bin
			sudo mv /usr/local/etc/kismet* ~/kismet-master-setup/kismet-backups/$BACKUPDATE/conf
			sudo mv /usr/local/lib/kismet/* ~/kismet-master-setup/kismet-backups/$BACKUPDATE/kismet-plugins
			mv ~/.kismet/* ~/kismet-master-setup/kismet-backups/$BACKUPDATE/.kismet
			echo "Backup done. Setting permissions for current user on backup files"
			sudo chown -R $(id -u):$(id -g) kismet-backups/
			echo "Done"
		;;
		s)
			echo 'Copying kismet_site configuration'
			#cp ~/kismet-master-setup/certs/kismet-cert.pem ~/.kismet/
			#cp ~/kismet-master-setup/certs/kismet-cert.key ~/.kismet/
			sudo cp ~/kismet-master-setup/kismet_site.conf /usr/local/etc/
			echo "Done"
		;;
		t)
			tmux new-session -d -s kisdev -n kismet -c ~/
			tmux split-window -d -t kisdev:kismet -c ~/kismet-master-setup/
			tmux split-window -h -d -t kisdev:kismet -c ~/kismet-master-setup/
			tmux select-layout -t kisdev:kismet main-vertical
			tmux list-panes -t kisdev:kismet
			tmux a -t kisdev
		;;
	esac
done