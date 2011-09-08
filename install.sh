#!/bin/bash

COLOR_NC='\033[0m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'

EXCLUDE=(install.sh README.markdown)

echo -n "Initializing and updating git submodules..."
if (cd $(dirname $0) && exec git submodule update --init &> /dev/null); then
  echo -ne "\r$COLOR_GREEN"
  echo "Submodules successfully initialized & updated."
else
  echo -ne "\r$COLOR_YELLOW"
  echo "Submodules could not be initialized/updated."
fi

for filename in $(ls "$(dirname $0)"); do
  [[ ${EXCLUDE[@]} =~ $filename ]] && continue
  original="$(cd "$(dirname $0)" && pwd)/$filename"
  symbolic="$HOME/.$filename"

  if [ -e "$symbolic" ]; then
    if [[ $(readlink "$symbolic") != "$original" ]]; then
      echo -ne $COLOR_YELLOW
      echo "\".$filename\" already exists, skipping."
    else
      echo -ne $COLOR_GREEN
      echo "\".$filename\" is already linked"
    fi
  else
    echo -ne $COLOR_GREEN
    echo "\".$filename\" linked"
    ln -s "$original" "$symbolic"
  fi
done

mkdir -p ~/.vim/tmp ~/.vim/undo

for filename in $(ls "$HOME/.localrcs"); do
  original="$HOME/.localrcs/$filename"
  symbolic="$HOME/.$(echo $filename | cut -d'.' -f 2)"
  current_host="$(echo $(hostname) | cut -d'.' -f 1 | awk '{print tolower($0)}')"
  target_host="$(echo $filename | cut -d'.' -f 1 | awk '{print tolower($0)}')"

  if [[ $target_host == $current_host ]]; then
    if [ -e "$symbolic" ]; then
      if [[ $(readlink "$symbolic") != "$original" ]]; then
        echo -ne $COLOR_YELLOW
        echo "\".$filename\" already exists, skipping."
      else
        echo -ne $COLOR_GREEN
        echo "\".$filename\" is already linked"
      fi
    else
      echo -ne $COLOR_GREEN
      echo "\".$filename\" linked"
      ln -s "$original" "$symbolic"
    fi
  fi
done

echo -ne $COLOR_NC
