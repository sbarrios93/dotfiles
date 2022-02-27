# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH=$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH

# CORE folder
export core=$HOME/.core

# Google  Drive
export drive="/Volumes/GoogleDrive/My Drive"

# Machine Learning Folder
export ml="$drive/ML/"

# MBA Foldere
export mba="$drive/MBA/"

# Personal Site
export site="$HOME/sebabarrios.com/"

# iCloud
export icloud="/Users/seba/Library/Mobile Documents/com~apple~CloudDocs"

# Editor
export EDITOR="nvim"

# MacPrefs Backup Path
export MACPREFS_BACKUP_DIR="$core/macprefs"

# Notes
export notes="$HOME/notes"

# Starship Config File
export STARSHIP_CONFIG="$core/starship.toml"

# avoid installing pip outside virtual env
# export PIP_REQUIRE_VIRTUALENV=true
export PATH="$HOME/.local/bin:$PATH"

export HDF5_DIR=/opt/homebrew/opt/hdf5

# target this file
export custompaths=/Users/seba/.oh-my-zsh/custom/_paths.zsh

# for openblas
export LDFLAGS="-L/opt/homebrew/opt/openblas/lib -L/opt/homebrew/opt/lapack/lib ${LDFLAGS}"
# fix numpy/scipy build issues
export OPENBLAS=$(/opt/homebrew/bin/brew --prefix openblas)
export CFLAGS="-falign-functions=8 ${CFLAGS}"
export CPPFLAGS="-I/opt/homebrew/opt/lapack/include -I/opt/homebrew/opt/openblas/include ${CPPFLAGS}"
