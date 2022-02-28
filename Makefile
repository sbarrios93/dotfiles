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
install: brew oh-my-zsh poetry-init crontab-ui

.PHONY: deploy
deploy:
	chezmoi code-extensions

# Homebrew
.PHONY: brew-init
brew-init:
	xcode-select --install 2>/dev/null || :
	${SCRIPTS_DIR}/brew_init

.PHONY: brew
brew: brew-init
	brew bundle --file=dot_core/brew/Brewfile


.PHONY: oh-my-zsh
oh-my-zsh:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# poetry
.PHONY: poetry-init
poetry-init:
	curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} python3 -
# append line if it does not exist
	mkdir -p ${ZSH_CUSTOM}/plugins/poetry
	${HOME}/.core/poetry/bin/poetry completions zsh > ${ZSH_CUSTOM}/plugins/poetry/_poetry

.PHONY: poetry-remove
poetry-remove:
	curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} POETRY_UNINSTALL=1 python3 -

.PHONY: crontab-ui
crontab-ui:
	npm install -g crontab-ui

.PHONY: chezmoi
chezmoi:
	chezmoi init --apply

.PHONY: code-extensions
code-extensions:
	chmod +x ${SCRIPTS_DIR}/executable_install-vscode-extensions.sh
	$(SCRIPTS_DIR)/executable_install-vscode-extensions.sh
