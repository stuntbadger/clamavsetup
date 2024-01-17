#!/bin/bash
#/etc/clamav/detected.sh
#modify reply and to addresses

PATH=/usr/bin
alert="Signature detected: $CLAM_VIRUSEVENT_VIRUSNAME in $CLAM_VIRUSEVENT_FILENAME"

logtail="$(tail -n 50 /var/log/clamav/clamav.log | tac)"

# send email
export HOME=/root
/usr/bin/printf "Host: $HOSTNAME.\n$alert\n\ntail -n 50 /var/log/clamav/clamav.log\n\n\n$logtail" | /usr/bin/mailx -s "VIRUS ALERT - $HOSTNAME" -r REPLY@YOURDOMAIN.COM "ALERTS@YOURDOMNAIN.COM"

# Send the alert to systemd logger if exist, othewise to /var/log
if [[ -z $(command -v systemd-cat) ]]; then
        echo "$(date) - $alert" >> /var/log/clamav/detections.log
else
        echo "$alert" | /usr/bin/systemd-cat -t clamav -p emerg
fi
