#!/usr/bin/python
#import pdb; pdb.set_trace()
import re,sys, os, time
from datetime import date, tzinfo, timedelta, datetime
from time import gmtime, strftime, localtime, strptime

ConsigneSOS = "17"

localtime = strftime("%a %b %d  %I:%M%P", localtime()).split("  ")
FileConsigne = "/var/tmp/RAM_FILE/Consigne"
FileCalendar = "/var/tmp/RAM_FILE/GcalCond.txt"
jour = str(localtime[0][:])
heure = str(localtime[1])

#time.gmtime(time.time())
year = time.localtime(time.time())[0]
month = time.localtime(time.time())[1]
day = time.localtime(time.time())[2]
hour = time.localtime(time.time())[3]
minute = time.localtime(time.time())[4]

aujourdhui = datetime(year, month, day,hour, minute )
duree_de_un_jour = timedelta(1) # Represente la duree d'une journee
demain = aujourdhui + duree_de_un_jour
hier = aujourdhui - duree_de_un_jour

#print(localtime)
#print(aujourdhui)
#print(duree_de_un_jour)
#print(demain)
#print(hier)

#auj=str(date.today())
#dem=str(date.today()+timedelta(1))
#print("auj=",auj)
#print("dem=",dem)
t = (year, month, day, hour, minute,0,0,0,0)
SecNow = time.mktime( t )
SecHier = time.mktime(strptime(str(hier),'%Y-%m-%d %H:%M:%S'))
SecDemain = time.mktime(strptime(str(demain),'%Y-%m-%d %H:%M:%S'))

def CheckFile():
	if (not os.path.isfile(FileConsigne) ):
		#print ("Erreur! Le fichier n'a pas pu etre ouvert")
		fi = open(FileConsigne,"w")
		fi.write(ConsigneSOS)
		fi.close()

def GetConsigne():
	if (os.path.isfile(FileConsigne) ):
		ConsFile = open(FileConsigne, "r")
		ConsigneSOS = ConsFile.read()
		#print "c", ConsigneSOS
		ConsFile.close()

CheckFile()
GetConsigne()
with open(FileCalendar) as f:
	data = f.read().split("  ")
	#print(data)

i=len(data)
Cal = []
while i!=0:
	i=i-1
	#print(data[i],len(data[i]))
	if (len(str(data[i])) != 0 ): 
		if (len(str(data[i])) <= 11 ):
			#print(data[i],len(data[i]))
			Cal.append(str(data[i]))
			# donne le jour
		else:
			i=i-1

Calendar = []
j = jour
i=len(Cal)
print("______") 
while i!=0:
	i=i-1
	#print(Cal[i],len(Cal[i]))
	if (len(str(Cal[i])) == 11 ):
		Cal[i] = Cal[i].replace(" ","",1)
		#print(Cal[i],len(Cal[i]))

	if (len(str(Cal[i])) == 10 ):  # or (len(str(Cal[i])) == 11 ):
		#print(Cal[i])
		Calendar.append(Cal[i])
		#print(Cal[i],Cal[i-1],Cal[i-2])
		Calendar.append(Cal[i-1].replace(" ","",1))
		H = Cal[i-1]
		Calendar.append(Cal[i-2])
		C = Cal[i-2]
		j = Cal[i]
		i = i - 2
	else:
		Calendar.append(j)
		Calendar.append(Cal[i].replace(" ","",1))
		H = Cal[i]
		Calendar.append(Cal[i-1])
		C = Cal[i-1]
		#print(j,Cal[i],Cal[i-1])
		i = i - 1
	
	H = H.replace(" ","",1)
	temps = str(year) +" "+ j +" "+ H
	SecCons=time.mktime(strptime(temps,'%Y %a %b %d  %I:%M%p'))
	Calendar.append(SecCons)

i=len(Calendar) 
Flag = False
while i!=0:
	i=i-1
	#print("aa="+str(Calendar[i]))
	if ( str(Calendar[i]) == jour ): #and not Flag:
		print(Calendar[i],Calendar[i+1],Calendar[i+2],Calendar[i+3])
		if Calendar[i+3] < SecNow:
			ConsF = open(FileConsigne, "w")
			#print(Calendar[i-4],Calendar[i-3],Calendar[i-2],Calendar[i-1],SecNow)
			#print(Calendar[i],Calendar[i+1],Calendar[i+2],Calendar[i+3],SecNow)
			Flag = True
			ConsF.write(str(Calendar[i+2]))
			ConsF.close()


f.close()

CheckFile()
