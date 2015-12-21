#!/usr/bin/python
# -*- coding: utf-8 -*-
 
# ce programme interroge l agenda google et renvoie la temperature du jour
# dans un fichier texte
# on utilise gcalcli qui doit etre installe
 
import time , os
from datetime import date, tzinfo, timedelta, datetime 
from subprocess import (PIPE, Popen)
 
############# Parametres #################################
# Nom du calendrier google qui contient les actions Domoticz
ConsigneSOS = "17"
domoticz_cal="Maison"
 
#options de la ligne de commande cf doc google
options="--tsv --military --detail_url='short'"
 
# fichier et chemin pour agenda
rep = "/var/tmp/RAM_FILE/"
#file = rep + "googlecal.txt"
FileConsigne = rep + "Consigne"
 
#debug = 1 on affiche les chaines de caracteres recues
debug=0
aujourdhui = date.today()
 
# fin du parametrage #

#aujourdhui = datetime(year, month, day,hour, minute )
duree_de_un_jour = timedelta(1) # Represente la duree d'une journee
demain = aujourdhui + duree_de_un_jour
hier = aujourdhui - duree_de_un_jour

###############  fin des parametres 
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

datej=time.strftime('%Y-%m-%d',time.localtime())
#datej=time.strftime('%d/%m/%y',time.localtime())
heurej=time.strftime('%H:%M',time.localtime())
lignecde="gcalcli --cal="+domoticz_cal+" --started agenda "+"'"+str(aujourdhui)+" "+str(heurej)+"' '"+str(demain)+"' "+options
#############################
 
CheckFile()
 
#Calendar = os.system(lignecde)
Calendar = Popen(lignecde, stdout=PIPE, shell=True).communicate()[0].split()
if datej == Calendar[0] and heurej >= Calendar[1] and heurej <= Calendar[3]:
    if str(Calendar[5]) != "":
        ConsF = open(FileConsigne, "w")
        print Calendar[0],Calendar[1],Calendar[2],Calendar[3],Calendar[5]
        ConsF.write(str(Calendar[5]))
        ConsF.close()
 
if debug!=0:
    print datej,heurej
    print lignecde
    #os.system ('cat ' + file )
    print "-d= " +Calendar[0],Calendar[1],Calendar[2],Calendar[3],Calendar[5] #,Calendar[0]


