#!/bin/sh

if [ -z "$@" ]; then
  zip -r -o -X wifi_switch_$(cat module.prop | grep 'version=' | awk -F '=' '{print $2}').zip ./ -x '.git/*' -x 'build.sh' -x '.github/*' -x 'update.json' -x '.gitignore' -x 'wifi_switch_*.zip' -x 'run/.gitkeep'
else
  zip -r -o -X wifi_switch_${1}.zip ./ -x '.git/*' -x 'build.sh' -x '.github/*' -x 'update.json' -x '.gitignore' -x 'wifi_switch_*.zip' -x 'run/.gitkeep'
fi
