DC_FILE=docker-compose.yml
DOCKER_COMPOSE=docker-compose -f $(DC_FILE)
BRANCH=master

ifeq ($(FLAVOUR), pycopy)
	REPO=https://github.com/pfalcon/pycopy.git
else
	REPO=https://github.com/micropython/micropython
endif


error:
	echo "Type make<TAB><TAB> to see the available targets"


up:
	$(DOCKER_COMPOSE) up -d

build:
	$(DOCKER_COMPOSE) build --build-arg repo=$(REPO) --build-arg branch=$(BRANCH) app
	# invalidate "downloaded from docker" target
	rm -f $(LFIRMWARE_PATH)

shell: up
	$(DOCKER_COMPOSE) exec app /bin/bash


erase-esp32-flash:
	@$(DOCKER_COMPOSE) run --rm app esptool.py erase_flash


flash-esp32-firmware:
	@$(DOCKER_COMPOSE) run --rm app /bin/bash -l scripts/flash-esp32-firmware


configure-device:
	@$(DOCKER_COMPOSE) run --rm app /bin/bash -l scripts/configure-device


repl:
	@$(DOCKER_COMPOSE) run --rm app /bin/bash -l scripts/repl


# initialize device via ssh jumpstation
DOCKER_CONTAINER=`$(DOCKER_COMPOSE) ps -q app`
# firmware path in docker container
DFIRMWARE_PATH=/app/micropython/ports/esp32/build-GENERIC/firmware.bin
LFIRMWARE_PATH=.tmp/firmware.bin  # TODO: .tmp should maybe have different name
# temporary path to boot.py and webrepl_cfg.py with substituted password/etc
BOOT_PY=.tmp/boot.py
WEBREPL_CFG_PY=.tmp/webrepl_cfg.py

SSH_USER=pi
SSH_HOST=bpii
SSH_KEY=~/.ssh/id_rsa
SSH_USERHOST=$(SSH_USER)@$(SSH_HOST)
SSH_CMD=ssh -i $(SSH_KEY) $(SSH_USERHOST)

WEBREPL_PASS=foo
WIFI_SSID=wifissid
WIFI_PASS=wifikey

# if empty - then will take command from path
# other possibilities
# PI_PREFIX=/home/pi/venv/bin/
# or
# PI_PREFIX=/usr/local/bin
# 
PI_PREFIX=
PI_AMPY_CMD=$(PI_PREFIX)ampy
PI_ESPTOOL_CMD=$(PI_PREFIX)esptool.py
PI_DEVICE=/dev/ttyUSB0
PI_AMPY_DELAY=5

SSH_AMPY=$(SSH_CMD) $(PI_AMPY_CMD) -p $(PI_DEVICE) -d $(PI_AMPY_DELAY)
SSH_ESPTOOL=$(SSH_CMD) $(PI_ESPTOOL_CMD) --port $(PI_DEVICE)

# put sensitive and local variables in to private.mk, which won't be commited
-include private.mk

# do all: flash and install webrepl
ssh_all: ssh_flash_esp32 ssh_install_webrepl

ssh_reinstall_all: clean_ssh ssh_all

# get firmware from docker to here
download_esp32_firmware: $(LFIRMWARE_PATH)

ssh_minicom:
	$(SSH_CMD) -t minicom -D /dev/ttyUSB0

ssh_flash_esp32: .tmp/.flashed

clean_ssh:
	rm -rf .tmp

$(LFIRMWARE_PATH):
	make up
	mkdir -p $(shell dirname $(LFIRMWARE_PATH))
	# if you build 
	docker cp $(DOCKER_CONTAINER):$(DFIRMWARE_PATH) $(LFIRMWARE_PATH)



.tmp/.flashed: .tmp/.files_scpied
	# scp files to banana pi
	$(SSH_ESPTOOL) erase_flash
	$(SSH_ESPTOOL) write_flash -z 0x1000 /tmp/firmware.bin
	touch $@

ssh_install_webrepl: .tmp/.webrepl_cfg_installed .tmp/.boot_installed 

.tmp/.files_scpied: $(LFIRMWARE_PATH) $(BOOT_PY) $(WEBREPL_CFG_PY)
	scp -i $(SSH_KEY) $(LFIRMWARE_PATH) $(WEBREPL_CFG_PY) $(BOOT_PY) $(SSH_USERHOST):/tmp/
	touch $@


.tmp/.boot_installed: .tmp/.files_scpied .tmp/.flashed
	$(SSH_AMPY) put /tmp/boot.py 
	touch $@

.tmp/.webrepl_cfg_installed: .tmp/.files_scpied .tmp/.flashed
	$(SSH_AMPY) put /tmp/webrepl_cfg.py
	touch $@

$(BOOT_PY): scripts/boot.py.base
	cp $< $(BOOT_PY)
	sed -i s/{WIFI_SSID}/$(WIFI_SSID)/g $(BOOT_PY)
	sed -i s/{WIFI_PASS}/$(WIFI_PASS)/g $(BOOT_PY)

$(WEBREPL_CFG_PY): scripts/webrepl_cfg.py.base
	cp $< $(WEBREPL_CFG_PY)
	sed -i s/{WEBREPL_PASS}/$(WEBREPL_PASS)/g $(WEBREPL_CFG_PY)
