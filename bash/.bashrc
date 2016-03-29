export PS1="\e[36m\]\u\e[31m\] :: \e[33m\][\w]\n\e[1;37m\]>\e[1;34m\]>\e[1;37m\]>\[\e[m\] "

alias showAll='defaults write com.apple.finder AppleShowAllFiles YES'
alias hideAll='defaults write com.apple.finder AppleShowAllFiles NO'

# Colors for ls
if ls --color=auto &> /dev/null; then
    alias ls="ls --color=auto"
else
    export CLICOLOR=1
fi

