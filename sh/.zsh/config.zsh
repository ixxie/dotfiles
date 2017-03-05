# => General configs
export EDITOR=vim

REPORTTIME=10

KEYTIMEOUT=1

# => History
HISTFILE=~/.zhistory

HISTSIZE=2000
SAVEHIST=2000

setopt APPEND_HISTORY # Append rather than replace hist file
setopt INC_APPEND_HISTORY # Incrementally append commands when entered
setopt HIST_IGNORE_ALL_DUPS # Only keep most recent duplicate of command
setopt HIST_REDUCE_BLANKS # Remove superfluous blanks
setopt EXTENDED_HISTORY # Save commands timestamp and duration
setopt HIST_VERIFY # Dont execute outright when entering line w/ hist expansion

# => Basics
setopt NO_LIST_BEEP # Dont beep on an ambiguous completion
setopt COMPLETE_ALIASES # Make alias distinct command for completion purposes
setopt PROMPT_SUBST # Allow parameter/arithmetic expansion & command substitution
setopt MENU_COMPLETE
