#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "Menginstal paket dasar Termux..."
pkg install -y openssh termux-services termux-api curl tar gzip

ARCH=$(uname -m)
echo "Arsitektur terdeteksi: $ARCH"

if [ "$ARCH" != "aarch64" ]; then
  echo "Peringatan: Skrip otomatis ini ditargetkan untuk 64-bit (aarch64)."
  exit 1
fi

echo "Mengunduh rilis terbaru Filebrowser untuk linux-arm64..."
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest \
  | grep "browser_download_url.*linux-arm64.tar.gz" \
  | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Gagal mengambil URL rilis Filebrowser. Cek koneksi internet atau GitHub API."
  exit 1
fi

curl -fsSL "$DOWNLOAD_URL" -o /tmp/filebrowser.tar.gz
tar -xzf /tmp/filebrowser.tar.gz -C "$PREFIX/bin" filebrowser
chmod +x "$PREFIX/bin/filebrowser"
rm -f /tmp/filebrowser.tar.gz

echo "Instalasi selesai. Cek versi: $(filebrowser version)"
