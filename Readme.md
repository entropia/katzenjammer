Katzenjammer
============

Trigger sound effects at Entropia.

Preparation of the ESP8266
--------------------------
1. Flash the NodeMCU firmware, e.g. using [`esptool`](https://github.com/themadinventor/esptool):

   ```
   esptool.py write_flash 0x00000 your-firmware-file.bin
   ```

1. Configure WiFi using the Lua interpreter interactively:

   ```lua
   wifi.setmode(wifi.STATION)
   wifi.sta.config('example-ssid', '', 1)
   ```

1. Upload the Lua code, e.g. using [`luatool`](https://github.com/4refr0nt/luatool):

   ```
   luatool.py -b 115200 -r -f init.lua
   ```

1. ???
1. Profit!
