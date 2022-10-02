# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH=$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH

# Dropbox
export drive="/Users/seba/Dropbox"

# app development fall 2022
export APPDEV="$drive/MBA/Fall 2022/app-development"

# poetry
export PATH="$core/poetry/bin:$PATH"

# Machine Learning Folder
export ml="$drive/ML/"

# MBA Folder
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
export custompaths=$core/zsh/_paths.zsh

# for openblas
export LDFLAGS="-L/opt/homebrew/opt/openblas/lib -L/opt/homebrew/opt/lapack/lib ${LDFLAGS}"
# fix numpy/scipy build issues
export OPENBLAS=$(/opt/homebrew/bin/brew --prefix openblas)
export CFLAGS="-falign-functions=8 ${CFLAGS}"
export CPPFLAGS="-I/opt/homebrew/opt/lapack/include -I/opt/homebrew/opt/openblas/include ${CPPFLAGS}"

# Go Paths
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
# export GOROOT=$(brew --prefix)/opt/go/libexec
export PATH="$GOBIN:$PATH"
# custom scripts
export scripts="$core/scripts"


# Init rbenv
eval "$(rbenv init - zsh)"

# pypher project
export pypher=$GOPATH/src/github.com/sbarrios93/pypher
