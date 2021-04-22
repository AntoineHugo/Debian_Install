#!/bin/bash
#Script pour le paramétrage d'un nouveau serveur

FILE=/tmp/script_install_compteur.txt
NC='\033[0m' # No Color
GREEN='\033[0;32m'
bold=$(tput bold) #Text en gras
RED='\033[0;31m'
ping -c 1 8.8.8.8 &> /dev/null

#Mise en place de garde fou en fonction de l'accès réseau, l'user ROOT et si le script a déjà été lancé
if [[ $? -ne 0 ]];
then
	echo -e "${RED}${bold}ERROR this VM can't reach internet the script can't be lauch${NC}"
elif [ "$EUID" -ne 0 ]
then
	echo -e "${RED}${bold}ERROR The user isn't ROOT the script can't be launch${NC}"
elif test -f "$FILE"; 
then	
	echo -e "${RED}${bold}ERROR This Script has already been run once the script can't be launch${NC}"	
else 
varuser=$(users)
#Début du script	

touch /tmp/script_install_compteur.txt
echo -e  "${GREEN}${bold}1/10 -- Paramétrage NTP :"
echo -e "################${NC}"
echo ""
echo ""
truncate -s 0 /etc/resolv.conf
echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf > /dev/null
cat /etc/resolv.conf



echo ""
echo ""
echo ""


echo -e "${GREEN}${bold}3/10 -- Mise à jour et installation"
echo -e "################${NC}"
echo ""
echo ""
apt update && apt upgrade -y
apt install -y vim htop sudo net-tools tree ntpdate iftop iotop screen uuid-runtime ncdu git curl zip


echo ""
echo ""
echo ""


echo -e "${GREEN}${bold}4/10 -- Paramétrage VIM & sudo"
echo -e "################${NC}"
echo ""
echo ""
sed -i -e "s/mouse=a/mouse-=a/g" /usr/share/vim/vim81/defaults.vim
rm /bin/sh
ln -s /bin/bash /bin/sh
echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> /root/.bashrc
echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> /home/$varuser/.bashrc
sed -i -e "s/\"set background/set background/g" /etc/vim/vimrc
sed -i -e "s/\"syntax on/syntax on/g" /etc/vim/vimrc
sed -i '/User privilege specification/ a\uservariable    ALL=\(ALL:ALL\) ALL' /etc/sudoers
sed -i -e "s/uservariable/$varuser/g" /etc/sudoers
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/sbin/ntpdate ntp.ovh.net > /dev/null") | crontab -


echo ""
echo ""
echo ""


echo -e "${GREEN}${bold}7/10 -- Paramétrages de session"
echo -e "################${NC}"
echo ""
echo ""
echo "auth required pam_access.so" | tee -a /etc/pam.d/common-auth
echo "session required pam_mkhomedir.so skel=/etc/skel umask=0022" | tee -a /etc/pam.d/common-session
echo "-:ALL EXCEPT root $varuser :ALL EXCEPT LOCAL" | tee -a /etc/security/access.conf
echo ""
echo -e "${bold}Le script est terminé, ${GREEN}ne pas oublier les VMWareTools et check le nom de carte réseau pour le parefeu${NC}"
echo ""
echo -e "${GREEN}${bold}Pour la suite installer les VmWareTools avec ces instructions : ${NC}"
echo -e "${GREEN}${bold}       - I/ Via l'interface du Vcenter, installer les VMwareTools ${NC}"
echo -e "${GREEN}${bold}       - II/ Sur la machine en root : ${NC}"
echo -e "${GREEN}       - 1/ ${NC}${bold}mount /dev/cdrom /mnt "
echo -e "${GREEN}       - 2/ ${NC}${bold}cd /tmp/"
echo -e "${GREEN}       - 3/ ${NC}${bold}tar xvf /mnt/VMwareTools-"
echo -e "${GREEN}       - 4/ ${NC}${bold}cd /tmp/vmware-tools-distrib/"
echo -e "${GREEN}       - 5/ ${NC}${bold}sudo ./vmware-install.pl"
echo -e "${GREEN}       - 6/ ${NC}${bold}rm -r /tmp/vmware-tools-distrib/${NC}"
echo ""
echo -e "${GREEN}Penser à bien paramétrer Munin${NC}"
echo ""
rm -f ./Debian10_Server_first_install.sh
fi
