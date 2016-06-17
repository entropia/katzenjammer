BUTTON = 1 -- GPIO 4. NodeMCUs pin mapping ist broken
PIN1 = 5
PIN2 = 6
PIN3 = 7

sound = 0
soundname = nil
host = {
  address = "192.168.23.42";
  port = 23421
}
timers = {
  debounce = 0;
  rainbow = 1;
  config_update = 2;
}

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
  socket:connect(host.port, host.address)
  command = (command and command or "rimshot")
  print("will send command: " .. command)
  socket:send(command .. "\n")
  socket:close()
end

function button_callback (level)
  print("button pressed")
  gpio.mode(BUTTON, gpio.INPUT) -- disable interrupt
  tmr.alarm(timers.debounce, 300, tmr.ALARM_SINGLE, button_init)
  if level == 0 then
    rimshot(soundname)
  end
end

function rainbow ()
  r = math.random(0,1)*255
  g = math.random(0,1)*255
  b = math.random(0,1)*255

  leds_grb = string.char(g,r,b, g,r,b)
  ws2812.write(leds_grb)
end


function card_callback (level)
  gpio.mode(PIN1, gpio.INPUT) -- disable interrupt
  gpio.mode(PIN2, gpio.INPUT) -- disable interrupt
  gpio.mode(PIN3, gpio.INPUT) -- disable interrupt

  print ("interrupt!")

  g = gpio.read(PIN1)
  r = gpio.read(PIN2)
  b = gpio.read(PIN3)

  sound = r*4 + g*2 + b
  sound = sound - 1

  if sound == 6 then sound = nil end
  print (sound)

  soundname = nil
  if json then
    soundname = json[tostring(sound)]
  end
  print (soundname)

  if (soundname == '$random') then
    tmr.alarm(timers.rainbow, 500, tmr.ALARM_AUTO, rainbow)
  else
    tmr.stop(timers.rainbow)
    leds_grb = string.char(g*255,r*255,b*255, g*255,r*255,b*255)
    ws2812.write(leds_grb)
  end
  gpio_init()
end

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

json = nil
function update_config ()
  print ("start request")
  http.get('http://' .. host.address .. '/storage/ENTROPIA/configkadse.txt', nil, function(code, _data)
    if (code >= 0) then
      json = cjson.decode(_data)
    end
  end)
end

gpio_init()
button_init()
ws2812.init()
tmr.alarm(timers.config_update, 120000, 1, update_config)
