# Color scheme
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Source all relevant files
for config ($HOME/.zsh/*.zsh) source $config

# Init better autocomplete
autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' insert-tab pending

# Set $TERM to 256color
case "$TERM" in
    xterm) TERM=xterm-256color
esac

