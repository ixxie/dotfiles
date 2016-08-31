#!/bin/sh

x_res="$(xrandr | grep '\*' | cut -d ' ' -f4 | cut -d 'x' -f1 | head -n 1)"

./.feeder.sh | lemonbar -b -g "250x20+$((x_res/2-125))+5" -F "#f0f0f0" -B "#595959" -f "-benis-lemon-medium-r-normal--10-110-75-75-m-50-ISO8859-1" -n "lemonbar-time"
