DOTFILE  := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
EXCLUDES := .DS_Store .git
TARGETS  := $(wildcard .??*)
DOTFILES := $(filter-out $(EXCLUDES), $(TARGETS))
POETRY_HOME := ${HOME}/.core/poetry
ZSH_CUSTOM := ${HOME}/.core/zsh
SCRIPTS_DIR := dot_core/scripts
NVM_DIR := $(HOME)/.nvm
export XDG_CONFIG_HOME := $(HOME)/.config


.PHONY: all
all: install deploy python-envs

.PHONY: install
install: terminal-permissions xcode brew-tap brew-core brew-formulas nvm-init oh-my-zsh poetry-init brew-casks crontab-ui brew-mas

.PHONY: deploy
deploy: terminal-permissions sudo chezmoi code-extensions macos-defaults crontab-restore

.PHONY: terminal-permissions
terminal-permissions: # Check whether Terminal has Full Disk Access
	chmod +x dot_core/scripts/executable_terminal-permissions;\
	dot_core/scripts/executable_terminal-permissions

.PHONY: sudo
sudo:
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

.PHONY: xcode
xcode: ## Install xcode unix tools
	@echo "Installing xcode cli tools";
	xcode-select --install || True

# Homebrew
.PHONY: brew-core
brew-core: brew-init
	@echo "Installing Homebrew core";
	eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	brew install python@3.9 cmake chezmoi pyenv pyenv-virtualenv

.PHONY: brew-tap
brew-tap:
	@echo "Tapping homebrew taps"
	eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	cat dot_core/brew/Brewfile |  grep '^[tap]' | grep -o '".*"' | tr -d '"' | tr '\n' '\0' | xargs -n 1 -0 brew tap

.PHONY: brew-formulas
brew-formulas:
	@echo "Installing homebrew formulas"
	eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	cat dot_core/brew/Brewfile |  grep '^[brew]' | grep -o '".*"' | tr -d '"' | tr '\n' '\0' | xargs -n 1 -0 brew install

.PHONY: brew-casks
brew-casks:
	@echo "Installing homebrew casks"
	eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	cat dot_core/brew/Brewfile |  grep '^[cask]' | grep -o '".*"' | tr -d '"' | tr '\n' '\0' | xargs -n 1 -0 brew install --cask


.PHONY: brew-init
brew-init: ## Initialize homebrew
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";

.PHONY: brew-mas
brew-mas: ## Install Mac App Store apps
	@echo "Installing Mac App Store apps"
	eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	cat dot_core/brew/Brewfile |  grep '^[mas]' | grep -o '\d*$' | tr '\n' '\0' | xargs -n 1 -0 /opt/homebrew/bin/mas install

.PHONY: nvm-init
nvm-init: ## Initialize nvm
	if ! [ -d $(NVM_DIR)/.git ]; then git clone https://github.com/creationix/nvm.git $(NVM_DIR); fi
	. $(NVM_DIR)/nvm.sh;
	source $(HOME)/.nvm/nvm.sh ;\
	nvm install 17.6;\
	nvm alias default 17.6;\


.PHONY: oh-my-zsh
oh-my-zsh:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

.PHONY: python-envs
python-envs: pyenv-env-base pyenv-env-jupyter

# poetry
.PHONY: poetry-init
poetry-init:
	curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} /opt/homebrew/bin/python3 -
# append line if it does not exist
	mkdir -p ${ZSH_CUSTOM}/plugins/poetry
	${HOME}/.core/poetry/bin/poetry completions zsh > ${ZSH_CUSTOM}/plugins/poetry/_poetry

.PHONY: poetry-remove
poetry-remove:
	curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} POETRY_UNINSTALL=1 python3 -

.PHONY: crontab-ui
crontab-ui:
	source $(HOME)/.nvm/nvm.sh ;\
	npm install -g crontab-ui

.PHONY: chezmoi
chezmoi:
	/opt/homebrew/bin/chezmoi init --apply

.PHONY: code-extensions
code-extensions:
	chmod +x ${SCRIPTS_DIR}/executable_install-vscode-extensions.sh
	mkdir -p ${HOME}/.vscode/extensions
	export PATH="$$PATH:/opt/homebrew/bin"; \
	$(SCRIPTS_DIR)/executable_install-vscode-extensions.sh

.PHONY: macos-defaults
macos-defaults:
	chmod +x ${SCRIPTS_DIR}/dot_macos
	${SCRIPTS_DIR}/dot_macos

.PHONY: crontab-restore
crontab-restore:
	crontab < ${HOME}/.core/scripts/crontab.save

.PHONY: pyenv-env-base
pyenv-env-base:
	@echo "Installing pyenv base env"
	pyenv install 3.9.10;\
	pyenv virtualenv 3.9.10 base;\
	pyenv global base;\
	pyenv rehash;\

.PHONY: pyenv-env-jupyter
pyenv-env-jupyter:
	@echo "Installing pyenv jupyter env"
	eval "$$(pyenv init -)"; \
	eval "$$(pyenv virtualenv init -)"; \
	pyenv virtualenv 3.9.10 jupyter;\
	pyenv rehash;\
	pyenv shell jupyter;\
	pip install jupyterlab black jupyter_contrib_nbextensions jupyter_nbextensions_configurator ipykernel;\
