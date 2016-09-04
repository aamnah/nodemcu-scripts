-- ORIGINAL: https://gist.github.com/rock3m/7da289ee41ced0488152

--- Config
SSID       = "YOUR_WIFI_NAME"
PASSWORD   = "YOUR_WIFI_PASSWORD"
TIMEOUT    = 30000000 -- 30s

--- Station modes
STAMODE = {
  STATION_IDLE             = 0,
  STATION_CONNECTING       = 1,
  STATION_WRONG_PASSWORD   = 2,
  STATION_NO_AP_FOUND      = 3,
  STATION_CONNECT_FAIL     = 4,
  STATION_GOT_IP           = 5
}

--- Connect to WIFI and then periodically send data to ThingSpeak.com
function connect(timeout)
  local time = tmr.now()
  wifi.sta.connect()

  -- Wait for IP address; check each 1000ms; timeout
  tmr.alarm(1, 1000, 1, 
    function() 
      if wifi.sta.status() == STAMODE.STATION_GOT_IP then 
        tmr.stop(1)
        print("Station: connected! IP: " .. wifi.sta.getip())
        tmr.alarm(0, 60000, 1, function() sendData() end )
      else
      if tmr.now() - time > timeout then
        tmr.stop(1)
        print("Timeout!")
        if wifi.sta.status() == STAMODE.STATION_IDLE
          then print("Station: idling") end
        if wifi.sta.status() == STAMODE.STATION_CONNECTING
          then print("Station: connecting") end
        if wifi.sta.status() == STAMODE.STATION_WRONG_PASSWORD
          then print("Station: wrong password") end
        if wifi.sta.status() == STAMODE.STATION_NO_AP_FOUND
          then print("Station: AP not found") end
        if wifi.sta.status() == STAMODE.STATION_CONNECT_FAIL
          then print("Station: connection failed") end
      end
    end 
  end)
end

--- Get temp
function getTemp()
  local r = adc.read(0)
  local c = r * 285 / 1024
  return c
end

--- Get temp and send data to thingspeak.com
function sendData()
  local t = getTemp()
    
  print("Temp:"..t .." C\n")
    
  -- conection to thingspeak.com
  print("Sending data to thingspeak.com")
  conn=net.createConnection(net.TCP, 0) 
  conn:on("receive", function(conn, payload) print(payload) end)
    
  -- api.thingspeak.com 184.106.153.149
  conn:connect(80,'184.106.153.149') 
  conn:send("GET /update?key=YOUR_API_KEY&field1="..t.." HTTP/1.1\r\n") 
  conn:send("Host: api.thingspeak.com\r\n") 
  conn:send("Accept: */*\r\n") 
  conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
  conn:send("\r\n")
  conn:on("sent",function(conn)
    print("Closing connection")
    conn:close()
  end)
  conn:on("disconnection", function(conn)
    print("Got disconnection...")
  end)
end


--- Main
print("Setting up Wi-Fi connection..")
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID, PASSWORD)
connect(TIMEOUT)
