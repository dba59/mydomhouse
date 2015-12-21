#!/usr/bin/python

import re,sys, os, time
from datetime import tzinfo, timedelta, datetime
from time import gmtime, strftime, localtime

localtime = strftime("%a %b %d  %I:%M%P", localtime()) #.split()

jour = localtime[:10]
heure = str(localtime[12:19])
#heure = " 4:00pm"
ConsFile = open("/var/tmp/RAM_FILE/Consigne", "r")
ConsigneSOS = ConsFile.read()
#print "c", ConsigneSOS
ConsFile.close()
ConsF = open("/var/tmp/RAM_FILE/Consigne", "w")
with open("/var/tmp/RAM_FILE/GcalCond.txt") as f:
	data = f.readlines()
	i=len(data)
	while i!=0:
		#if ( str(data[i-1][:10]) == jour ):
		if ( str(data[i-1][12:19]) <= heure ) and ( len(data[i-1][12:19]) >0):
			#print(data[i-1][:10])
			#print(data[i-1][12:19],heure)
			Consigne = str(data[i-1][21:23])
			#print("Cons=",Consigne,len(Consigne))
			ConsigneSOS = Consigne
		else:
			Consigne = ConsigneSOS
		i=i-1

if ( len(Consigne) >= 0 ): 
	#print "e", Consigne
	ConsF.write(str(Consigne))
f.close()
ConsF.close()

