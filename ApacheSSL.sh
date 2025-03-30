#!/usr/bin/env bash

#Color variables
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
cyan="\e[36m"
endcolor="\e[0m"

#Checking for sudo privileges
privileges (){
if [[ $(id -u) -ne 0 ]]; 
	then
	echo -e "$red[!] WARNING!!! \nThis script must run with sudo privileges. \nPlease restart the script with sudo. \nTerminating script operations...$endcolor"
	exit 1
	else
	inst
fi
}



#installation checkup function
inst(){
if ! apt list --installed figlet &>/dev/null ;
	then
        echo -e "${red}\u26A0${endcolor} Figlet is not installed on system" ; sleep 0.2
        echo -e "${yellow}\u2022${endcolor} Installing figlet..."
        sudo apt install figlet -y &> /dev/null
        if ! apt list --installed figlet &>/dev/null ; 
		then 
		echo -e "${red}\u26A0${endcolor} Failed to install figlet" ; sleep 0.2
                else 
		echo -e "${green}\u2611${endcolor} Figlet was successfully installed" ; sleep 0.2
        fi
	else echo -e "${green}\u2611${endcolor} Figlet is already installed" ; sleep 0.2
fi

if ! apt list --installed apache2 &>/dev/null;
	then
	echo -e "${red}\u26A0${endcolor} Apache2 is not installed on system" ; sleep 0.2
	echo -e "${yellow}\u2022${endcolor} Updating system & installing apache2..."
	sudo apt update &>/dev/null && sudo apt install apache2 -y &>/dev/null
	if ! apt list --installed apache2 &>/dev/null;
		then
		echo -e  "${red}\u26A0${endcolor} Failed to install apache2. Exiting..." ; sleep 1 ; exit 1
		else
		echo -e "${green}\u2611${endcolor} Apache2 was successfully installed" ; sleep 0.2
	fi
	else
	echo -e "${green}\u2611${endcolor} Apache2 is already installed" ; sleep 0.2
fi



servinst
}

#Apache configuratin function
servinst(){
printf $red
figlet -f digital Launching Apache2 SSL Configuration...
printf $endcolor
sleep 1
echo -e "\n${yellow}\u2022${endcolor} Starting and configuring apache2 to launch at startup..."
sudo systemctl start apache2 &>/dev/null
sudo systemctl enable apache2 &>/dev/null
apachetest=$(curl -s http://localhost | grep "It works")
if [[ ! -z $apachetest ]]
	then
	echo -e "${green}\u2611${endcolor} Apache2 was successfully launched and configured"
	else
	echo -e "${red}\u26A0${endcolor} Failed to launch and configure apache2. Exiting..." ; sleep 1 ; exit 1
fi

echo -e "${yellow}\u2022${endcolor} Enabling SSL support..." ; sleep 0.2
sudo a2enmod ssl &>/dev/null
sudo systemctl reload apache2
echo -e "${yellow}\u2022${endcolor} Generating a dedicated certificate folder..." ; sleep 0.2
sudo mkdir /etc/apache2/ssl &>/dev/null
echo -e "${green}\u2611${endcolor} Folder was generated at ${cyan}/etc/apache2/ssl${endcolor}" ; sleep 0.2


#Prompt for certificate details
echo -e "\n📌 ${blue}Please enter SSL Certificate Details: ${endcolor}"
read -p "🌍 $(echo -e "${yellow}Country (2-letter code) [IL]:${endcolor}") " COUNTRY
read -p "🏙  $(echo -e "${yellow}State or Province Name:${endcolor}") " STATE
read -p "🏢 $(echo -e "${yellow}City:${endcolor}") " CITY
read -p "🏛  $(echo -e "${yellow}Organization Name:${endcolor}") " ORG
read -p "📂 $(echo -e "${yellow}Organizational Unit:${endcolor}") " DEPT
read -p "🌐 $(echo -e "${yellow}Common Name (Domain) [localhost]:${endcolor}") " COMMON_NAME
read -p "✉️  $(echo -e "${yellow}Email Address:${endcolor}") " EMAIL

#Set default values if left empty
if [ -z COUNTRY ];
	then
	COUNTRY=${COUNTRY:-IL}
fi

if [ -z COMMON_NAME ];
	then
	COMMON_NAME=${COMMON_NAME:-localhost}
fi

echo -e "\n${yellow}\u2022${endcolor} Generating SSL keys..." ; sleep 0.2
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/selfsigned.key -out /etc/apache2/ssl/selfsigned.crt -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$DEPT/CN=$COMMON_NAME/emailAddress=$EMAIL" &>/dev/null

echo -e "${yellow}\u2022${endcolor} Generating .conf file..." ; sleep 0.2
sudo bash -c "cat > /etc/apache2/sites-available/https-selfsigned.conf" <<EOF
<VirtualHost *:443>
    ServerAdmin admin@localhost
    DocumentRoot /var/www/html
    

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/selfsigned.crt
    SSLCertificateKeyFile /etc/apache2/ssl/selfsigned.key

    <Directory /var/www/html/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

EOF

echo -e "${green}\u2611${endcolor} File has been generated at ${cyan}/etc/apache2/sites-available/https-selfsigned.conf${endcolor}" ; sleep 0.2
echo -e "${yellow}\u2022${endcolor} Enabling configuration and restarting apache2..." ; sleep 0.2
sudo a2ensite https-selfsigned.conf &>/dev/null
sudo systemctl reload apache2 
echo -e "${yellow}\u2022${endcolor} Testing configuration..." ; sleep 0.2
configtest=$(sudo apache2ctl configtest 2>&1 | grep "Syntax OK")
if [[ ! -z $configtest ]];
	then
	echo -e "${green}\u2611${endcolor} Configuration status: ${green}Enabled${endcolor}" ; sleep 0.2
	echo -e "${green}\u2611${endcolor} Apache2 configuration complete. Exiting..." ; sleep 1 ; exit 1
	else
	echo -e "${red}\u26A0${endcolor} Configuration status: ${red}Disabled${endcolor}" ; sleep 0.2
	echo -e "${red}\u26A0${endcolor} Apache2 configuriation was unsuccessful. Exiting..." ; sleep 1 ; exit 1
fi
}

privileges
