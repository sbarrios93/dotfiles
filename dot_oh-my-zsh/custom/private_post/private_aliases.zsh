alias ll='ls -al'
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
