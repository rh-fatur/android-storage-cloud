# AGENTS.md

## Gambaran Proyek
Skrip & dokumentasi untuk menjadikan HP Android (**Android 9–11** / Custom ROM setara, **64-bit `aarch64`**) sebagai **Personal Cloud Storage Server** ringan dengan **Termux**, **OpenSSH**, dan **Filebrowser**. Proyek dipisah menjadi dua sisi:

* `server/` – berjalan di **HP server** (Termux). Satu CLI: `server/cloudctl`.
* `admin/` – berjalan di **laptop/PC admin** (Linux/macOS/WSL/Git Bash). `admin/cloudctl` hanya membungkus perintah server lewat SSH.

## Struktur
```text
├── server/
│   ├── cloudctl                  # setup|start|stop|restart|status|logs|update|backup|boot-install|ssh-harden
│   ├── boot/start-cloud.sh       # entry Termux:Boot
│   └── config/server.env.example
└── admin/
    ├── cloudctl                  # init|deploy|setup|... + open|shell|config|pull|push|backup
    └── config/admin.env.example
```
Runtime di HP (tidak di-commit): `server/config/server.env`, `server/data/` (DB, log), `server/run/` (PID).

## Konvensi
* **Pemisahan peran:** kode di `server/` tidak boleh mengasumsikan laptop admin; kode di `admin/` tidak boleh mengasumsikan Termux. Satu-satunya jembatan adalah SSH + `tar`.
* Setiap perintah baru: implementasi di `server/cloudctl`, lalu (jika perlu remote) tambahkan pembungkus di `admin/cloudctl`, dan perbarui tabel README.
* `server/`: shebang `#!/data/data/com.termux/files/usr/bin/bash`, `set -eu`, tanpa root, path selalu relatif ke `SERVER_DIR` (via `readlink -f`).
* `admin/`: shebang `#!/usr/bin/env bash`, `set -euo pipefail`, hanya butuh `ssh`, `scp`, `tar` (tanpa rsync/ssh-copy-id agar jalan di Git Bash).
* Konfigurasi hanya lewat `*.env` (contoh: `*.env.example`); variabel baru harus punya default di `load_env`/`load_conf`.
* Skrip idempotent; output untuk mesin (mis. `backup --stdout`) tidak boleh bercampur dengan pesan log.
* Proses dilacak lewat PID file + verifikasi `/proc/PID/cmdline`, bukan `pkill -f`.
* Jangan membuka layanan ke internet publik secara default; akses jarak jauh via Tailscale.
* Bahasa output & dokumen: Indonesia. Wajib lolos `bash -n` (dan `shellcheck` bila tersedia).

## Ide Lanjutan
* HTTPS (sertifikat Tailscale / self-signed) untuk Filebrowser.
* Backup terjadwal otomatis (`crond`) + rotasi backup di `admin/backups/`.
* Notifikasi baterai/storage lewat `termux-notification`.
* Wrapper PowerShell native untuk Windows tanpa WSL/Git Bash.
