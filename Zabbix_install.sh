#!/bin/bash

#<---------- Declaration of Functions ---------->

function install-packages-zabbix() { #  install packages zabbix function: It aims to gather all packages and install them for zabbix
    apt install build-essential libmariadb-dev sudo libxml2-dev snmp libsnmp-dev libcurl4-openssl-dev php-gd php-xml php-bcmath php-mbstring vim libevent-dev libpcre3-d>    #apt update -y && apt upgrade -y
    sleep 1
    read -p "What version of Zabbix do you want to have ?(X.X):"  version
    wget https://repo.zabbix.com/zabbix/${version}/debian/pool/main/z/zabbix-release/zabbix-release_${version}-1+debian${version_os}_all.deb
    echo -e "Upload Zabbix $version on OS version $version_os"
    sleep 1
    dpkg -i zabbix-release_${version}-1+debian${version_os}_all.deb
    apt update
    apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y
}

function zabbix-server() {  #  zabbix-server function: The goal is to create a sql file to group the commands and then ask the user to put a password and then put everything into operation
    read -p "Provide a password for the Zabbix Server user : "  password
    touch zabbix-sql-server.sql
    echo "create database zabbix character set utf8 collate utf8_bin;">zabbix-sql-server.sql
    echo "create user zabbix@localhost identified by '$password';">>zabbix-sql-server.sql
    echo "grant all privileges on zabbix.* to zabbix@localhost;">>zabbix-sql-server.sql
    mysql -u root <zabbix-sql-server.sql
    zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -u zabbix -p $password
    sed -i "s/DBPassword=/DBPassword=$password/">/etc/zabbix/zabbix_server.conf
    systemctl restart zabbix-server zabbix-agent apache2
    systemctl enable zabbix-server zabbix-agent apache2
}

function Description-Zabbix() { # Description-Zabbix function: The goal is to inform the user that he has finished the installation and give him the url of the site and the login
    IP=$(hostname -I)
    echo -e "Here it is all set up \nYou can finally access your site : https://$IP/zabbix/ \nUsername : admin \nPassword : zabbix"
}

function main() {   #   main function : The goal is to gather all the functions to make the script work
    install-packages-zabbix
    zabbix-server
    Description-Zabbix
    echo -e "By Foufou-exe | https://github.com/Foufou-exe | GNU GPL v3 \nThanks to you ❤️ "
}

#<------- Using the Functions ---------->

main
