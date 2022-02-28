DOTFILE  := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
EXCLUDES := .DS_Store .git
TARGETS  := $(wildcard .??*)
DOTFILES := $(filter-out $(EXCLUDES), $(TARGETS))

.PHONY: all
all: deploy install

# Homebrew

.PHONY: brew-init
brew-init:
	xcode-select --install 2>/dev/null || :
	./scripts/brew_init

.PHONY: brew
brew: # brew-init
	brew bundle --file=dot_core/brew/Brewfile

