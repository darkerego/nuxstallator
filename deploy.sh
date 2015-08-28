#!/bin/bash
##################################################
## 	PC Deploy V 1.0 -- Author DarkerEgo  	##
##################################################
## Define Programs to install/uninstall here:
GETLIST="harden-clients secure-delete git gimp vlc intel-microcode linux-firmware-nonfree"
KILLLIST="popularity-contest"
########
cwd=$(pwd)
CONFDIR="$cwd/conf"
DEPLOG="$cwd/deploy.log"
username=$username
RIGHT_NOW=$(date +"%x %r %Z")
#########
FWERROR1='Error enabling firewall!'
FWERROR2='Error opening port or port already open.'
AptError1='Error updating system!'
#########
# Directory for configuration files if applicable
#########
#if [ ! -d $cwd/conf ]; then
#mkdir conf
#echo $confERROR1
#exit
#fi

echo -e "
#####################################################
## PC DEPLOY Version 1.0 -- Author DarkerEgo		   ##
#####################################################
## A bash script to expedite the configuration of  ## 
## *nux systems post installation. 					   ##
## https://github.com/darkerego/ 					   ##
## Script will now configure the system and reboot ##
#####################################################
"


function config_USER(){

echo Configuring user...
touch $DEPLOG && echo $RIGHT_NOW >> $DEPLOG
echo "Specify credentials." #Username+Password of admin user
read -p "Enter username : " username
read -s -p "Enter password : " password
# Encrpyts the password variable with perl
pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
echo "Done."
echo "Go...! Setting up a user, ssh key and the firewall!"
echo "$username" /etc/passwd >/dev/null
useradd -m -p password $username
[ $? -eq 0 ] && echo "User $username has been added to system!" || echo "Adduser Fail!"


}

function config_FW(){

apt-get install ufw -y -qq > /dev/null # Ensure ufw is installed
ufw enable >> $DEPLOG || echo $FWERROR1 >> $DEPLOG
echo Done. Setting kernel tweaks...
}

function tweak_KERN(){
echo "Settings sysctl tweaks..."
sysctl -w net.netfilter.nf_conntrack_timestamp=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv6.conf.all.accept_source_route=0
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w vm.swappiness=10
sysctl -w kernel.randomize_va_space=1
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -p >> $DEPLOG
}

function update_SYS()
{
echo "Performing System Updates..." # Update repos&software
apt-get update -qq && apt-get upgrade -y -qq >> $DEPLOG || echo $AptError1 >> $DEPLOG
echo "Now installing: $GETLIST..."
apt-get install -y -qq $GETLIST || echo "Error installing some program(s)" >> $DEPLOG # Install/Remove desired programs
echo "Removing programs: $KILLLIST"
apt-get remove -y -qq $KILLLIST || echo "Kill list error!" >> $DEPLOG
}

# This function might not work on all systems and will be fixed

#function customize_SYS{
#cp $cwd/post/ubuntu-wallpaper.jpg /home/$user/ubuntu-wallpaper.jpg
#chmod 755 /home/$user/ubuntu-wallpaper.jpg
#gsettings set org.gnome.desktop.background picture-uri file:///home/$user/ubuntu-wallpaper.jpg
#reboot
#}


config_USER
tweak_KERN
config_FW
update_SYS


echo "All done!"
