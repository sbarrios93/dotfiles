#!/usr/bin/env zsh

set -eu # Exit immediately if a command exits with a non-zero status.

# set -x # debug

set -o pipefail # Return value of a pipeline as the value of the last command to
# exit with a non-zero status, or zero if all commands in the
# pipeline exit successfully.

#set os
OS="$(uname)"
CI=${CI:-'0'}

# colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 31)
NC=$(tput sgr0)

NVM_DIR="$HOME/.nvm"

SKIP_INSTALL_GITHUB="skip-install-github-actions.yaml"

# install required dependencies if running linux
if [[ "$OS" == "Linux" ]]; then
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update
    sudo apt-get install git zsh -y
    sudo apt install \
        build-essential \
        curl \
        libbz2-dev \
        libffi-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        python-openssl \
        libssl-dev \
        libxml2-dev \
        libxmlsec1-dev \
        llvm \
        make \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev -y
fi

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
        return 2
    fi
    return 0
}

if [[ $CI == 1 ]]; then
    echo 'CI detected'
    echo "Skip github authentication check"
    echo "Skip terminal full disk access check"
    # because we want a fast CI build, there's a file as yaml in the main directory for instructions of things to skip, I want to read that, and I need to use a yaml parser
    # check if there is a file called skip-install-github-actions.yaml
    if [[ -f $SKIP_INSTALL_GITHUB ]]; then
        echo "skip-install-github-actions.yaml found. Installing shyaml to parse the file"
        pip3 install shyaml # for parsing .yaml files
    fi
else
    # run github authentication check
    echo "${BLUE}[localenv] Checking github authentication${NC}"
    if github-authenticated; then
        echo "${GREEN}github-authenticated check passed${NC}"
    else
        echo "${RED}github-authenticated check failed${NC}"
        exit 1
    fi
    if [[ "$OS" == "Darwin" ]]; then
        # Check whether Terminal has Full Disk Access
        echo "${BLUE}[localenv] Checking terminal full disk access${NC}"
        if [[ ! -r "/Library/Application Support/com.apple.TCC/TCC.db" ]]; then
            echo "${RED}Full Disk Access must be granted to Terminal in order to run this script.${NC}"
            open "x-apple.systempreferences:com.apple.preference.security?Privacy"
            exit
        fi
        if ! xcode-select -p >/dev/null; then
            echo "${BLUE}[localenv] Installing xcode${NC}"
            xcode-select --install
        else
            echo "${BLUE}[localenv] xcode already installed -> skipped${NC}"
        fi
        softwareupdate --install-rosetta
    else
        echo "Not Darwin env"
    fi
fi

# proceed with core setup
# Install xcode

# Installing Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "${BLUE}[localenv] Installing brew${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>$HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "${BLUE}[localenv] brew is already installed -> skipped${NC}"
fi

# Installing go-task
if ! brew list --formula go-task >/dev/null 2>&1; then
    echo "${BLUE}[localenv] Installing go-task${NC}"
    brew install go-task/tap/go-task
else
    echo "${BLUE}[localenv] go-task is already installed with brew -> skipped${NC}"
fi

# Installing go-task
if ! brew list --formula chezmoi >/dev/null 2>&1; then
    echo "${BLUE}[localenv] Installing chezmoi${NC}"
    brew install chezmoi
else
    echo "${BLUE}[localenv] chezmoi is already installed with brew -> skipped${NC}"
fi

# installing nvm
if [[ ! -d "$NVM_DIR" ]]; then
    echo "${BLUE}[localenv] Installing nvm${NC}"
    git clone https://github.com/creationix/nvm.git $NVM_DIR
fi
source $NVM_DIR/nvm.sh
nvm install node
nvm alias default node
nvm use default
npm install -g crontab-ui

# init repo, use ssh if local machine. In case CI is set, we don't want to use ssh
chezmoi_init_args=(
    sbarrios93
)

if [[ $CI != 1 ]]; then
    echo "${BLUE}[localenv] localenv detected, adding ssh flag${NC}"
    chezmoi_init_args+=(--ssh)
else
    echo "${BLUE}[localenv] CI detected, skipping ssh flag${NC}"
fi

echo "${BLUE}[localenv] Running chezmoi init${NC}"
echo "${BLUE}[localenv] Args: ${chezmoi_init_args[@]}${NC}"
chezmoi init "${chezmoi_init_args[@]}"

# cd into dotfiles directory on local machine
# because I set up the chezmoi dir in the home subfolder, we need to cd into the parent folder
cd "$HOME/.local/share/chezmoi"
echo "${BLUE}[localenv] cd into dotfiles directory${NC}"

# execute taskfile.yaml
echo "Run Taskfile..."
task init -v
