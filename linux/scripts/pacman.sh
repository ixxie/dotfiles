#!/usr/bin/env bash

set -e

sudo -v # Ask for sudo upfront

sudo pacman -Sy # Download fresh package databases

sudo pacman -S alsa-utils \
               alsa-lib \
               blender \
               compton \
               dmenu \
               firefox \
               gimp \
               git \
               gvfs \
               graphicsmagick \
               htop \
               lxappearance \
               nitrogen \
               numix-gtk-theme \
               obconf \
               obmenu \
               openbox \
               openssh \
               pavucontrol \
               pulseaudio \
               pulseaudio-alsa \
               redshift \
               terminus-font \
               thunar \
               tmux \
               vim \
               wireless_tools \
               xbindkeys \
               xfce4-terminal \
               zsh \
               scrot \
               rust \
               cargo \
               valgrind \
               make \
               rxvt-unicode \
               jre8-openjdk
