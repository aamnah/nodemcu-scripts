-- Get temp
function getTemp()
  local r = adc.read(0)
  local c = r * 285 / 1024
  return c
end

-- Print temp
function printTime()
  t = getTemp()
  print("Temp:".. t .." C\n")
end

-- Print temp every 3 secs
tmr.alarm(1, 3000, 1, 
  function()
    printTime()
  end
)
