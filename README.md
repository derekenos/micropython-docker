Docker environment to flash, configure, and interact with boards running Micropython.

Tested with:

- ESP32-DevKitC
- ESP32-PICO-KIT


## Usage

Everything is executed using `make` because it keeps the interface simple.
All targets assume that the ESP32 device is attached via USB to the `DEVICE_PORT` defined in the `Dockerfile` (default: `/dev/ttyUSB0`).

If you want to run it without this device attached, use: `docker-compose -f docker-compose-no-device.yml ...`

### Erase the Device's Flash Memory

```
make erase-esp32-flash
```


### Flash the Micropython Firmware to the Device

```
make flash-esp32-firmware
```


### Configure the Device

```
make configure-device
```

This:

1. Copies all the files in the `./filesystem` directory in the Micropython filesystem root, including:
- `boot.py` - executed on power up and attempts to connect to WiFi (for the specified `SSID` and `PASSWORD`) and starts the web repl
- `webrepl_cfg.py` - defines the webrepl password (`PASS`) configuration variable

2. Resets the device in order to execute the new `boot.py`

3. Prints the MAC address of the device in case you need to whitelist it

4. Waits for the network connection and then print the device's IP address


### Connect to the Micropython REPL

By default, this attempts to connect to the `DEVICE_PORT` specified in the `Dockerfile` using GNU Screen.
To kill a GNU Screen session, type: `ctrl-a k y`

```
make repl
```


### Shell into the Docker container

This will give you a bash prompt within the container from which you can use esptool, ampy, etc. directly.

```
make shell
```
