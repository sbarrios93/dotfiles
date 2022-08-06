alias myip='curl https://ipinfo.io/json'
alias run-speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'
alias zz='nvim /Users/seba/.zshrc'
alias sz='source ~/.zshrc'
alias maketex='cp ~/.texfiles/* . && mv file.tex'

alias debuck='$DOTFILES/debuck/debuck'

# VIM Snippets
alias vimsnips='$XDG_CONFIG_HOME/nvim/UltiSnips'

# VIM Init
alias vc='nvim $XDG_CONFIG_HOME/nvim/init.vim'

# Draw.io
alias draw.io='/Applications/draw.io.app/Contents/MacOS/draw.io'

# replace common `rm` command for trash (https://github.com/changkun/rmtrash)
alias rm='trash'

# ls
TREE_IGNORE="cache|log|logs|node_modules|vendor"

alias ls=' exa --group-directories-first'
alias la=' ls -a'
alias ll=' ls --git -l'
alias lt=' ls --tree -D -L 2 -I ${TREE_IGNORE}'
alias ltt=' ls --tree -D -L 3 -I ${TREE_IGNORE}'
alias lttt=' ls --tree -D -L 4 -I ${TREE_IGNORE}'
alias ltttt=' ls --tree -D -L 5 -I ${TREE_IGNORE}'


# cat
alias cat=' bat'


# fix brew doctor issue with config files outside directory (pyenv issue)
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'

# go github folder
alias gogit='cd $GOPATH/src/github.com/sbarrios93/'
