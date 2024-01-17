#!/bin/bash
#disable selinx

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

reboot
