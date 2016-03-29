export PS1="\u :: [\w]: "

alias showAll='defaults write com.apple.finder AppleShowAllFiles YES'
alias hideAll='defaults write com.apple.finder AppleShowAllFiles NO'

# Colors for ls
if ls --color=auto &> /dev/null; then
    alias ls="ls --color=auto"
else
    export CLICOLOR=1
fi

