#!/bin/zsh

set -e # Exit immediately if a command exits with a non-zero status.

# first thing is check that connecting to github with ssh works
# if it doesn't, then we need to exit
function github-authenticated() {
    # Attempt to ssh to GitHub
    ssh -T git@github.com &>/dev/null
    RET=$?
    if [[ $RET == 1 ]]; then
        # user is authenticated, but fails to open a shell with GitHub
        return 0
    elif [[ $RET == 255 ]]; then
        # user is not authenticated
        return 1
    else
        echo "unknown exit code in attempt to ssh into git@github.com"
    fi
    return 2
}

if [[ $CI == 1 ]]; then
    echo 'CI detected, skipping github-authenticated check'
else
    if github-authenticated; then
        echo 'github-authenticated check passed'
    else
        echo 'github-authenticated check failed'
        exit 1
    fi
fi

# proceed with core setup
# Install xcode
if ! xcode-select -p >/dev/null; then
    echo "[localenv] Installing xcode"
    xcode-select --install
else
    echo "[localenv] xcode already installed -> skipped"
fi

# Installing Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "[localenv] Installing brew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "[localenv] brew is already installed -> skipped"
fi

# Installing go-task
if ! brew list --formula go-task >/dev/null 2>&1; then
    echo "[localenv] Installing go-task"
    brew install go-task/tap/go-task
else
    echo "[localenv] go-task is already installed with brew -> skipped"
fi

# Installing go-task
if ! brew list --formula chezmoi >/dev/null 2>&1; then
    echo "[localenv] Installing chezmoi"
    brew install chezmoi
else
    echo "[localenv] chezmoi is already installed with brew -> skipped"
fi

# init repo, use ssh if local machine. In case CI is set, we don't want to use ssh
chezmoi_init_args=(
    sbarrios93
)

if [[ $CI != 1]]; then
    echo "[localenv] localenv detected, adding ssh flag"
    chezmoi_init_args+=(--ssh)
else
    echo "[localenv] CI detected, skipping ssh flag"
fi

chezmoi init "${chezmoi_init_args[@]}"
