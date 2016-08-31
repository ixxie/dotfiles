#!/bin/sh

clock() {
    date "+%a %d %b, %H:%M"
}

volume() {
    if [[ $(amixer get Master | grep -E -o '\[off\]' | head -n 1) ]]; then
        echo "--%"
    else
        amixer get Master | grep -E -o '[0-9]+\%' | head -n 1
    fi
}

battery() {
    if [[ $(acpi | grep -E -o '[0-9]+\%') ]]; then
        acpi | grep -E -o '[0-9]+\%'
    else
        echo "--%"
    fi
}

while true; do
    echo "%{c}TIME: $(clock) - VOL: $(volume) - BATT: $(battery)"
    sleep 2
done
