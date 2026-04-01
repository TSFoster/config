.DEFAULT_GOAL := help

PLAYBOOK := main.yml
INVENTORY := localhost ansible_python_interpreter=$$(command -v python3),
ANSIBLE := ansible-playbook -i "$(INVENTORY)"
GALAXY := ansible-galaxy collection install --upgrade -r collections/requirements.yml
LINT := ansible-lint
TAGS ?=
EXTRA_ARGS ?=

.PHONY: help bootstrap collections install run check syntax lint lint-fix nvim_pack_list nvim_pack_update nvim_pack_uninstall shells dotfiles ssh asdf dev_tools macos nvim nvim_files hammerspoon macos_navigation fonts dictionaries macos_apps alfred nvim_lsp

help:
	@printf '%s\n' \
		'Common targets:' \
		'  make bootstrap         Run the bootstrap script' \
		'  make collections       Install Ansible collections' \
		'  make install           Alias for collections' \
		'  make run               Run the full playbook' \
		'  make check             Dry-run the playbook (--check --diff)' \
		'  make syntax            Run ansible-playbook syntax check' \
		'  make lint              Run ansible-lint' \
		'  make lint-fix          Run ansible-lint --fix' \
		'  make nvim_pack_list    List vim.pack plugin names from ~/.config/nvim' \
		'  make nvim_pack_update  Run Neovim vim.pack updates through Ansible' \
		'  make nvim_pack_uninstall PACKAGES=<name1,name2>' \
		'                         Remove one or more vim.pack packages' \
		'  make <tag>             Run only that tagged role (for example: make nvim)' \
		'' \
		'Overrides:' \
		'  TAGS=<tags>            Comma-separated tags for make run/check' \
		'  PACKAGES=<csv>         Comma-separated vim.pack packages to update/remove' \
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

lint:
	$(LINT) $(EXTRA_ARGS)

lint-fix:
	$(LINT) --fix $(EXTRA_ARGS)

nvim_pack_list:
	$(ANSIBLE) $(PLAYBOOK) --tags nvim_pack_list $(EXTRA_ARGS)

nvim_pack_update:
	$(ANSIBLE) $(PLAYBOOK) --tags nvim_pack_update $(if $(strip $(PACKAGES)),-e 'packages_to_update=$(PACKAGES)') $(EXTRA_ARGS)

nvim_pack_uninstall:
	@test -n "$(strip $(PACKAGES))" || { printf '%s\n' "Set PACKAGES=<name1,name2>"; exit 1; }
	$(ANSIBLE) $(PLAYBOOK) --tags nvim_pack_uninstall -e 'packages_to_uninstall=$(PACKAGES)' $(EXTRA_ARGS)

shells dotfiles ssh asdf dev_tools macos nvim nvim_files hammerspoon macos_navigation fonts dictionaries macos_apps alfred nvim_lsp:
	$(MAKE) run TAGS=$@ EXTRA_ARGS="$(EXTRA_ARGS)"
