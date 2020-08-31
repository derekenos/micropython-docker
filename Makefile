
error:
	echo "Type make<TAB><TAB> to see the available targets"


shell:
	docker-compose run --rm app /bin/bash


erase-esp32-flash:
	@docker-compose run --rm app /bin/bash -l scripts/erase-esp32-flash


flash-esp32-firmware:
	@docker-compose run --rm app /bin/bash -l scripts/flash-esp32-firmware


compile-and-flash-esp32-firmware:
	@docker-compose run --rm app /bin/bash -l scripts/compile-and-flash-esp32-firmware


configure-device:
	@docker-compose run --rm app /bin/bash -l scripts/configure-device


repl:
	@docker-compose run --rm app /bin/bash -l scripts/repl
