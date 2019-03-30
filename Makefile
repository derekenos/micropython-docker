
SHELL := /bin/bash

error:
	echo "type make<TAB><TAB> to see available targets"
	exit 1


erase:
	@docker-compose run micropython-docker erase


deploy:
	@docker-compose run micropython-docker deploy


repl:
	@docker-compose run --entrypoint /bin/bash micropython-docker -l scripts/repl


shell:
	@docker-compose run --entrypoint /bin/bash micropython-docker


setup-pyboard:
	@docker-compose run --entrypoint /bin/bash micropython-docker -l scripts/setup-pyboard
