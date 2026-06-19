.PHONY: install uninstall test lint unit check help

help:
	@echo "make install    — install the 'aito' CLI onto your PATH (PREFIX=/usr/local for system-wide)"
	@echo "make uninstall  — remove the 'aito' CLI (per-project config files are left untouched)"
	@echo "make lint       — shellcheck all scripts"
	@echo "make unit       — run the bats test suite"
	@echo "make test       — lint + unit (full local suite)"
	@echo "make check      — alias for test"

SCRIPTS = bin/aito install.sh lib/*.sh lib/profiles/*.sh lib/components/*.sh

# Pass PREFIX through to install.sh only when explicitly provided, so the script's
# own default (~/.local) is preserved otherwise. e.g. make install PREFIX=/usr/local
install:
	$(if $(PREFIX),PREFIX=$(PREFIX)) bash install.sh

uninstall:
	$(if $(PREFIX),PREFIX=$(PREFIX)) bash install.sh --uninstall

lint:
	shellcheck -x $(SCRIPTS)

unit:
	bats tests/

test:
	bash tests/run.sh

check: test
