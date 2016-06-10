# Prompt
export PS1="[\w]: "

# Aliases
alias cl='clear'
# OSX
alias showAll='defaults write com.apple.finder AppleShowAllFiles YES'
alias hideAll='defaults write com.apple.finder AppleShowAllFiles NO'

# Set $TERM to 256color
case "$TERM" in
    xterm) TERM=xterm-256color
esac

# Colors for ls
if ls --color=auto &> /dev/null; then
    alias ls="ls --color=auto"
else
    export CLICOLOR=1
fi

