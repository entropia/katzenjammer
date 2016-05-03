BUTTON = 1 -- GPIO 4. NodeMCUs pin mapping ist broken
PIN1 = 5
PIN2 = 6
PIN3 = 7

r = 0
g = 0
b = 0

rainbow = 0

sound = 0
soundname = nil

function gpio_init()
  gpio.trig(PIN1, "both", card_callback)
  gpio.mode(PIN1, gpio.INT, gpio.PULLUP)

  gpio.trig(PIN2, "both", card_callback)
  gpio.mode(PIN2, gpio.INT, gpio.PULLUP)

  gpio.trig(PIN3, "both", card_callback)
  gpio.mode(PIN3, gpio.INT, gpio.PULLUP)
end

function button_init ()
  gpio.trig(BUTTON, "down", button_callback)
  gpio.mode(BUTTON, gpio.INT)
end

function rimshot (command)
  socket = net.createConnection(net.UDP, 0)
  socket:connect(23421, "192.168.24.164") 
  socket:send((command and command or "rimshot") .. "\n")
  socket:close()
end

function button_callback (level)
  gpio.mode(BUTTON, gpio.INPUT) -- disable interrupt
  tmr.alarm(0, 300, tmr.ALARM_SINGLE, button_init)
  if level == 0 then

    rimshot(soundname)
  end
end

function rainbow ()
  r = math.random(0,1)*255
  g = math.random(0,1)*255
  b = math.random(0,1)*255

  leds_grb = string.char(g,r,b, g,r,b)
  ws2812.write(4, leds_grb)
end


function card_callback (level)
  gpio.mode(PIN1, gpio.INPUT) -- disable interrupt
  gpio.mode(PIN2, gpio.INPUT) -- disable interrupt
  gpio.mode(PIN3, gpio.INPUT) -- disable interrupt

  print ("interrupt!")
  tmr.alarm(0, 500, 0, button_init)

  g = gpio.read(PIN1)
  r = gpio.read(PIN2)
  b = gpio.read(PIN3)

  sound = r*4 + g*2 + b 
  sound = sound - 1

  if sound == 6 then sound = nil end  
  print (sound)  

  soundname = json[tostring(sound)]
  print (soundname)

  if (soundname == '$random') then
    print ("random11!!!")
    tmr.alarm(1, 500, 1, rainbow)
  else
    tmr.stop(1)
    leds_grb = string.char(g*255,r*255,b*255, g*255,r*255,b*255)
    ws2812.write(4, leds_grb)
  end
  button_init()
end



function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end) 
  return fields
end



json = nil
available = {}
function update_config ()
  print ("start request")
  http.get('http://192.168.23.42/storage/ENTROPIA/configkadse.txt', nil, function(code, _data)
    if (code >= 0) then
      json = cjson.decode(_data)
    end
  end)

  -- http.get('http://192.168.23.42/storage/ENTROPIA/sounds.txt', nil, function(code, _data)
    -- if (code >= 0) then
      -- available = _data:split('\n')
    -- end
  -- end)
  -- print (available[math.random(0,#available)])

end

gpio_init()
button_init()
tmr.alarm(5, 10000, 1, update_config)
