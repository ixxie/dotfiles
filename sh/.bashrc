# Color scheme
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Prompt
export PS1="[\w]: "

# Aliases
alias cl='clear'
# Mac
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

