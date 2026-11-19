#!/data/data/com.termux/files/usr/bin/bash

# Beri jeda agar sistem Android & jaringan Wi-Fi siap setelah boot
sleep 15

termux-wake-lock
bash "$HOME/termux-cloud-server/scripts/03_start_server.sh"
