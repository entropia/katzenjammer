BUTTON = 1 -- GPIO 4. NodeMCUs pin mapping ist borken
PIN1 = 5
PIN2 = 6
PIN3 = 7

function button_init ()
  gpio.trig(BUTTON, "down", button_callback)
  gpio.mode(BUTTON, gpio.INT)
  
  gpio.mode(PIN1, gpio.INPUT, gpio.PULLUP)

  gpio.mode(PIN2, gpio.INPUT, gpio.PULLUP)

  gpio.mode(PIN3, gpio.INPUT, gpio.PULLUP)
end



function rimshot ()
  g = gpio.read(PIN1) * 255
  r = gpio.read(PIN2) * 255
  b = gpio.read(PIN3) * 255
  leds_grb = string.char(g,r,b, g,r,b) 
  ws2812.write(2, leds_grb)
  socket = net.createConnection(net.UDP, 0)
  socket:connect(23421, "192.168.23.42")
  
  if (r == 255 and g == 0 and b == 0) then 
    socket:send("haha\n")

  elseif (r == 0 and g == 255 and b == 0) then
    socket:send("fail\n")

  elseif (r == 0 and g == 0 and b == 255) then
    socket:send("shutdown\n")

  else
    socket:send("rimshot\n")
  end

  socket:close()
end

function button_callback (level)
  gpio.mode(BUTTON, gpio.INPUT) -- disable interrupt
  tmr.alarm(0, 300, tmr.ALARM_SINGLE, button_init)
  if level == 0 then
    node.task.post(rimshot)
  end
end

button_init()
