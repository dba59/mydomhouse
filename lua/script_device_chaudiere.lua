
Hysteresis = 0.2
T_Max_Nuit = 17
-- Heure fin temperature de nuit
H_FinNuit = 5
-- Heure debut temperature de nuit
H_DebNuit = 22
-- degre en moins sur consigne
Minus_Consigne = 0
MinMax_Consigne = 1
Temps_Confort = 2700
ConsigneSOS = 19

TE_Retour_mini = 30
Message = "" 
Heure = tonumber(os.date("%H"))
PauseChaudiere = 300

months={Jan=01,Feb=02,Mar=03,Apr=04,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}

function recode(str) -- a calendar date string to mddhhmm
  m=months[str:sub(1,3)]
  v=tonumber(m..str:sub(5,6)..str:sub(8,9)..str:sub(11,12))
  --print("recode: ["..str.."] -> "..v)
  return v
end

function GetConsigne()
-- local file = io.open("/home/pi/domoticz/Consigne", "r")
    file, err = io.open("/var/tmp/RAM_FILE/Consigne", "r")
    if file == nil then
       print("Couldn't open file: "..err)
    else
	   Consigne = file:read()
	   file:close()
	   return tonumber(Consigne)
    end
end

commandArray = {}

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function timedifference (s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   t1 = os.time()
   t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
   difference = os.difftime (t1, t2)
   return difference
end

function Debug (Mesg)
    if (otherdevices['DEBUG']=="On") then
		IsDebug = true
	else
		IsDebug = false
	end
	if IsDebug then
     -- print("\n------------------------- \ndebug = " .. Mesg .."\n-------------------------")
     print(" DEBUG = " .. Mesg )
    end
end

function JourNuit ()
	if Heure < H_DebNuit and Heure > H_FinNuit then 
		-- print ("jour")
		return 1
	else
		-- print ("nuit")
		return 0
	end
end

-- for i, v in pairs(otherdevices_svalues) do print(i, v) end
--  print ("retour " .. otherdevices_svalues['TE_Retour'] )

SOSChauffage = otherdevices['SOS Chauffage']
Consigne = GetConsigne(ConsigneSOS)

-- Consigne = 19
Confort = otherdevices['Confort']
TSalon = round(tonumber(otherdevices_temperature['TeHu_Salon']),4)
TCuisine = round(tonumber(otherdevices_temperature['TeHu_Cuisine']),4)
TSmkSalon = round(tonumber(otherdevices_svalues['Te_Smoke']),4)
Last_Change_Chaudiere = timedifference(otherdevices_lastupdate['Chaudiere'])
Last_Change_Confort = timedifference(otherdevices_lastupdate['Confort'])

TE_Retour = round(tonumber(otherdevices_svalues['TE_Retour'] ),1)
TE_Envoi = round(tonumber(otherdevices_svalues['TE_Envoi'] ),1)
-- TE_Envoi = round(tonumber(otherdevices_temperature['TE_Envoi'] ),4)
-- TE_Retour = round(tonumber(otherdevices_temperature['TE_Retour'] ),4)

Message = Message .. "[ Start = " .. TE_Envoi .. " ]"
Message = Message .. "[ Back = " .. TE_Retour .. " ]"
Message = Message .. "[ Order = ".. tostring(Consigne) .." ]"
Message = Message .. "[ Salon = " .. TSalon .. " ]"
Message = Message .. "[ Boiler = " .. otherdevices['Chaudiere'] .. " ]"
Message = Message .. "[ LastChgt = " .. Last_Change_Chaudiere .. " ]"
Message = Message .. "[ J/N = " .. JourNuit() .. " ]"

-- if ( TCuisine < 16) and ( Last_Change_Confort > 3600 ) then
--     if ( otherdevices['Confort'] == 'Off' ) then commandArray['Confort'] = 'On' end
-- end
--if ( TSmkSalon < 17) and ( Last_Change_Confort > 3600 ) then
--    if ( otherdevices['Confort'] == 'Off' ) then commandArray['Confort'] = 'On' end
--end

if ( SOSChauffage == 'On' ) then
  Message = Message .. " SOS Chauffage chaudiere on" 
  print ( Message )
  if ( otherdevices['Chaudiere'] == 'Off' ) then commandArray['Chaudiere'] = 'On' end
else
  if (devicechanged['TeHu_Salon']) or (Confort == 'Off') then
--  print (" chaudiere status :" .. otherdevices['Chaudiere'] .. " --- " )
    if (TSalon <= Consigne) then -- or (Confort == 'On') then
      if (JourNuit()== 1) then  -- le jour
        Message = Message .. " jour Marche chaudiere on" 
        print ( Message )
        if ( TE_Retour < TE_Retour_mini and otherdevices['Chaudiere'] == 'Off' ) then commandArray['Chaudiere'] = 'On' end
      else  -- la nuit
        -- if TSalon <= (Consigne - MinMax_Consigne) then
        if (TSalon <= tonumber(T_Max_Nuit))  then
          Message = Message .. " nuit Marche chaudiere on" 
          if ( TE_Retour < TE_Retour_mini and otherdevices['Chaudiere'] == 'Off' ) then commandArray['Chaudiere'] = 'On' end
          print ( "aa " .. Message )
        else
          Message = Message .. " nuit Arret chaudiere off" 
          if ( otherdevices['Chaudiere'] == 'On' ) then commandArray['Chaudiere'] = 'Off' end
          if ( otherdevices['Confort'] == 'On' ) then commandArray['Confort'] = 'Off' end
          print ( "ab " .. Message )
        end
      end
    else
      -- ajout confort
      if Confort == 'On' and TSalon <= (Consigne + MinMax_Consigne) then
        if Last_Change_Chaudiere < Temps_Confort then
          Message = Message .. " [ Confort = " .. Confort .. "] Mode Confort On"
          if ( TE_Retour < TE_Retour_mini and otherdevices['Chaudiere'] == 'Off') then commandArray['Chaudiere'] = 'On' end
          print ( "c " .. Message )
          --commandArray['Chaudiere'] = 'On'
        else
          Message = Message .. " [ Confort = " .. Confort .. "] Mode Confort Off"
	      if ( otherdevices['Chaudiere'] == 'On' ) then commandArray['Chaudiere'] = 'Off' end
	      if ( otherdevices['Confort'] == 'On' ) then commandArray['Confort'] = 'Off' end
          print ( "d " .. Message )
        end
      else
        Message = Message .. " [ Confort= " .. Confort .. "] "
        -- print ( Message )
	    if ( otherdevices['Chaudiere'] == 'On' ) then commandArray['Chaudiere'] = 'Off' end
	    if ( otherdevices['Confort'] == 'On' ) then commandArray['Confort'] = 'Off' end
      end
    end
 --   LgoFile = io.open("/home/pi/domoticz/chaudiere.log", "a")
--	LgoFile:write(os.date("%c") .." : " .. Message .. "\n")
--    LgoFile:close()
  end
end
Debug(Message )
return commandArray

