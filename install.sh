#!/bin/sh
echo Checking environment ...
NMAP=`which nmap 2> /dev/null`
MAIL=`which mail 2> /dev/null`
test -n "$NMAP" && echo "nmap: ok" || echo "nmap: not found - fix this!"
test -n "$MAIL" && echo "mail: ok" || echo "mail: not found - fix this!"
echo Installing autonmap
echo Copying autonmap.sh to /usr/local/bin
cp -v autonmap.sh /usr/local/bin || exit 1
echo Copying autonmap.conf to /etc
cp -v autonmap.conf /etc || exit 1
echo Creating daily run job in /etc/cron.daily/autonmap.sh
echo '#!/bin/sh' > /etc/cron.daily/autonmap.sh || exit 1
echo '/usr/local/bin/autonmap.sh >> /var/log/autonmap.log || exit 1' >> /etc/cron.daily/autonmap.sh || exit 1
chmod 755 /etc/cron.daily/autonmap.sh
echo Done.
echo NOTE: Do not forget to config autonmap in /etc/autonmap.conf
