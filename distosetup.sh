#!/bin/bash
#disable selinx

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
systemctl disable firewalld 
systemctl stop firewalld 

reboot
