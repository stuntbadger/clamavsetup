#!/bin/bash
#disable selinx

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
systemctl disable firewalld 
systemctl stop firewalld 


#email setup 
yum install -y postfix mailx cyrus-sasl cyrus-sasl-plain
#not added email or app password in this file for security 
echo "[smtp.gmail.com]:587 email@gmail.com:apppassword" > /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd
cp /etc/postfix/main.cf /etc/postfix/main.cf.backup

reboot
