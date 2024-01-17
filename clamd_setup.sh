#!/bin/bash
yum install -y epel-release
yum install -y clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd
mkdir /upload
mkdir /infected
mv /usr/lib/systemd/system/clamd@.service /usr/lib/systemd/system/clamd.service

cat > /usr/lib/systemd/system/clamd.service <<EOF
[Unit]
Description = clamd scanner daemon
After = syslog.target nss-lookup.target network.target
[Service]
Type = simple
ExecStart = /usr/sbin/clamd -c /etc/clamd.d/scan.conf --foreground=yes
Restart = on-failure
PrivateTmp = true
[Install]
WantedBy=multi-user.target
EOF

cat > /usr/lib/systemd/system/clamav-clamonacc.service <<EOF
[Unit]
Description=ClamAV On-Access Scanner
Documentation=man:clamonacc(8) man:clamd.conf(5) https://docs.clamav.net/
After=clamd@scan.service syslog.target network.target

[Service]
Type=simple
User=root
ExecStart=/usr/sbin/clamonacc -F --config-file=/etc/clamd.d/scan.conf --move=/infected

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable clamd.service
systemctl enable clamav-clamonacc.service
systemctl enable clamav-freshclam.service

# Configure ClamAV
sed -i 's/#LogFile /LogFile \/var\/log\/clamd.scan/' /etc/clamd.d/scan.conf
sed -i 's/#LogRotate /LogRotate \/var\/log\/clamd.scan/' /etc/clamd.d/scan.conf
sed -i 's/#PidFile /PidFile \/run\/clamd.scan\/clamd.pid/' /etc/clamd.d/scan.conf
sed -i 's/#TCPSocket /TCPSocket 3310/'  /etc/clamd.d/scan.conf
sed -i 's/#OnAccessIncludePath /OnAccessIncludePath \/upload/'  /etc/clamd.d/scan.conf
sed -i 's/#OnAccessPrevention /OnAccessPrevention yes/' /etc/clamd.d/scan.conf
sed -i 's/#OnAccessExtraScanning /OnAccessExtraScanning yes/' /etc/clamd.d/scan.conf

systemctl start clamd.service && systemctl start clamav-freshclam.service && systemctl start clamav-clamonacc.service

