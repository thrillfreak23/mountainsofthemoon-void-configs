#!/bin/bash

xrdb -load ~/.Xdefaults

# 1. Clean up everything first (nuclear reset)
pkill -u "$USER" -x pipewire
pkill -u "$USER" -x wireplumber
pkill -u "$USER" -x pipewire-pulse
pkill -u "$USER" -x redshift
pkill -u "$USER" -x slstatus
pkill -u "$USER" -x dwmblocks
pkill -u "$USER" -x emacs
pkill -u "$USER" -x sxhkd
pkill -u "$USER" -x volumeicon
pkill -u "$USER" -x picom
pkill -u "$USER" -x nm-applet
pkill -u "$USER" -x blueman-applet
pkill -u "$USER" -x blueman-applet
pkill -u "$USER" -x xdg-user-dirs-update
pkill -u "$USER" -x gnome-keyring-daemon
sleep 1

# fix user dirs
xdg-user-dirs-update --force

# picom
picom &

# nm-applet
nm-applet &



# blueman-applet
blueman-applet &

# feh --bg-max /home/rachel/Build/void-artwork/assets/hires/028.png
~/.fehbg

# Start Pipewire stack (must be in this order)
dbus-run-session pipewire &
sleep 2.5
wireplumber &
sleep 2.5
pipewire-pulse &

# slstatus
slstatus &

# three and a half
sxhkd &

# volume control
volumeicon &

# emacs
emacs --daemon 

# Redshift
redshift -l 35:-81 -t 6500:4000 &

# Input & X settings
setxkbmap -option compose:ralt -option terminate:ctrl_alt_bksp

# gnome keyring daemon
/usr/bin/gnome-keyring-daemon --start --components=secrets &
