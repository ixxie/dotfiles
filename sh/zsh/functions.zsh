# Makes colorizing output a bit easier.
# $1: string to be colorized
# $2: tput color code
# $3: flag for bold text
function echo_c {
    if [[ $3 == "-b" ]]; then
        echo "$(tput bold && tput setaf $2)$1$(tput sgr0)"
    else
        echo "$(tput setaf $2)$1$(tput sgr0)"
    fi
}

# Timer for various simple timing needs.
# $1: time in seconds (mandatory)
function timer {
    if [[ $1 == "" ]]; then
        echo "$(echo_c "ERROR:" 1 -b) Missing parameter"
        return
    elif ! [[ $1 =~ '^[0-9]+$' ]]; then
        echo "$(echo_c "ERROR:" 1 -b) Not a number"
        return
    fi

    for i in {1..$1}; do sleep 1; echo -n -e $i\\r; done
}
