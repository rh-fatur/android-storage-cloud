#!/data/data/com.termux/files/usr/bin/bash

if pgrep -f "filebrowser" >/dev/null 2>&1; then
  pkill -f "filebrowser"
  echo "Filebrowser dihentikan."
else
  echo "Filebrowser tidak sedang berjalan."
fi
