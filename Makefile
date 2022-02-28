DOTFILE  := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
EXCLUDES := .DS_Store .git
TARGETS  := $(wildcard .??*)
DOTFILES := $(filter-out $(EXCLUDES), $(TARGETS))
POETRY_HOME := ${HOME}/.core/poetry
ZSH_CUSTOM := ${HOME}/.core/zsh
SCRIPTS_DIR := dot_core/scripts

.PHONY: all
all: install deploy

.PHONY: install
install: xcode brew-core nvm-init oh-my-zsh poetry-init crontab-ui brew-install-all

.PHONY: deploy
deploy:
	chezmoi code-extensions macos-defaults


.PHONY: xcode
xcode: ## Install xcode unix tools
	@echo "Installing xcode cli tools";
	xcode-select --install || True

# Homebrew
.PHONY: brew-install-all
brew-install-all: brew-init
	eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	brew bundle --file=dot_core/brew/Brewfile

.PHONY: brew-core
brew-core: brew-init
	eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	brew install python@3.9 node nvm chezmoi pyenv pyenv-virtualenv; \
	brew postinstall node; \
	brew link node; \

.PHONY: brew-init
brew-init: ## Initialize homebrew
	if [[ ! -f "/usr/local/bin/brew" ]]; then \
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; \
	fi

.PHONY: nvm-init
nvm-init: ## Initialize nvm
	source $(HOME)/.nvm/nvm.sh ;\
	nvm install 17.6;\
	nvm alias default 17.6;\


.PHONY: oh-my-zsh
oh-my-zsh:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

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
crontab-ui: nvm-init
	npm install -g crontab-ui

.PHONY: chezmoi
chezmoi:
	/opt/homebrew/bin/chezmoi init --apply

.PHONY: code-extensions
code-extensions:
	chmod +x ${SCRIPTS_DIR}/executable_install-vscode-extensions.sh
	$(SCRIPTS_DIR)/executable_install-vscode-extensions.sh

.PHONY: macos-defaults
macos-defaults:
	chmod +x ${SCRIPTS_DIR}/dot_macos
	${SCRIPTS_DIR}/dot_macos
