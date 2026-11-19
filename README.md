# Termux Cloud Server (Android 9–11)

Repositori ini berisi rencana setup, panduan penggunaan admin, dan skrip otomatisasi untuk mengubah HP Android jadul (atau HP yang di-*port* ke Custom ROM **Android 9–11**, arsitektur **64-bit / `aarch64`**) menjadi **Personal Cloud / Home Storage Server** menggunakan **Termux**, **OpenSSH**, dan **Filebrowser**.

> **Catatan keamanan & baterai:**
> * Jalankan server ini di jaringan lokal (Wi-Fi rumah) atau lewat jaringan privat **Tailscale**. Hindari membuka *port* langsung ke internet publik tanpa lapisan keamanan tambahan.
> * Gunakan charger standar (bukan *fast charging* berlebih jika tidak diperlukan), letakkan HP di tempat berventilasi baik, dan pertimbangkan pembatas pengisian daya (misalnya modul ACC jika HP sudah *root*) untuk penggunaan 24/7.

---

## Ringkasan Cara Kerja

Daripada menjalankan aplikasi cloud berat seperti Nextcloud yang membutuhkan web server, PHP, dan database terpisah, setup ini menggunakan pendekatan ringan yang cocok untuk HP bekas:

* **Termux:** Lingkungan terminal Linux di Android untuk menjalankan layanan *background* dan skrip administrasi.
* **OpenSSH (`sshd`):** Memungkinkan admin mengakses terminal HP dari laptop/PC secara *remote* serta mentransfer file lewat protokol **SFTP**.
* **Filebrowser:** Menyediakan antarmuka web modern mirip Google Drive untuk *upload/download*, mengelola folder, *preview* media, membuat akun pengguna, dan berbagi file lewat jaringan lokal maupun Tailscale.
* **Termux:Boot + `termux-wake-lock`:** Menjaga proses tetap hidup dan otomatis menyala kembali setelah HP *restart*.

---

## Persiapan Perangkat & Aplikasi

### 1. Perangkat Keras (*Hardware*)
* **HP Android 9–11 (64-bit / `aarch64`):** Ideal dengan RAM minimal 3 GB (2 GB masih bisa untuk beban ringan) dan penyimpanan internal yang memadai.
* **Jika memakai HP *port* / Custom ROM:** Pastikan Wi-Fi, pengisian daya, dan akses penyimpanan berjalan stabil.
* **Charger & kabel yang layak** serta posisi HP yang tidak memerangkap panas.

### 2. Aplikasi di HP Server
* **Termux:** Wajib instal dari sumber yang sama (GitHub Releases resmi atau F-Droid), **bukan** dari Google Play Store.
* **Termux:Boot:** Wajib instal dari sumber yang sama dengan Termux (GitHub atau F-Droid) agar *signature* aplikasi cocok dan skrip *auto-start* bisa berjalan.
* **Tailscale (Opsional):** Untuk mengakses server dari luar rumah (data seluler / Wi-Fi luar) tanpa *port forwarding* router.
* **ACC / pengatur baterai (Opsional, khusus HP *root*):** Membantu menjaga kesehatan baterai saat dicolok terus-menerus.

### 3. Perangkat Admin (Laptop / PC / HP Utama)
* Terminal/SSH client (atau aplikasi seperti Termius / WinSCP / FileZilla) untuk mengelola HP dari jarak jauh.
* Browser web modern untuk membuka dashboard Filebrowser.

---

## Struktur Direktori Proyek

```text
termux-cloud-server/
├── README.md
├── .gitignore
├── config/
│   └── server.env.example
├── scripts/
│   ├── 01_init_termux.sh
│   ├── 02_install_services.sh
│   ├── 03_start_server.sh
│   └── 04_stop_server.sh
└── boot/
    └── start-cloud.sh
