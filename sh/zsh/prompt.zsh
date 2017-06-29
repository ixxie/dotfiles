git_dirty() {
    command git rev-parse --is-inside-work-tree &>/dev/null || return

    command git diff --quiet --ignore-submodules HEAD &>/dev/null;
    if [[ $? -eq 1 ]]; then
        echo " %F{red}(*)%f"
    else
        echo " %F{green}(-)%f"
    fi
}

git_branch() {
    command git rev-parse --is-inside-work-tree &>/dev/null || return

    echo " %F{245}[$(git rev-parse --abbrev-ref HEAD)]%f"
}

function zle-line-init zle-keymap-select {
    V_P="%F{green}[N]%f"
    export RPROMPT='${${KEYMAP/vicmd/$V_P}/(main|viins)/}`git_branch``git_dirty`'
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

export PROMPT='[%~]: '

