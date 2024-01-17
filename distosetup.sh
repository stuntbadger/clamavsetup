#!/bin/bash
#disable selinx

sed -i 's/#SELINUX=permissive /SELINUX=disabled/' /etc/clamd.d/scan.conf /etc/selinux/config

reboot
