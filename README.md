# Android Storage Cloud

Satu HP Android jadul jadi **cloud pribadi**, dikendalikan dari **HP Android lain**. Keduanya hanya butuh **Termux**, tanpa root dan tanpa web.

```text
 HP admin (apa saja)  ──── SSH/SFTP, port 8022 ────▶  HP cloud (jadul, dicolok terus)
 perintah: cloud ...                                   perintah: cloudctl ...
                                                       sshd + folder CloudStorage + watchdog
```

Server hanya terdiri dari tiga hal: **sshd** (SSH dan SFTP), **satu folder penyimpanan**, dan **watchdog** yang menjaga semuanya tetap hidup dan online. File dikirim dan diambil lewat `cloud push` dan `cloud pull`, atau lewat aplikasi SFTP apa pun.

> **Keselamatan:** baterai HP lama yang dicolok 24/7 bisa menggembung. Taruh di tempat berventilasi dan hentikan pemakaian bila baterai membesar atau sangat panas.

## Syarat

| | HP cloud | HP admin |
| --- | --- | --- |
| Android | 9 sampai 12 (API 28–32) | HP apa saja (Termux untuk perintah `cloud`; tanpa Termux lihat bagian *Admin tanpa Termux*) |
| Arsitektur | 32-bit atau 64-bit (`armv7l`, `armv8l`, `aarch64`, x86) | bebas |
| Kernel | tidak butuh fitur khusus (hanya sshd dan shell) | bebas |
| Aplikasi | Termux, Termux:Boot, Termux:API | Termux, Termux:API (notifikasi). `rsync` terpasang otomatis, membuat transfer bisa dilanjutkan |
| Koneksi | Wi-Fi stabil, **online terus**, dicolok charger | online saat dipakai |

Termux, Termux:Boot, dan Termux:API wajib dari sumber yang sama (**F-Droid** atau **GitHub Releases**), bukan Play Store.

## Setup

Hanya tiga langkah. HP cloud cukup memakai **satu file** (`server/cloudctl`) dan satu perintah.

**1. Di HP cloud** (satu perintah mengerjakan semuanya):

Dapatkan filenya, lalu jalankan `install`:
```bash
pkg update -y && pkg install -y curl
curl -fsSL https://raw.githubusercontent.com/rh-fatur/android-storage-cloud/main/server/cloudctl -o cloudctl
bash cloudctl install
```
> Alamat `raw.githubusercontent.com` hanya bekerja setelah `server/cloudctl` ada di cabang `main` repo Anda. Alternatif tanpa internet GitHub: pindahkan file `cloudctl` ke HP cloud (Bluetooth, Telegram, kabel), jalankan `termux-setup-storage` dulu, lalu `bash ~/storage/downloads/cloudctl install`.

`install` mengerjakan tujuh hal secara berurutan dan menampilkan progresnya (`[1/7]` sampai `[7/7]`):

| Langkah | Yang dilakukan |
| --- | --- |
| 1 | Memeriksa Termux, versi Android, arsitektur, dan peringatan bila Termux dari Play Store |
| 2 | Meminta izin storage (ketuk **Izinkan** di layar) dan menunggu sampai diberikan |
| 3 | Memasang paket: `openssh`, `termux-api`, `net-tools`, `nano`, `rsync` |
| 4 | Membuat folder cloud dan konfigurasi bawaan, serta kunci host SSH |
| 5 | Meminta Anda mengatur password SSH (hanya jika belum ada password atau kunci) |
| 6 | Menjalankan sshd dan watchdog |
| 7 | Memasang auto-start untuk Termux:Boot |

Skrip berakhir dengan perintah siap salin untuk HP admin, misalnya:
```text
cloud init 192.168.1.50 u0_a123
```
Dijalankan dari folder lain (mis. `Download`), skrip menyalin dirinya ke `~/cloud-server` dan melanjutkan dari sana. Aman dijalankan ulang kapan saja. Opsi: `--yes` (tanpa pertanyaan) dan `--no-passwd`.

Beberapa hal tidak bisa diotomatiskan oleh aplikasi mana pun, jadi skrip mencetaknya sebagai daftar akhir: buka **Termux:Boot** satu kali, atur pengecualian baterai (skrip menawarkan membukanya), dan aktifkan **Tetap aktif** di Opsi pengembang.

**2. Di HP admin** (clone ke `~`, jangan ke `/sdcard`):
```bash
pkg update -y && pkg install -y git
cd ~ && git clone https://github.com/rh-fatur/android-storage-cloud.git
cd android-storage-cloud
bash admin/install.sh       # memasang paket + perintah `cloud`
```

