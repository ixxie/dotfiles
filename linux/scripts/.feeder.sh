#!/bin/sh

clock() {
    date "+%a %d %b, %H:%M"
}

volume() {
    amixer get Master | egrep -o '[0-9]+\%' | head -n 1
}

battery() {
    if [[ $(acpi | egrep -o '[0-9]+\%') ]]; then
        acpi | egrep -o '[0-9]+\%'
    else
        echo "N/A"
    fi  
}

while true; do
    echo "%{c}TIME: $(clock) - VOL: $(volume) - BATT: $(battery)"
    sleep 2
done
