#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="$HOME/termux-cloud-server"
ENV_FILE="$PROJECT_DIR/config/server.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "File $ENV_FILE belum ada. Salin dulu dari config/server.env.example!"
  exit 1
fi

# Memuat variabel lingkungan
set -a
source "$ENV_FILE"
set +a

# Evaluasi path jika memakai variabel seperti $HOME
eval FB_ROOT="$FB_ROOT"
eval FB_DB="$FB_DB"
eval FB_LOG="$FB_LOG"

mkdir -p "$FB_ROOT" "$(dirname "$FB_DB")" "$(dirname "$FB_LOG")"

# Menjaga wake-lock aktif
termux-wake-lock

# Menjalankan SSH daemon jika belum jalan
if ! pgrep -x "sshd" >/dev/null 2>&1; then
  sshd
  echo "SSHD dijalankan (default port 8022)."
fi

# Menjalankan Filebrowser di background jika belum jalan
if pgrep -f "filebrowser.*-p ${FB_PORT}" >/dev/null 2>&1; then
  echo "Filebrowser sudah berjalan di port ${FB_PORT}."
else
  nohup filebrowser \
    -a "$FB_ADDRESS" \
    -p "$FB_PORT" \
    -r "$FB_ROOT" \
    -d "$FB_DB" \
    >> "$FB_LOG" 2>&1 &
  sleep 1
  echo "Filebrowser dijalankan di http://0.0.0.0:${FB_PORT}"
  echo "Folder root : $FB_ROOT"
  echo "Log file    : $FB_LOG"
fi
