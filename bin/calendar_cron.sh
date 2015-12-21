#!/bin/bash

# wrap to use by cron

#/usr/local/bin/gcalcli --nocolor --calendar="Maison" --started agenda "$(date '+%b %d %Y %I:%Mpm')" | tr "\n" " " > /var/tmp/RAM_FILE/GcalCond.txt && /home/pi/bin/Consigne.py
/usr/local/bin/gcalcli --nocolor --calendar="Maison" --started agenda  | tr "\n" " " > /var/tmp/RAM_FILE/GcalCond.txt && /home/pi/bin/Consigne.py >> /var/tmp/RAM_FILE/consigne.log

if [ ! -s /var/tmp/RAM_FILE/Consigne ]
then
  /bin/echo 17 > /var/tmp/RAM_FILE/Consigne
fi
