--/home/pi/domoticz/scripts/lua/script_time_consigne.lua
commandArray = {}

-- otherdevices and otherdevices_svalues are two item array for all devices: 
--   otherdevices['yourotherdevicename']="On"
--	otherdevices_svalues['yourotherthermometer'] = string of svalues
--

tmp="/var/tmp/RAM_FILE/Consigne" f=io.open(tmp)
if f then
	while true do
		value = f.read(f)
    	if not value  then
        	--print("no lines read Calendar listing "..tmp)
       	break
    	else

	    	-- print ("Consigne=" .. tostring(value))
			Consigne = tostring(value)
    	end
   	end
end
f:close()

--[[
    file, err = io.open("/var/tmp/RAM_FILE/Consigne", "r")
    if file == nil then
       print("Couldn't open file: "..err)
    else
       Consigne = file:read()
       file:close()
       return tonumber(Consigne)
    end

]]--
-- nowtemp = tonumber(otherdevices_svalues['Te Consigne'])
print('Current Consigne: '..tostring(Consigne))
--Uncomment to use UpdateDevice
-- commandArray['UpdateDevice'] = '41|0|'..Consigne
-- commandArray['UpdateDevice'] = '161|0|'..Consigne
--Uncomment to use OpenURL and json
--commandArray['OpenURL'] = 'http://192.168.0.25:8081/json.htm?type=command&param=udevice&idx=41&nvalue=0&svalue='..tostring(nowtemp+1)
commandArray[1]={['OpenURL']='http://192.168.0.25:8081/json.htm?type=command&param=udevice&idx=41&nvalue=0&svalue='..tostring(Consigne) }
commandArray[2]={['OpenURL']='http://192.168.0.25:8081/json.htm?type=command&param=udevice&idx=161&nvalue=0&svalue='..tostring(Consigne) }

return commandArray
