#!/usr/bin/env zsh

set -e # Exit immediately if a command exits with a non-zero status.

DOTFILES_DIR="/usr/local/share/dotfiles"

# colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 31)
NC=$(tput sgr0)

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
    echo 'CI detected'
    echo "Skip github authentication check"
    echo "Skip terminal full disk access check"
else
    # run github authentication check
    echo "${BLUE}[localenv] Checking github authentication${NC}"
    if github-authenticated; then
        echo "${GREEN}github-authenticated check passed${NC}"
    else
        echo "${RED}github-authenticated check failed${NC}"
        exit 1
    fi
    # Check whether Terminal has Full Disk Access
    echo "${BLUE}[localenv] Checking terminal full disk access${NC}"
    if [[ ! -r "/Library/Application Support/com.apple.TCC/TCC.db" ]]; then
        echo "${RED}Full Disk Access must be granted to Terminal in order to run this script.${NC}"
        open "x-apple.systempreferences:com.apple.preference.security?Privacy"
        exit
    fi
fi

# proceed with core setup
# Install xcode
if ! xcode-select -p >/dev/null; then
    echo "${BLUE}[localenv] Installing xcode${NC}"
    xcode-select --install
else
    echo "${BLUE}[localenv] xcode already installed -> skipped${NC}"
fi

# Installing Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "${BLUE}[localenv] Installing brew${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

chezmoi init "${chezmoi_init_args[@]}"

# cd into dotfiles directory on local machine
# because I set up the chezmoi dir in the home subfolder, we need to cd into the parent folder
cd "$(chezmoi source-path)/.."
echo "${BLUE}[localenv] cd into dotfiles directory${NC}"

# execute taskfile.yaml
echo "Run Taskfile..."
task init
