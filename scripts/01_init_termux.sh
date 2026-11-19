#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[1/3] Meminta izin akses penyimpanan Android..."
termux-setup-storage

echo "[2/3] Mengaktifkan wake-lock agar CPU tidak mudah tidur..."
termux-wake-lock

echo "[3/3] Memperbarui daftar & paket Termux..."
pkg update -y && pkg upgrade -y

echo "Selesai inisialisasi dasar."
