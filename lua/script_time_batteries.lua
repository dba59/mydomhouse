--~/domoticz/scripts/lua/script_time_battery.lua
commandArray = {}

-- ==============================
-- Check battery level of devices
-- ==============================

--Uservariables
BatteryLevelSetPoint=30
EmailTo="denis62310@gmail.com"
ReportHour=21
ReportMinute=34
DomoticzIP="192.168.0.25"
DomoticzPort="8081"
Message = 'DOMOTICZ Batterie check'
DeviceFileName = "/var/tmp/RAM_FILE/JsonAllDevData.tmp"

TelegramTo="denis_BOCQUET"
--Message = ''
DormantTime = 5

function timedifference(s)
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

-- Time to run?
time = os.date("*t")

--if time.hour == ReportHour and time.min == ReportMinute then
-- if time.hour then

   -- Update the list of device names and ids to be checked later
   os.execute("curl 'http://" .. DomoticzIP .. ":" .. DomoticzPort .. "/json.htm?type=devices&order=name' 2>/dev/null| /usr/local/bin/jq -r '.result[]|{(.Name): .idx}' >" .. DeviceFileName)
   BattToReplace = false

   -- Retrieve the battery device names from the user variable - stored as name one|name 2|name 3|name forty one
   DevicesWithBatteries = uservariables["DevicesWithBatteries"]
   DeviceNames = {}
   --print(DevicesWithBatteries)
   for DeviceName in string.gmatch(DevicesWithBatteries, "[^|]+") do
     DeviceNames[#DeviceNames + 1] = DeviceName
   end
   
   -- Loop round each of the devices with batteries
   for i,DeviceName in ipairs(DeviceNames) do

      -- Determine device id
      local handle = io.popen("/usr/local/bin/jq -r '.\"" .. DeviceName .. "\" | values' " .. DeviceFileName)
      local DeviceIDToCheckBatteryLevel = handle:read("*n")
      -- print("check batterie level :" .. DeviceIDToCheckBatteryLevel)
      handle:close()

      -- Determine battery level
      local handle = io.popen("curl 'http://" .. DomoticzIP .. ":" .. DomoticzPort .. "/json.htm?type=devices&rid=" .. DeviceIDToCheckBatteryLevel .. "' 2>/dev/null | /usr/local/bin/jq -r .result[].BatteryLevel")
      local BattLevel = string.gsub(handle:read("*a"), "\n", "")
      handle:close()
      -- print( DeviceName .. ' batterylevel is ' .. BattLevel .. "%")
      if ( DeviceName == "TeHu_Salon" ) then
          commandArray[1]={['UpdateDevice'] = '78|0|'.. BattLevel}
      end
      if ( DeviceName == "TeHu_Cuisine" ) then
          commandArray[2]={['UpdateDevice'] = '81|0|'.. BattLevel}
      end
      if ( DeviceName == "TeHu_SdB" ) then
          commandArray[3]={['UpdateDevice'] = '80|0|'.. BattLevel}
      end

--[[
      -- Check batterylevel against setpoint
      if tonumber(BattLevel) < BatteryLevelSetPoint then
         BattToReplace = true
         print("!!!" .. DeviceName .. " batterylevel below " .. BatteryLevelSetPoint .. "%, current " .. BattLevel .. "%")
         Message = Message .. ' *** ' .. DeviceName .. ' battery level is ' .. BattLevel .. '%'
      end
]]
      -- Check when device last seen
      difference = timedifference(otherdevices_lastupdate[DeviceName]) / 3600
      if tonumber(difference) > DormantTime then
         BattToReplace = true
         print("!!!" .. DeviceName .. " has not been seen for " .. difference .. " hours")
         Message = Message .. '\n *** '  .. DeviceName .. ' has not been seen for ' .. difference .. ' hours'
      end
   end

   -- Only send an email if at least one battery fails the test
   if(BattToReplace) then
      commandArray['SendEmail']='Domoticz Battery Levels#'.. Message .. '#' .. EmailTo
--      os.execute("/home/pi/domoticz/scripts/lua/Telegram.sh " .. TelegramTo .. " \"" .. Message .." \"")
      command = "/home/pi/domoticz/scripts/lua/Telegram.sh " .. TelegramTo .. " \"" .. Message .." \""
      print(command)
   end
--end

--LUA default
return commandArray
