#!/bin/sh
today=`/bin/date '+%d-%m-%Y__%H-%M-%S'`;    #Used to generate filename
IP="192.168.0.15"                         # IP address Camera 
snap_file="/var/tmp/RAM_FILE/ipprobot3_snap_$today.jpeg"

#Ping IP-address of camera to see if it's online, otherwise we don't have to grab a snapshot
if ping -c 1 $IP > /dev/null ; then 

/usr/bin/avconv -rtsp_transport tcp -i 'rtsp://admin:Den1s@192.168.0.15/o/video0' -f image2 -vframes 1 $snap_file

fi

if [ -e $snap_file ] ; then
  mv $snap_file /NAS/Denis/DOMOTIQUE/snap/iprobot3/
fi
