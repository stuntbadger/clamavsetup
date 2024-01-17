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
chmod 600 /etc/postfix/sasl_passwd
cp /etc/postfix/main.cf /etc/postfix/main.cf.backup
sed -i '/#relayhost \= \[an.ip.add.ress\]/a relayhost = [smtp.gmail.com]:587' /etc/postfix/main.cf
sed -i '/#myhostname \= virtual.domain.tld/a myhostname = virus.local' /etc/postfix/main.cf

sed -i '/smtp_tls_CAfile/d'  /etc/postfix/main.cf
sed -i '/smtp_tls_security_level/d'  /etc/postfix/main.cf

cat <<EOF >> /etc/postfix/main.cf
smtp_use_tls = yes                                                                                 
smtp_sasl_auth_enable = yes   
smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
   
# Disallow methods that allow anonymous authentication
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
EOF

systemctl start postfix 

#quick test mail 
echo "Hopefully you can see this message  " | mailx -s "send email from virus.local" john.penney@gmail.com

reboot
