#!/bin/bash

sketchybar --add item front_app left \
           --set front_app       background.color=$ACCENT_COLOR \
                                 icon.color=0xffffffff \
                                 icon.font="sketchybar-app-font:Regular:16.0" \
                                 label.color=0xffffffff  \
                                 script="$PLUGIN_DIR/front_app.sh"            \
           --subscribe front_app front_app_switched
