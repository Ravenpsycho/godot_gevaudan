#!/bin/sh
printf '\033c\033]0;%s\a' Gevaudan
base_path="$(dirname "$(realpath "$0")")"
"$base_path/gevaudan.x86_64" "$@"
