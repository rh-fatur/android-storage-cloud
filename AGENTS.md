# AGENTS.md

## Gambaran Proyek
Repositori ini berisi skrip, konfigurasi, dan dokumentasi untuk menjadikan HP Android (target utama **Android 9–11** atau Custom ROM/port setara, arsitektur **64-bit / `aarch64`**) sebagai **Personal Cloud Storage Server** ringan menggunakan **Termux**, **OpenSSH**, dan **Filebrowser**.

## Struktur Direktori
```text
termux-cloud-server/
├── README.md
├── AGENTS.md
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
