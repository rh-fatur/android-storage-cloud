# AGENTS.md

## Gambaran Proyek
Mengubah **satu HP Android jadul** (Android 9–12, 32 atau 64-bit) menjadi cloud pribadi, dikendalikan dari **satu HP Android lain**. Keduanya memakai Termux. Tanpa web, tanpa root.

Server = **sshd (SSH + SFTP) + folder `CLOUD_ROOT` + watchdog**. Tidak ada biner pihak ketiga yang diunduh, jadi tidak ada urusan arsitektur selain yang sudah ditangani paket `openssh` Termux.

* `server/` – berjalan di **HP cloud**. **Hanya satu file mandiri: `server/cloudctl`**. Tidak ada file pendamping (konfigurasi bawaan dan skrip auto-start tertanam di dalamnya). `bash cloudctl install` menyiapkan segalanya; file dideploy ke `~/cloud-server`.
* `admin/` – berjalan di **HP admin**. `admin/cloudctl` (perintah `cloud` setelah `admin/install.sh`) membungkus perintah server lewat SSH, plus file (`ls/mkdir/push/pull/rm`), `doctor`, `info`, `set`, `upgrade`, `monitor`.

## Konvensi
* **Pemisahan peran:** `server/` tidak mengasumsikan HP admin; `admin/` tidak mengasumsikan Termux server. Jembatannya hanya SSH + `tar`/`scp`.
* Setiap perintah baru: implementasi di `server/cloudctl`; tambahkan pembungkus di `admin/cloudctl` bila perlu remote; perbarui tabel README.
* `server/`: shebang `#!/data/data/com.termux/files/usr/bin/bash`, `set -eu`, tanpa root, path relatif ke `SERVER_DIR` (via `readlink -f`). **Tetap satu file**: jangan menambah file pendamping; tambahkan teks bawaan sebagai heredoc di dalam `cloudctl`. `install` harus idempotent, tidak boleh membutuhkan input saat `--yes`, dan menyalin dirinya ke `~/cloud-server` bila dijalankan dari luar home Termux.
* `admin/`: shebang `#!/usr/bin/env bash`, `set -euo pipefail`, hanya butuh `ssh`, `scp`, `tar`.
* Konfigurasi hanya lewat `*.env`. Server: variabel baru wajib punya default di `load_env` **dan** muncul di heredoc `default_env`. Admin: default di `load_conf` dan contoh di `admin/config/admin.env.example`.
* Hal yang tidak bisa diotomatiskan (Termux:Boot, pengecualian baterai, Opsi pengembang) dicetak sebagai daftar akhir oleh `install`, bukan diam-diam dilewati.
* Admin: alamat utama + cadangan (`CLOUD_HOST_ALT`) lewat `reach_host`; semua perintah jarak jauh memanggil `connect` dulu. Perintah destruktif (`rm`, `stop`, `ssh-harden`) wajib minta konfirmasi (kecuali `-y`), dan path dari pengguna wajib lolos `safe_rel`. `ssh-harden` wajib memverifikasi login kunci (BatchMode) lebih dulu.
* Transfer: pakai `rsync` bila ada di kedua HP, jika tidak `scp`. Kode harus kompatibel bash 3.2 (hindari `"${arr[@]}"` kosong di bawah `set -u`).
* Skrip idempotent. Proses dilacak lewat PID file + verifikasi `/proc/PID/cmdline`, bukan `pkill -f`. `stop` harus menghentikan watchdog **sebelum** sshd.
* Uji konektivitas dengan TCP (`/dev/tcp`), bukan `ping`/`curl`/DNS, agar tanpa dependensi.
* Jangan hardcode asumsi 64-bit; jangan butuh fitur kernel khusus.
* Repo harus berada di `~` Termux, bukan `/sdcard`.
* Jangan membuka port ke internet publik; akses jarak jauh via Tailscale.
* Bahasa output dan dokumen: Indonesia. Wajib lolos `bash -n` (dan `shellcheck` bila tersedia).

## Ide Lanjutan
* Sinkronisasi dua arah otomatis (rsync bila tersedia, atau `scp` bertahap).
* Backup terjadwal dari HP admin ke penyimpanan lain.
* Akun SFTP terbatas (satu folder per pengguna) selain akun admin.
* Antarmuka web (Filebrowser) sebagai lapisan opsional di atas server ini.
