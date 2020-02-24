Docker environment to flash, configure, and interact with boards running Micropython.

Tested with:

- ESP32-DevKitC
- ESP32-PICO-KIT



# Usage

Everything is executed using `make` because it keeps the interface simple.

Make has 2 sections: related to device attached via USB, and related to device attached to
SSH jumpstation. 

## Local Device

All targets assume that the ESP32 device is attached via USB to the `DEVICE_PORT` defined
in the `Dockerfile` (default: `/dev/ttyUSB0`).

If you want to run it without this device attached, use: `docker-compose -f
docker-compose-no-device.yml ...`, or DC_FILE='docker-compose-no-device.yml' parameter

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

## SSH Jumpstation

Sometimes is not possible to connect ESP32 to your laptop, because there is problem with
USB drivers (eg. on some MacOses). In such case, it's convenient to use SSH jumpstation.
Eg old laptop or RaspberryPI/BananaPi plugged to your network. 

There are following targets:

* `ssh_flash_esp32` - flash esp32 connected to ssh jumpstation (eg. raspberry pi)"
* `ssh_install_webrepl` - install webrepl on esp32 (via jumpstation) "
* `ssh_all` - flash and install webrepl via ssh jumpstation"
* `ssl_clean_ssh` - clean/reset information about instalation status 
* `ssh_reinstall_all` - flash and install webrepl once again

### Variables
You should modify at least `SSH_USER`, `SSH_HOST`, `WEBREPL_PASS`, `WIFI_SSID` and
`WIFI_PASS`. You can use them in make commandline, or write to `private.mk` file, which is
in .gitignore, so secrets won't land in git repository. 

Available parameters:
* `SSH_USER` - username on your SSH jumpstation,
* `SSH_HOST` - address of your SSH jumpstation,
* `SSH_KEY` - key to your SSH jumpstation, default is ~/.ssh/id_rsa (and usually default is ok)
* `WEBREPL_PASS` - password to webrepl in your ESP32. Don't forget to modify it, otherwise
            your installation will be insecure
* `WIFI_SSID` and `WIFI_PASS` - your esp32 will try to connect to wifi using these
            credentials. 
* `PI_PREFIX` - prefix of `ampy` and `esptool.py` commands. If you have everything in
            $PATH, just leave it blank. If you have it in virtualenv, give
            `PI_PREFIX=/path/to/venv/bin/`
* `PI_DEVICE` - device on ssh jumpstation side. Default is `/dev/ttyUSB`
* `PI_AMPY_DELAY` - delay before calling ampy command. Default is 5. Make it bigger if you
            ecounter strange replies from your esp32 device
* `DC_FILE` - you probably want to use `docker-compose-no-device.yml` instead of default,
            when using SSH jumpstation. 
