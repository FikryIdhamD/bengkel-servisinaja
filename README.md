# PitStop by Servisin Aja — Multi-Vehicle Booking Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State_Management-Riverpod-blue)](https://riverpod.dev)
[![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Aplikasi mobile berbasis Flutter yang dikembangkan untuk Technical & UI/UX Assessment posisi Mobile Developer & UI/UX Designer di PT Karya Putra Wardjito (Servisin Aja).

Aplikasi ini mengimplementasikan fitur pemesanan servis berkala untuk banyak kendaraan sekaligus dalam satu transaksi (_Multi-Vehicle Booking in One Flow_), menyelesaikan limitasi alur pemesanan tunggal pada aplikasi referensi industri.

---

## Fitur Utama

1. **Multi-Vehicle Selection & Management**  
   Mendukung pemilihan lebih dari satu kendaraan dalam satu alur pemesanan dengan validasi seleksi dinamis serta formulir modal sheet untuk menambahkan unit baru langsung di dalam alur transaksi.
2. **Konfigurasi Servis Spesifik per Unit**  
   Navigasi _Sticky Unit Switcher_ untuk menentukan paket servis (5 paket standar), suku cadang/pelumas tambahan, serta catatan keluhan kendala teknis secara independen per kendaraan tanpa duplikasi form.
3. **Penjadwalan & Alokasi Antrean Pit Terpadu**  
   Penentuan satu cabang bengkel dan satu slot waktu kedatangan terpadu dengan alokasi nomor antrean pit berurutan per unit (`Unit 1: Pit #01`, `Unit 2: Pit #02`) serta kalkulasi akumulasi durasi dan rincian biaya.
4. **Tiket Konfirmasi & Pelacakan Status Real-Time**  
   Penerbitan tiket servis terpadu dengan Kode Booking unik, QR Code bengkel, dan stepper pelacakan progres 4 tahap per unit yang tersinkronisasi langsung via Supabase Realtime.

---

## Catatan Pengujian (Evaluator Guide)

Untuk mempermudah proses evaluasi teknis, perhatikan beberapa ketentuan fungsional berikut:

### 1. Auto-Generate Kendaraan Default saat Registrasi

Saat membuat akun baru melalui halaman Registrasi, sistem secara otomatis memasukkan 2 data kendaraan awal ke dalam garasi akun tersebut:

- **Honda Vario 160** (Plat: `B 1234 ABC`, Tahun: 2023)
- **Yamaha NMAX 155** (Plat: `B 5678 XYZ`, Tahun: 2022)

Hal ini disediakan agar penguji dapat langsung menjalankan pengujian alur Multi-Vehicle Booking tanpa harus melakukan input kendaraan secara manual terlebih dahulu. Penambahan unit kendaraan baru secara manual tetap dapat dilakukan melalui tombol tambah kendaraan di Garasi maupun alur booking.

### 2. Simulator Status Pengerjaan (Dev Tool)

Pada halaman detail tiket pelacakan (`/tracking/:id`), terdapat tombol melayang **Develop/Dev** di sudut kanan bawah layar:

- Tombol ini membuka kontrol simulasi untuk mengubah status pengerjaan unit kendaraan langsung pada database Supabase (`Menunggu Antrean` -> `Sedang Dikerjakan` -> `Pengecekan Akhir` -> `Selesai`).
- Fitur ini digunakan untuk memverifikasi bahwa antarmuka pelacakan dan stepper status benar-benar reaktif dan terbarui secara seketika (_real-time_) melalui koneksi WebSocket Supabase tanpa perlu memuat ulang halaman.

### 3. Pemetaan Data Dinamis dan Statis

| Komponen / Modul             | Tipe Data     | Sumber Data                                                             | Keterangan                                              |
| :--------------------------- | :------------ | :---------------------------------------------------------------------- | :------------------------------------------------------ |
| Autentikasi Pengguna         | Dinamis       | Supabase Auth                                                           | Sign in, Sign up, Session persistence.                  |
| Garasi Kendaraan             | Dinamis       | Supabase DB (`vehicles`)                                                | CRUD armada kendaraan tersimpan per akun.               |
| Transaksi Booking            | Dinamis       | Supabase DB (`bookings`, `booking_vehicle_items`, `booking_item_parts`) | Data transaksi, rincian biaya, dan antrean pit.         |
| Pelacakan & Dev Simulator    | Dinamis       | Supabase Realtime                                                       | Sinkronisasi status pengerjaan via WebSocket.           |
| Katalog Servis & Suku Cadang | Statis        | Master Data (Dart Model)                                                | Struktur paket servis dan suku cadang standar.          |
| Daftar Cabang Bengkel        | Statis / Seed | Seed Data (`dummy_workshops.dart`)                                      | Data cabang, fasilitas, koordinat, dan rating ulasan.   |
| Banner Promosi & Edukasi     | Statis        | Mock Content (`promo_carousel.dart`)                                    | Informasi promo dan tips perawatan pada beranda.        |
| Notifikasi                   | Statis        | Mock Content (`dummy_notifications.dart`)                               | Simulasi riwayat pemberitahuan sistem.                  |
| Halaman Bantuan & Profil     | Statis        | Template Screen                                                         | Pusat Bantuan, Kebijakan Privasi, dan Tentang Aplikasi. |

---

## Struktur Navigasi

Aplikasi menggunakan arsitektur `GoRouter` dengan `ShellRoute` untuk mempertahankan persistent navigation bar:

```text
[ MAIN SHELL ]
├── Beranda (/home)
│   ├── Ringkasan Akun & Status Verifikasi
│   ├── Promo Carousel
│   ├── Preview Garasi Cepat
│   ├── Rekomendasi Bengkel Terdekat
│   └── Notifikasi (/notifications)
├── Garasi (/garage)
│   ├── Daftar Kendaraan Terdaftar
│   ├── Modal Tambah Kendaraan
│   └── Detail Kendaraan & Riwayat Servis (/vehicle/:id)
├── Quick Action FAB (/vehicle-selection)
├── Tiket (/tickets)
│   ├── Tab Tiket Aktif & Riwayat
│   └── Navigasi Pelacakan Langsung
└── Profil (/profile)
    ├── Informasi Pengguna & Status Verifikasi
    ├── Pusat Bantuan (/profile/help)
    ├── Kebijakan Privasi (/profile/privacy)
    └── Tentang Servisin Aja (/profile/about)

[ MULTI-VEHICLE BOOKING FLOW ]
1. Seleksi Multi-Kendaraan (/vehicle-selection)
2. Konfigurasi Servis per Unit (/service-configuration)
3. Pemilihan Bengkel & Jadwal Antrean Pit (/schedule)
4. Ringkasan Biaya & Checkout (/summary-checkout)
5. Tiket Konfirmasi & Pelacakan Real-Time (/tracking/:id)
```

---

## Arsitektur Kode Sumber

Proyek menerapkan pola _Feature-First Clean Architecture_ untuk memisahkan domain logika, data, dan presentasi:

```text
lib/
├── core/
│   ├── constants/       # Token warna, tipografi, aset, daftar negara
│   ├── data/            # Seed data (bengkel, notifikasi)
│   ├── models/          # Model domain inti
│   ├── network/         # Inisialisasi Supabase client & environment loader
│   ├── routes/          # Konfigurasi deklaratif GoRouter & ShellRoute
│   ├── theme/           # Konfigurasi Material 3 theme
│   └── widgets/         # Komponen reusable (Button, TextField, Card, Switcher)
├── features/
│   ├── auth/            # Splash, Login (Password & OTP), Register
│   ├── garage/          # Manajemen kendaraan & detail armada
│   ├── booking/         # Alur 4 langkah pemesanan multi-kendaraan & checkout
│   ├── tracking/        # Tiket digital, pelacakan bertingkat, Dev Simulator
│   ├── home/            # Dashboard beranda, promo carousel, main layout
│   └── profile/         # Profil akun, verifikasi telepon, halaman statis
└── main.dart            # Entry point aplikasi
```

---

## Panduan Instalasi Lokal

### Prasyarat

- Flutter SDK `^3.24.0`
- Dart SDK `^3.5.0`
- Android Studio / VS Code dengan plugin Flutter & Dart
- Java JDK 17

### Langkah Menjalankan Aplikasi

1. **Clone repositori:**

   ```bash
   git clone https://github.com/FikryIdhamD/bengkel-servisinaja.git
   cd pitstop_servisinaja_app
   ```

2. **Konfigurasi Environment Variables (`.env`):**  
   Salin template `.env.example` menjadi `.env`:

   ```bash
   cp .env.example .env
   ```

   _File `.env` bawaan proyek telah terisi konfigurasi Supabase sandbox untuk keperluan pengujian._

3. **Install dependensi:**

   ```bash
   flutter pub get
   ```

4. **Jalankan pengujian unit & widget:**

   ```bash
   flutter test
   ```

5. **Jalankan aplikasi:**

   ```bash
   flutter run
   ```

6. **Build APK Rilis:**
   ```bash
   flutter build apk --release
   ```
   File binary installer akan terbuat pada direktori:  
   `build/app/outputs/flutter-apk/app-release.apk`

---

## Dokumentasi Teknis & Desain

Spesifikasi detail perancangan tersimpan pada folder `assessment_docs/`:

- `assessment_docs/PRD.md`: _Product Requirement Document_ berisi latar belakang masalah, batasan MVP, kebutuhan fungsional 4 pilar, skema relasional database PostgreSQL, dan kriteria penerimaan.
- `assessment_docs/Design.md`: Panduan _Design System_, token warna resmi Servisin Aja (`#FF6600`, `#3E4347`), skala tipografi, spesifikasi UI per halaman, serta pemetaan safe layout.

---

## Tautan Pengumpulan

- **Figma Design:** [https://www.figma.com/design/YYRQjV5BPoMIHu8ENBhobX/PitStop-by-Servisinaja?node-id=4-8338&t=qUnH0KJIWAh56lXD-1](https://www.figma.com/design/YYRQjV5BPoMIHu8ENBhobX/PitStop-by-Servisinaja?node-id=4-8338&t=qUnH0KJIWAh56lXD-1)
- **GitHub Repository:** [https://github.com/FikryIdhamD/bengkel-servisinaja](https://github.com/FikryIdhamD/bengkel-servisinaja)
- **Installer APK:** [https://drive.google.com/drive/folders/1tUAXVdqmOkQcju-NXqZ8i5hq-px4iHch?usp=sharing](https://drive.google.com/drive/folders/1tUAXVdqmOkQcju-NXqZ8i5hq-px4iHch?usp=sharing)
- **Log Percakapan AI:** [https://share.gemini.google/cC8ZDlhm8mV6](https://share.gemini.google/cC8ZDlhm8mV6)