**3. Hubungkan** (dari HP admin, tempel perintah yang dicetak langkah 1):
```bash
cloud init 192.168.1.50 u0_a123   # kunci SSH dipasang otomatis (password diminta sekali)
cloud doctor                      # cek koneksi langkah demi langkah
cloud ssh-harden                  # matikan login password (setelah kunci berfungsi)
cloud monitor --bg                # notifikasi di HP admin bila HP cloud mati
```
`cloud setup` tidak wajib untuk pemasangan pertama. Ia berguna untuk memperbaiki: mengirim ulang skrip lalu menjalankan `install` lagi di HP cloud.

**Memperbarui kemudian:** `cloud upgrade` (git pull + kirim skrip terbaru). Jalankan `cloud restart` bila watchdog berubah.

## Pemakaian

| Tujuan | Perintah |
| --- | --- |
| Status (perangkat, sshd, internet, IP, storage, baterai) | `cloud status` |
| Start / restart | `cloud start` · `cloud restart` |
| Hentikan sshd + watchdog (minta konfirmasi) | `cloud stop` |
| Isi folder cloud | `cloud ls` · `cloud ls Foto` |
| Buat folder | `cloud mkdir Foto/2026` |
| Kirim ke cloud | `cloud push ~/storage/shared/DCIM/foto.jpg Foto` |
| Ambil dari cloud | `cloud pull Foto/foto.jpg` (masuk ke Downloads) |
| Hapus dari cloud (permanen, minta konfirmasi) | `cloud rm Foto/lama.jpg` |
| Log watchdog | `cloud logs` · `cloud logs -f` |
| Edit konfigurasi HP cloud | `cloud config`, lalu `cloud restart` |
| Perbarui skrip dari repo | `cloud upgrade` (git pull + deploy) |
| Diagnosa masalah | `cloud doctor` |
| Ubah IP tanpa edit file | `cloud set CLOUD_HOST 192.168.1.60` |
| Terminal HP cloud | `cloud shell` |

Tambahkan `-y` untuk melewati pertanyaan konfirmasi (`cloud -y rm ...`). Perintah `push` dan `pull` memakai **rsync** bila ada di kedua HP, sehingga transfer yang putus di tengah bisa dilanjutkan dengan mengulang perintah yang sama. Tanpa rsync dipakai `scp`. Path di `rm`, `mkdir`, `ls`, `push`, dan `pull` selalu relatif terhadap folder cloud; `..` dan awalan `/` ditolak.

Langsung di HP cloud: `bash ~/cloud-server/cloudctl help`.

### Di rumah dan di luar rumah
Isi alamat cadangan dengan IP Tailscale HP cloud:
```bash
cloud set CLOUD_HOST_ALT 100.101.102.103
```
Perintah `cloud` mencoba alamat utama (Wi-Fi rumah) dulu, lalu otomatis beralih ke alamat cadangan bila tidak menjawab. Monitor juga menganggap HP cloud hidup selama salah satu alamat menjawab. Tailscale dipasang sebagai aplikasi di kedua HP.

### Admin tanpa Termux
HP apa pun yang punya aplikasi SFTP/SSH (Termius, Solid Explorer, dan sejenisnya) bisa mengakses cloud. Jalankan `cloud info` dari HP yang sudah punya Termux untuk melihat host, port, user, dan folder awal. Setelah `cloud ssh-harden`, login password dimatikan sehingga aplikasi tersebut harus memakai kunci SSH, bukan password.

## Cara server bekerja

1. `cloudctl start` mengaktifkan **wake-lock**, menjalankan **sshd** di port 8022, lalu **watchdog** di latar belakang.
2. Folder `CLOUD_ROOT` (bawaan `~/storage/shared/CloudStorage`) adalah isi cloud. Karena ada di storage bersama, juga terlihat di aplikasi File di HP cloud.
3. **Watchdog** (tiap `WD_INTERVAL` detik, bawaan 60):
   * menyalakan ulang sshd jika mati;
   * menguji internet lewat koneksi TCP ke `1.1.1.1:443` (cadangan `8.8.8.8:53`), tanpa DNS atau curl;
   * jika gagal `WD_NET_FAILS` kali berturut-turut, mencoba mematikan lalu menyalakan Wi-Fi lewat Termux:API (hanya berhasil di sebagian perangkat);
   * mencatat peringatan bila suhu baterai ≥ `WD_TEMP_WARN` atau charger terlepas.
