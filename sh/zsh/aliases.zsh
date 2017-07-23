# Use colors for 'ls'
if ls --color > /dev/null 2>&1; then
    alias ls='ls --color'
else
    alias ls='ls -G'
fi

# => Aliases
alias cl='clear'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias g='git'

# => MacOS
alias showAll='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hideAll='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'

