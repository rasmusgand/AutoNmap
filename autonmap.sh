#!/bin/bash

DATE=`date +%F`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

test -e /etc/autonmap.conf && . /etc/autonmap.conf || \
  test -e /usr/local/etc/autonmap.conf && . /usr/local/etc/autonmap.conf || \
    test -e "$DIR/"autonmap.conf && . "$DIR/"autonmap.conf || \
      test -e ./autonmap.conf && . ./autonmap.conf || {
        echo Error: can not find config file autonmap.conf, place it in /etc/
        exit 1
      }

test -n "$RUN_DIRECTORY" -a -n "$WEB_DIRECTORY" || {
  echo Error: no configuration data loaded
  exit 1
}


# be sure the paths are there
mkdir -p /usr/local/autonmap/
mkdir -p /var/www/autonmap/

echo "`date` - Welcome to AutoNmap2. "

# Ensure we can change to the run directory
cd $RUN_DIRECTORY || exit 2
echo "`date` - Running nmap, please wait. This may take a while.  "
$NMAP --open -T4 -PN $SCAN_SUBNETS -n -oX scan-$DATE.xml --stylesheet "nmap.xsl" > /dev/null
echo "`date` - Nmap process completed with exit code $?"

# If this is not the first time autonmap2 has run, we can check for a diff. Otherwise skip this section, and tomorrow when the link exists we can diff.
if [ -e scan-prev.xml ]
then
    echo "`date` - Running ndiff..."
    # Run ndiff with the link to yesterdays scan and todays scan
    DIFF=`$NDIFF scan-prev.xml scan-$DATE.xml`

    echo "`date` - Checking ndiff output"
    # There is always two lines of difference; the run header that has the time/date in. So we can discount that.
    if [ `echo "$DIFF" | wc -l` -gt 2 ]
    then
            echo "`date` - Differences Detected. Sending mail."
            echo -e "AutoNmap2 found differences in a scan for '${SCAN_SUBNETS}' since yesterday. \n\n$DIFF\n\nFull report available at $WEB_URL" | mail -s "AutoNmap2" $EMAIL_RECIPIENTS
    else
            echo "`date` - No differences, skipping mail. "
    fi

else 
    echo "`date` - There is no previous scan (scan-prev.xml). Cannot diff today; will do so tomorrow."
fi

# Copy the scan report to the web directory so it can be viewed later.
echo "`date` - Copying XML to web directory. "
cp scan-$DATE.xml $WEB_DIRECTORY

# Create the link from today's report to scan-prev so it can be used tomorrow for diff.
echo "`date` - Linking todays scan to scan-prev.xml"
ln -sf scan-$DATE.xml scan-prev.xml

echo "`date` - AutoNmap2 is complete."
exit 0 