4. **Termux:Boot** menjalankan `cloudctl boot` setelah HP restart. Perintah itu menunggu jaringan siap (maksimal sekitar 60 detik), lalu menjalankan `start`. Log-nya di `~/cloud-server/data/boot.log`.
5. **Monitor** di HP admin memeriksa port 8022 tiap 60 detik dan mengirim notifikasi Android saat HP cloud mati atau pulih.

Watchdog tidak bisa memperbaiki router mati, gangguan ISP, listrik padam, atau Android yang mematikan Termux. Untuk itu ada monitor.

## Menjaga HP cloud tetap online (pengaturan Android)

* **Opsi pengembang → Tetap aktif** saat mengisi daya.
* **Baterai → Tanpa pembatasan** untuk Termux, Termux:Boot, dan Termux:API. Kunci Termux di daftar aplikasi terbaru bila ROM mematikan aplikasi latar belakang.
* **IP tetap:** pesan IP HP cloud di router (DHCP reservation), atau pakai Tailscale (IP `100.x.y.z` tidak berubah, dan bisa diakses dari luar rumah tanpa port forwarding).
* **Android 12 (API 31–32):** sistem bisa mematikan proses latar Termux (*phantom process killer*), termasuk sshd. Menurut wiki Termux, perbaikannya lewat `adb` (Wireless debugging): `adb shell "settings put global settings_enable_monitor_phantom_procs false"`, atau di Android 12 awal: `adb shell "device_config put activity_manager max_phantom_processes 2147483647"`. Android 9–11 tidak terpengaruh.

## Keamanan
* Jangan *port forward* 8022 ke internet publik. Untuk akses dari luar rumah, pakai Tailscale dan isi `CLOUD_HOST` dengan IP Tailscale.
* Pakai kunci SSH dan jalankan `cloud ssh-harden`. Simpan kunci privat `~/.ssh/id_ed25519_cloud` di HP admin. Jika HP admin hilang, buka Termux langsung di HP cloud untuk memasang kunci baru.
* Satu HP berarti satu titik gagal. Salin file penting ke tempat lain secara berkala.

## Pemecahan Masalah

| Gejala | Solusi |
| --- | --- |
| Perintah `cloud` bilang HP cloud tidak terjangkau | Jalankan `cloud doctor`; ia menunjukkan langkah mana yang gagal. Bila IP berubah: `cloud set CLOUD_HOST <ip-baru>`. |
| `cloud init` gagal tersambung | Pastikan `sshd` jalan di HP cloud, IP benar, satu Wi-Fi (atau Tailscale), port 8022. |
| "Skrip server belum terpasang" | Jalankan `cloud deploy`. |
| `install`: "Izin storage belum diberikan" | Jalankan `termux-setup-storage` langsung di HP cloud, ketuk Izinkan, lalu ulangi `bash cloudctl install`. Izin ini tidak bisa diberikan lewat SSH. |
| `install`: gagal memperbarui daftar paket | Cek internet HP cloud, atau ganti mirror dengan `termux-change-repo`, lalu ulangi `install`. |
| `curl` ke `raw.githubusercontent.com` gagal (404) | `server/cloudctl` belum ada di cabang `main` repo Anda. Push dulu, atau pindahkan file manual. |
| sshd sering mati sendiri | Cek `cloud logs`. Di Android 12, lihat bagian *phantom process killer*. |
| Tidak menyala setelah HP cloud restart | Buka Termux:Boot sekali, cek `~/cloud-server/data/boot.log` di HP cloud, ulangi `cloud boot-install`. |
| Notifikasi monitor tidak muncul | Pasang aplikasi Termux:API (sumber sama dengan Termux) dan izinkan notifikasinya. |
| Tidak bisa SSH setelah `cloud stop` | `stop` mematikan sshd. Nyalakan dari HP cloud: `bash ~/cloud-server/cloudctl start`. |
| `git`: "dubious ownership" | Repo ada di `/sdcard`. Pindahkan ke `~`, atau `git config --global --add safe.directory <path>`. |

## Struktur

```text
├── server/
│   └── cloudctl             # SATU file untuk HP cloud: install | start | stop | restart | status | logs | boot-install | ssh-harden
│                            # (konfigurasi bawaan dan skrip auto-start sudah tertanam di dalamnya)
└── admin/                   # dipakai di HP admin
    ├── install.sh           # pasang paket + perintah `cloud`
    ├── cloudctl             # init | setup | start | status | doctor | ls | mkdir | push | pull | rm | monitor | ...
    └── config/admin.env.example
```

## Lisensi
Lihat berkas [LICENSE](LICENSE).
