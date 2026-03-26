.DEFAULT_GOAL := help

PLAYBOOK := main.yml
INVENTORY := localhost ansible_python_interpreter=$$(asdf which python3),
ANSIBLE := asdf exec ansible-playbook -i "$(INVENTORY)"
GALAXY := asdf exec ansible-galaxy collection install --upgrade -r collections/requirements.yml
TAGS ?=
EXTRA_ARGS ?=

.PHONY: help bootstrap collections install run check syntax nvim_pack shells dot_dirs ssh npm homebrew macos nvim nvim_files hammerspoon macos_navigation fonts dictionaries docker java cli_tools alfred nvim_lsp

help:
	@printf '%s\n' \
		'Common targets:' \
		'  make bootstrap         Run the bootstrap script' \
		'  make collections       Install Ansible collections' \
		'  make install           Alias for collections' \
		'  make run               Run the full playbook' \
		'  make check             Dry-run the playbook (--check --diff)' \
		'  make syntax            Run ansible-playbook syntax check' \
		'  make nvim-pack         Run Neovim vim.pack updates headlessly' \
		'  make <tag>             Run only that tagged role (for example: make nvim)' \
		'' \
		'Overrides:' \
		'  TAGS=<tags>            Comma-separated tags for make run/check' \
		'  EXTRA_ARGS="<args>"    Extra args forwarded to ansible-playbook'

bootstrap:
	./bin/bootstrap $(if $(TAGS),--tags "$(TAGS)") $(EXTRA_ARGS)

collections install:
	$(GALAXY)

run:
	$(ANSIBLE) $(PLAYBOOK) $(if $(TAGS),--tags "$(TAGS)") $(EXTRA_ARGS)

check:
	$(ANSIBLE) $(PLAYBOOK) --check --diff $(if $(TAGS),--tags "$(TAGS)") $(EXTRA_ARGS)

syntax:
	$(ANSIBLE) $(PLAYBOOK) --syntax-check $(EXTRA_ARGS)

nvim-pack:
	nvim --headless "+lua vim.pack.update(nil, { force = true })" +qa

shells dot_dirs ssh npm homebrew macos nvim nvim_files hammerspoon macos_navigation fonts dictionaries docker java cli_tools alfred nvim_lsp:
	$(MAKE) run TAGS=$@ EXTRA_ARGS="$(EXTRA_ARGS)"
