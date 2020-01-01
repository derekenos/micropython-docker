DC_FILE=docker-compose.yml
DOCKER_COMPOSE=docker-compose -f $(DC_FILE)


error:
	echo "Type make<TAB><TAB> to see the available targets"


shell:
	$(DOCKER_COMPOSE) run --rm app /bin/bash


erase-esp32-flash:
	@$(DOCKER_COMPOSE) run --rm app esptool.py erase_flash


flash-esp32-firmware:
	@$(DOCKER_COMPOSE) run --rm app /bin/bash -l scripts/flash-esp32-firmware


configure-device:
	@$(DOCKER_COMPOSE) run --rm app /bin/bash -l scripts/configure-device


repl:
	@$(DOCKER_COMPOSE) run --rm app /bin/bash -l scripts/repl
