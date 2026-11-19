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
> Hanya perangkat ini yang menjalankan `admin/cloudctl`. Tidak ada layanan cloud di sini.
* Terminal/SSH client (atau aplikasi seperti Termius / WinSCP / FileZilla) untuk mengelola HP dari jarak jauh.
* Browser web modern untuk membuka dashboard Filebrowser.

---

## Arsitektur: Dua Perangkat, Dua Folder

| | **Perangkat Server** (HP Android) | **Perangkat Admin** (Laptop/PC) |
| --- | --- | --- |
| Folder | `server/` | `admin/` |
| Menjalankan | sshd + Filebrowser | hanya CLI pengendali |
| CLI | `server/cloudctl` (di Termux) | `admin/cloudctl` (Linux, macOS, WSL, Git Bash) |
| Konfigurasi | `server/config/server.env` (di HP) | `admin/config/admin.env` (di laptop) |

Admin **tidak perlu menyentuh HP** setelah bootstrap awal. `admin/cloudctl` mengirim skrip `server/` lewat SSH lalu menjalankan `server/cloudctl` di HP. Setiap perintah admin hanyalah pembungkus tipis untuk perintah server dengan nama yang sama.

```text
android-storage-cloud/
├── README.md  AGENTS.md  LICENSE  .gitignore
├── server/                        # ← berjalan di HP (Termux)
│   ├── cloudctl                   # setup | start | stop | status | logs | update | backup | boot-install | ssh-harden
│   ├── boot/start-cloud.sh        # dipanggil Termux:Boot (menunggu jaringan siap)
│   └── config/server.env.example
└── admin/                         # ← berjalan di laptop/PC
    ├── cloudctl                   # init | deploy | setup | start | status | open | shell | backup | pull | push ...
    └── config/admin.env.example
```

---

## Setup Awal

### A. Di HP server (sekali, manual)
Buka Termux, lalu:
```bash
termux-setup-storage        # izinkan akses storage (hanya bisa dari HP langsung)
pkg install -y openssh
passwd                      # password sementara untuk login pertama
whoami                      # catat username, mis. u0_a123
sshd                        # port 8022
```
Cek IP HP (Wi-Fi atau Tailscale), mis. dengan `ifconfig`.

### B. Di laptop/PC admin
```bash
git clone https://github.com/rh-fatur/android-storage-cloud.git
cd android-storage-cloud

./admin/cloudctl init       # isi IP & username; kunci SSH dipasang otomatis
./admin/cloudctl setup      # kirim skrip + instal Filebrowser di HP
./admin/cloudctl start
./admin/cloudctl boot-install   # auto-start setelah HP restart
./admin/cloudctl ssh-harden     # (disarankan) matikan login password
```
> Windows: gunakan WSL atau Git Bash (butuh `ssh`, `scp`, `tar`).

### C. Login pertama Filebrowser
```bash
./admin/cloudctl open        # buka Web UI
./admin/cloudctl logs        # cari password admin awal (versi baru: acak, tercetak di log)
```
Segera ganti password di **Settings → Profile Settings**, dan buat akun terpisah per pengguna di **Settings → User Management**.

Terakhir buka aplikasi **Termux:Boot** sekali di HP dan matikan optimasi baterai untuk Termux & Termux:Boot.

---

## Pemakaian Harian (dari laptop/PC)

| Tujuan | Perintah |
| --- | --- |
| Status, alamat akses, storage, baterai | `./admin/cloudctl status` |
| Start / stop / restart | `./admin/cloudctl start` · `stop` · `restart` |
| Lihat log (live) | `./admin/cloudctl logs -f` |
| Buka Web UI | `./admin/cloudctl open` |
| Edit konfigurasi server | `./admin/cloudctl config` lalu `restart` |
| Perbarui skrip + Filebrowser | `./admin/cloudctl update` |
| Backup DB & config ke laptop | `./admin/cloudctl backup` (tersimpan di `admin/backups/`) |
| Salin file dari/ke cloud | `./admin/cloudctl pull Foto/2026 .` · `./admin/cloudctl push ./dokumen Dokumen` |
| Terminal HP | `./admin/cloudctl shell` |

Pengguna biasa cukup membuka `http://IP-HP:8080` di browser. SFTP juga tersedia di port `8022` (user & kunci/password yang sama).

> **Perintah langsung di HP** (tanpa admin): `bash ~/android-storage-cloud/cloudctl help`. Daftar perintahnya sama.

### Akses dari luar rumah (Tailscale)
Pasang Tailscale di HP server dan perangkat admin/pengguna dengan akun yang sama, lalu isi `CLOUD_HOST` di `admin/config/admin.env` dengan IP Tailscale HP (`100.x.y.z`). Tanpa port forwarding.

---

## Keamanan
* Jangan *port forward* 8080/8022 ke internet publik.
* Pakai kunci SSH (`init`) dan jalankan `ssh-harden` setelah login kunci berhasil.
* `ssh-harden` mematikan login password. Jaga kunci privat `~/.ssh/id_ed25519_cloud` di laptop; jika hilang, akses ulang lewat Termux langsung di HP.
* Ganti password default Filebrowser dan buat akun per pengguna.
* `backup` hanya mencakup database & konfigurasi; file di folder cloud perlu disalin terpisah (`pull` atau rsync/SFTP).

---

## Pemecahan Masalah

| Gejala | Solusi |
| --- | --- |
| `init` gagal konek | Pastikan `sshd` jalan di HP, IP benar, satu jaringan, port 8022. |
| `setup`: "Akses storage belum diberikan" | Jalankan `termux-setup-storage` langsung di HP lalu ulangi `setup`. |
| Server mati saat layar padam | Matikan optimasi baterai untuk Termux; `termux-wake-lock` dipasang otomatis oleh `start`. |
| Tidak jalan setelah reboot | Buka Termux:Boot sekali; cek `server/data/boot.log` di HP; ulangi `boot-install`. |
| Port 8080 terpakai | `./admin/cloudctl config` → ubah `FB_PORT`, lalu `restart` (dan `FB_PORT` di `admin.env`). |
| Gagal unduh Filebrowser | Cek internet HP; GitHub API ada rate limit, coba lagi nanti. |
| Setelah `stop --all` tidak bisa SSH | Nyalakan lagi dari HP: `sshd`. |

---

## Lisensi
Lihat berkas [LICENSE](LICENSE).
