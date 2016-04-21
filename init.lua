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



function trigger_effect ()
  g = gpio.read(PIN1) * 255
  r = gpio.read(PIN2) * 255
  b = gpio.read(PIN3) * 255
  leds_grb = string.char(g,r,b, g,r,b)
  ws2812.write(2, leds_grb)
  socket = net.createConnection(net.UDP, 0)
  socket:connect(23421, "192.168.23.42")

  samples = {
    [0xFF0000] = "haha";
    [0x00FF00] = "fail";
    [0x0000FF] = "haha";
  }
  sample = samples[r*0x10000 + g*0x100 + b]
  socket:send((sample and sample or "rimshot") .. "\n")

  socket:close()
end

function button_callback (level)
  gpio.mode(BUTTON, gpio.INPUT) -- disable interrupt
  tmr.alarm(0, 300, tmr.ALARM_SINGLE, button_init)
  if level == 0 then
    node.task.post(trigger_effect)
  end
end

button_init()
