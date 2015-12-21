#!/bin/bash
cd /home/pi/tg && bin/telegram-cli -k tg-server.pub -W <<AAA
status_online $1
msg $1 $2
status_offline $1
safe_quit
AAA
