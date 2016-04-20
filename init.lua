BUTTON = 1 -- GPIO 4. NodeMCUs pin mapping ist borken

wifi.setmode(wifi.STATION)
wifi.sta.config('example-ssid', '', 1)

function button_init ()
  gpio.trig(BUTTON, "down", button_callback)
  gpio.mode(BUTTON, gpio.INT)
end


function rimshot ()
  socket = net.createConnection(net.UDP, 0)
  socket:connect(23421, "192.168.23.42")
  socket:send("rimshot\n")
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
