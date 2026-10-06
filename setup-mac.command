#!/bin/bash
cd "$(dirname "$0")" || exit 1
bash ./setup-mac.sh
status=$?
printf "\n"
read -r -p "Press Enter to close this window..."
exit "$status"
