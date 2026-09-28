# Product Requirement Document (PRD)

**Nama Produk:** PitStop by Servisin Aja

**Klien / Penugasan:** PT KARYA PUTRA WARDJITO • SERVISIN AJA

**Posisi Evaluasi:** Mobile Developer & UI/UX Designer

**Target Platform:** Mobile Application (Flutter - Android APK)

**Arsitektur & Teknologi:** Flutter, Riverpod (State Management), GoRouter (Declarative Routing), Supabase (Auth, Database PostgreSQL, Realtime Engine)

**Dokumen Pendukung Desain:** `Design.md` _(spesifikasi komponen UI/UX & visual tokens)_

---

## 1. Ikhtisar Produk & Latar Belakang Masalah

Pada ekosistem layanan purna jual kendaraan bermotor roda dua (seperti aplikasi referensi industri Honda MotorkuX), proses pemesanan servis berkala umumnya dibatasi hanya untuk 1 unit kendaraan per transaksi. Keterbatasan ini menimbulkan ketidakefisienan (_high friction_) bagi pelanggan yang memiliki lebih dari satu armada motor di rumah, maupun pengelola operasional usaha mikro yang ingin melakukan perawatan berkala bagi beberapa motor operasionalnya sekaligus.

**PitStop by Servisin Aja** dirancang sebagai aplikasi jaringan bengkel resmi milik Servisin Aja yang menghadirkan inovasi fitur **Multi-Vehicle Booking in One Flow**. Pengguna dapat:

1. Memilih lebih dari satu kendaraan dalam satu alur pemesanan.
2. Mengonfigurasi kebutuhan jenis servis, paket suku cadang/pelumas, dan catatan keluhan yang berbeda untuk masing-masing unit tanpa duplikasi formulir.
3. Menentukan lokasi bengkel resmi dan satu slot jadwal terpadu yang dilengkapi penomoran antrean pit servis transparan.
4. Mengakses tiket digital terpadu dengan kemampuan melacak progres pengerjaan per unit motor secara independen dan _real-time_.

---

## 2. Ruang Lingkup Minimum Viable Product (MVP)

Ruang lingkup MVP ditetapkan secara ketat berdasarkan 4 pilar tantangan utama produk serta kriteria wajib dokumen penugasan teknis, disesuaikan dengan kebutuhan autentikasi lengkap dan mekanisme pengujian:

| Modul MVP                                             | Batasan Fungsional Wajib                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Autentikasi & Profil**                              | • Splash screen resmi Servisin Aja dengan footer hak cipta tahun 2026.<br><br>• Registrasi Akun baru (Nama Lengkap, Nomor Telepon +62, Email, Kata Sandi).<br><br>• Verifikasi Email aktivasi via Supabase Auth sebelum login pertama kali.<br><br>• Dual-Tab Login: **Login via OTP** dan **Login Password**.<br><br>• Verifikasi nomor telepon lanjutan di layar profil.<br><br>• Integrasi Supabase Auth & session persistence lokal.                                                                                                                                                                                  |
| **Pilar 1: Multi-Vehicle Selection & Management**<br> | • Menampilkan seluruh daftar motor milik pengguna dari database Supabase.<br><br>• Mekanisme seleksi multi-kendaraan menggunakan _checkbox_ interaktif (minimal 2 motor dalam satu transaksi).<br><br>• Formulir penambahan unit motor baru secara instan dalam alur booking (Nomor Polisi, Model/Tipe, dan Tahun pembuatan via text field murni tanpa dropdown).                                                                                                                                                                                                                                                         |
| **Pilar 2: Keluhan & Servis Spesifik per Unit**<br>   | • Navigasi _switcher_ unit kendaraan terpilih (Tab selector di bagian atas).<br><br>• Konfigurasi mandiri per unit:<br><br> - Pemilihan 1 paket servis utama (5 pilihan katalog standar).<br><br> - Pemilihan suku cadang / pelumas tambahan opsional.<br><br> - Pengisian teks keluhan dan gejala kerusakan spesifik per unit.<br><br>• Validasi kelengkapan form sebelum dapat melanjutkan ke langkah jadwal.                                                                                                                                                                                                           |
| **Pilar 3: Jadwal & Form Booking Terpadu**<br>        | • Pemilihan 1 cabang bengkel resmi PitStop by Servisin Aja.<br><br>• Pemilihan 1 tanggal kedatangan dan 1 slot jam terpadu.<br><br>• Penentuan nomor urut antrean pit per kendaraan pada jam yang sama (misal: Unit 1 Antrean #01, Unit 2 Antrean #02).<br><br>• Rincian kalkulasi estimasi akumulasi total durasi servis seluruh unit.<br><br>• Ringkasan estimasi total biaya (Jasa + Sparepart per unit).<br><br>• Pilihan opsi metode pembayaran di _checkout_ (Bayar di Bengkel, Simulasi Virtual Account, Simulasi QRIS).                                                                                           |
| **Pilar 4: Tiket Konfirmasi & Status Pelacakan**<br>  | • Penerbitan tiket servis terpadu dengan Kode Booking unik dan QR Code check-in.<br><br>• Status transaksi induk pada level booking (`Menunggu Kedatangan`, `Diproses`, `Selesai`, `Dibatalkan`).<br><br>• Pelacakan status pengerjaan bertingkat (_stepper_) independen per unit motor (`Menunggu Antrean`, `Sedang Dikerjakan`, `Pengecekan Akhir`, `Selesai`).<br><br>• Sinkronisasi perubahan status berbasis Supabase Realtime.<br><br>• Tombol Pengujian Pengembang (_Dev Simulation Mode_) melayang untuk memicu pembaruan status unit langsung di database Supabase guna memvalidasi aspek realtime oleh penguji. |

---

## 3. Kebutuhan Fungsional Sistem (Functional Requirements)

### Modul 1: Autentikasi & Manajemen Pengguna

- **FR-1.1 (Splash Check):** Sistem wajib melakukan inisialisasi sesi `supabase.auth.currentSession` saat aplikasi dibuka melalui Splash Screen.
- **FR-1.2 (Pendaftaran Akun):** Sistem menyediakan form registrasi yang mewajibkan input: Nama Lengkap, Nomor Telepon, Email, dan Password.
- **FR-1.3 (Verifikasi Email):** Sistem mengirimkan email konfirmasi pendaftaran melalui Supabase Auth. Akun baru berstatus unverified dan dilarang masuk ke sesi aplikasi sebelum tautan verifikasi email dikonfirmasi.
- **FR-1.4 (Dual-Tab Login):** Halaman login menyediakan _segmented control_:
  - _Tab Login Password:_ Menerima input Nomor Telepon / Email dan Password.
  - _Tab Login via OTP:_ Menerima input Nomor Telepon dan mengirimkan OTP verifikasi.
- **FR-1.5 (Format Telepon Indonesia):** Field nomor telepon terkunci dengan awalan kode negara permanen `+62` disertai ikon bendera Indonesia.
- **FR-1.6 (Verifikasi Telepon Lanjutan):** Pada halaman profil akun pengguna, disediakan tombol untuk memverifikasi nomor telepon via OTP jika nomor belum berstatus terverifikasi.

### Modul 2: Garasi & Multi-Vehicle Selection

- **FR-2.1 (Pemuatan Armada):** Sistem memuat seluruh motor terdaftar milik pengguna dari tabel `vehicles` berdasarkan `user_id`.
- **FR-2.2 (Multi-Selection Checkbox):** Pengguna dapat mencentang lebih dari 1 kendaraan untuk dimasukkan ke dalam keranjang pemesanan aktif.
- **FR-2.3 (Form Tambah Motor Instan):** Disediakan tombol "+ Tambah Motor Baru" yang memunculkan modal sheet ringkas dengan 3 isian teks murni:
  1. Nomor Polisi (misal: `B 1234 ABC`)
  2. Merk & Model Motor (misal: `Honda Vario 160`)
  3. Tahun Pembuatan (misal: `2023`)
     Data yang disimpan langsung tersimpan ke Supabase dan otomatis terpilih di sesi pemesanan.
- **FR-2.4 (Validasi Armada):** Tombol lanjut dinonaktifkan (_disabled_) jika jumlah kendaraan yang dicentang kurang dari 1 unit.

### Modul 3: Konfigurasi Servis & Keluhan Spesifik per Unit

- **FR-3.1 (Switcher Kendaraan):** Bagian atas layar menyajikan bilah tab mendatar berisi motor-motor yang telah dipilih pada langkah sebelumnya.
- **FR-3.2 (Konfigurasi Independen Unit):** Pengguna dapat menentukan paket servis, opsi suku cadang/oli, dan catatan kerusakan untuk Unit A tanpa menduplikasi atau menimpa konfigurasi Unit B.
- **FR-3.3 (Katalog Servis Standar):** Sistem menyediakan 5 paket pilihan servis utama:
  1. _Ganti Pelumas Cepat (Fast Pit):_ Estimasi 15 Menit - Rp 15.000.
  2. _Servis Ringan / Rutin:_ Estimasi 30 Menit - Rp 65.000.
  3. _Servis Berkala / Lengkap (Tune Up):_ Estimasi 45 Menit - Rp 110.000.
  4. _Servis Transmisi CVT:_ Estimasi 35 Menit - Rp 55.000.
  5. _Perbaikan Khusus & Keluhan Berat:_ Estimasi 60 Menit - Rp 95.000.
- **FR-3.4 (Pilihan Suku Cadang & Pelumas Cepat):** Pengguna dapat mencentang kebutuhan suku cadang tambahan:
  - Oli Mesin MPX 2 (0.8L) - Rp 54.000
  - Oli Mesin Sintetik SPX 2 (0.8L) - Rp 67.000
  - Oli Gardan Scooter (120ml) - Rp 18.000
  - Busi Standar NGK / Denso - Rp 25.000
  - Kampas Rem Depan / Belakang - Rp 45.000
- **FR-3.5 (Catatan Keluhan):** Disediakan form teks bebas (_text area_) per unit untuk mencatat kendala spesifik.
- **FR-3.6 (Validasi Konfigurasi):** Seluruh unit wajib memiliki minimal 1 paket servis terpilih sebelum diperbolehkan melangkah ke penentuan jadwal.

### Modul 4: Jadwal, Bengkel & Penomoran Antrean Terpadu

- **FR-4.1 (Pemilihan Bengkel):** Pengguna memilih 1 bengkel cabang PitStop by Servisin Aja.
- **FR-4.2 (Pemilihan Jadwal):** Pengguna memilih 1 tanggal servis dan 1 slot jam kedatangan yang berlaku untuk seluruh kendaraan yang didaftarkan.
- **FR-4.3 (Penomoran Antrean Pit):** Sistem secara otomatis menerbitkan nomor antrean pengerjaan berurutan per kendaraan pada slot jam yang sama:
  - Unit 1: Jam Kedatangan `HH:mm` • Antrean Pit #01
  - Unit 2: Jam Kedatangan `HH:mm` • Antrean Pit #02
- **FR-4.4 (Kalkulasi Durasi):** Sistem mengalkulasi total durasi pengerjaan yang dibutuhkan armada secara transparan.

### Modul 5: Ringkasan Pemesanan & Pembayaran

- **FR-5.1 (Breakdown Biaya):** Layar ringkasan menyajikan perincian biaya transparan:
  - Subtotal Biaya Jasa Servis & Part Unit 1.
  - Subtotal Biaya Jasa Servis & Part Unit 2.
  - Akumulasi Total Pembayaran Akhir.
- **FR-5.2 (Opsi Pembayaran Frontend):** Disediakan radio button pilihan metode pembayaran (Bayar di Bengkel saat Servis Selesai, Simulasi Virtual Account Bank, dan Simulasi QRIS).
- **FR-5.3 (Penyimpanan Transaksi):** Menekan tombol "Konfirmasi Pemesanan" akan menyimpan record ke tabel `bookings`, `booking_vehicle_items`, dan `booking_item_parts` di Supabase.

### Modul 6: Tiket Pemesanan & Pelacakan Status Real-Time

- **FR-6.1 (Tiket Digital):** Menampilkan Kode Booking unik (misal: `#PSA-20260928-001`), QR Code check-in bengkel, cabang bengkel, dan jadwal.
- **FR-6.2 (Status Induk Pemesanan):** Menampilkan status global transaksi booking (`Menunggu Kedatangan`, `Diproses`, `Selesai`, `Dibatalkan`).
- **FR-6.3 (Pelacakan Independen per Unit):** Setiap unit motor memiliki kartu status terpisah dengan indikator tahapan pengerjaan:
  - Tahap 1: _Menunggu Antrean_
  - Tahap 2: _Sedang Dikerjakan_
  - Tahap 3: _Pengecekan Akhir_
  - Tahap 4: _Selesai_
- **FR-6.4 (Sinkronisasi Realtime):** Tampilan tiket terhubung dengan channel Supabase Realtime postgres changes sehingga perubahan status langsung teranimasi tanpa reload manual.
- **FR-6.5 (Dev Testing Mode Button):** Di pojok kanan bawah layar tiket pelacakan, disediakan Floating Action Button (ikon bug/terminal) yang membuka modal kontrol pengujian. Melalui modal ini, penguji dapat memilih unit motor dan mengubah statusnya langsung ke Supabase guna memvalidasi reaktivitas _real-time tracker_ secara praktis.

---

## 4. Alur Pengguna (End-to-End User Flow)

```
[ 1. Splash Screen ] ─────────────────── Inisialisasi Sesi Supabase
       │
       ├─► (Sesi Kosong / Belum Terverifikasi)
       │         │
       │         ▼
       │   [ 2. Layar Login ]
       │         ├─ Tab 1: Login Password (Email/No. Telp + Password)
       │         ├─ Tab 2: Login via OTP (No. Telp + OTP)
       │         └─ Tombol: "Belum punya akun? Daftar Sekarang"
       │                   │
       │                   ▼
       │             [ 2.1 Layar Sign Up ]
       │                   │ (Isi Nama, No. Telp, Email, Password)
       │                   ▼
       │             [ 2.2 Layar Verifikasi Email ]
       │                   │ (Cek inbox email & klik aktivasi)
       │                   └─► Redirect ke Login setelah sukses
       │
       └─► (Sesi Valid)
                 │
                 ▼
           [ 3. Home Screen / Dashboard ]
                 │
                 └─► CTA: "Booking Servis Sekarang"
                           │
                           ▼
           [ 4. Multi-Vehicle Selection Screen ]
                 ├─ Centang Motor 1 & Motor 2
                 ├─ Opsi: Modal Tambah Motor Baru (No. Polisi, Model, Tahun)
                 └─ Floating Bar: "2 Kendaraan Terpilih" ──► Klik Lanjut
                           │
                           ▼
           [ 5. Konfigurasi Servis per Unit ]
                 ├─ Switcher: [ Tab Unit 1 ]  [ Tab Unit 2 ]
                 ├─ Form Unit 1: Pilih Servis + Sparepart + Tulis Keluhan
                 └─ Form Unit 2: Pilih Servis + Sparepart + Tulis Keluhan
                           │
                           ▼
           [ 6. Jadwal & Lokasi Bengkel Terpadu ]
                 ├─ Pilih Bengkel Resmi PitStop by Servisin Aja
                 ├─ Pilih Tanggal Kedatangan
                 ├─ Pilih Slot Waktu (Penetapan Antrean #01 & #02)
                 └─ Kalkulasi Estimasi Durasi Total
                           │
                           ▼
           [ 7. Ringkasan & Konfirmasi Checkout ]
                 ├─ Rekapitulasi Rincian Biaya per Kendaraan
                 ├─ Akumulasi Total Biaya & Durasi Servis
                 ├─ Pilih Opsi Metode Pembayaran (Mock: Kasir / VA / QRIS)
                 └─ Tombol: "Konfirmasi & Buat Tiket"
                           │
                           ▼
           [ 8. Tiket Booking & Pelacakan Status Real-Time ]
                 ├─ Kode Booking & QR Code Bengkel
                 ├─ Status Induk: "Menunggu Kedatangan"
                 ├─ Tracker Unit 1: Stepper 4 Tahap (Status Real-time)
                 ├─ Tracker Unit 2: Stepper 4 Tahap (Status Real-time)
                 └─ [DEV BUTTON]: Trigger perubahan status unit di Supabase
```

---

## 5. Arsitektur Basis Data (Supabase PostgreSQL Schema)

Skema relasional lengkap untuk mendukung transaksi pemesanan multi-unit, autentikasi profil, status transaksi induk, dan status pelacakan per unit:

```sql
-- 1. PROFIL PENGGUNA
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. GARASI KENDARAAN PENGGUNA
CREATE TABLE public.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    plate_number VARCHAR(15) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CABANG BENGKEL RESMI
CREATE TABLE public.workshops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- 4. KATALOG PAKET SERVIS
CREATE TABLE public.service_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    base_price NUMERIC(12, 2) NOT NULL,
    duration_minutes INT NOT NULL
);

-- 5. KATALOG SUKU CADANG / PELUMAS
CREATE TABLE public.spare_parts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    part_code VARCHAR(50) UNIQUE NOT NULL,
    price NUMERIC(12, 2) NOT NULL
);

-- 6. TRANSAKSI BOOKING INDUK
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_code VARCHAR(30) UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    workshop_id UUID NOT NULL REFERENCES public.workshops(id) ON DELETE RESTRICT,
    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    total_duration_minutes INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL DEFAULT 'BAYAR_DI_BENGKEL',
    status VARCHAR(30) NOT NULL DEFAULT 'Menunggu Kedatangan',
    -- State Induk: 'Menunggu Kedatangan', 'Diproses', 'Selesai', 'Dibatalkan'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. RINCIAN KENDARAAN PEMESANAN (MULTI-VEHICLE ITEMS)
CREATE TABLE public.booking_vehicle_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE RESTRICT,
    service_type_id UUID NOT NULL REFERENCES public.service_types(id) ON DELETE RESTRICT,
    queue_number INT NOT NULL,
    complaints TEXT,
    service_price NUMERIC(12, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Menunggu Antrean',
    -- State Unit: 'Menunggu Antrean', 'Sedang Dikerjakan', 'Pengecekan Akhir', 'Selesai'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. SUKU CADANG TERPILIH PER UNIT KENDARAAN
CREATE TABLE public.booking_item_parts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_vehicle_item_id UUID NOT NULL REFERENCES public.booking_vehicle_items(id) ON DELETE CASCADE,
    part_id UUID NOT NULL REFERENCES public.spare_parts(id) ON DELETE RESTRICT,
    part_price NUMERIC(12, 2) NOT NULL
);

-- 9. AKTIFKAN SUPABASE REALTIME REPLICATION
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
ALTER PUBLICATION supabase_realtime ADD TABLE public.booking_vehicle_items;
```

---

## 6. Arsitektur State Management (Flutter + Riverpod)

Pengelolaan state pemesanan multi-unit, autentikasi, serta komputasi biaya disusun menggunakan pustaka Riverpod dengan arsitektur berbasis fitur (_Feature-First_):

```
lib/
├── core/
│   ├── constants/
│   │   ├── colors.dart            # #FF6600, #3E4347, #FFFFFF, dsb.
│   │   ├── typography.dart        # Heading, Body, Label TextStyles
│   │   └── assets.dart            # Path logo, ikon bendera, ilustrasi
│   ├── theme/
│   │   └── app_theme.dart         # Material 3 Theme Configuration
│   ├── network/
│   │   └── supabase_config.dart   # Inisialisasi SupabaseClient
│   └── routes/
│       └── app_router.dart        # Konfigurasi deklaratif GoRouter
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── logic/auth_controller.dart (NotifierProvider)
│   │   └── presentation/screens/
│   │       ├── splash_screen.dart
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── profile/
│   │   ├── data/profile_repository.dart
│   │   ├── logic/profile_controller.dart
│   │   └── presentation/screens/profile_screen.dart
│   ├── garage/
│   │   ├── data/vehicle_repository.dart
│   │   ├── logic/garage_provider.dart (AsyncNotifier<List<Vehicle>>)
│   │   └── presentation/screens/home_screen.dart
│   ├── booking/
│   │   ├── data/
│   │   │   ├── models/booking_draft_model.dart
│   │   │   └── booking_repository.dart
│   │   ├── logic/
│   │   │   ├── multi_vehicle_selection_provider.dart (Notifier<List<Vehicle>>)
│   │   │   ├── service_configuration_provider.dart (Notifier<Map<String, VehicleConfigDraft>>)
│   │   │   ├── booking_schedule_provider.dart (Notifier<ScheduleDraft>)
│   │   │   ├── booking_summary_computed_provider.dart (Provider)
│   │   │   └── checkout_controller.dart (AsyncNotifier)
│   │   └── presentation/screens/
│   │       ├── vehicle_selection_screen.dart
│   │       ├── service_configuration_screen.dart
│   │       ├── schedule_workshop_screen.dart
│   │       └── summary_checkout_screen.dart
│   └── tracking/
│       ├── data/tracking_repository.dart
│       ├── logic/tracking_stream_provider.dart (StreamProvider.family)
│       ├── logic/dev_simulation_controller.dart
│       └── presentation/screens/
│           ├── booking_ticket_tracking_screen.dart
│           └── widgets/dev_simulation_bottom_sheet.dart
└── main.dart
```

### Logika Provider Kunci

- **`selectedVehiclesProvider`:** Menyimpan daftar objek kendaraan yang dicentang pengguna.
- **`serviceConfigurationProvider`:** Mengelola state berstruktur `Map<String, VehicleConfigDraft>` dengan _key_ ID motor. Memastikan konfigurasi servis, sparepart, dan catatan keluhan tersimpan secara mandiri tanpa bentrok data.
- **`bookingSummaryComputedProvider`:** Provider komputasi reaktif otomatis untuk:
  - Subtotal per unit = $\text{Harga Jasa Servis} + \sum \text{Harga Part Terpilih}$.
  - Total biaya pemesanan = $\sum \text{Subtotal Seluruh Unit}$.
  - Total durasi pengerjaan = $\sum \text{Durasi Seluruh Unit}$.
- **`trackingStreamProvider`:** Mengikat listener Supabase Realtime pada record transaksi pemesanan sehingga perubahan kolom `status` di tabel `bookings` maupun `booking_vehicle_items` langsung direfleksikan ke antarmuka aplikasi.

---

## 7. Master Data Katalog Awal (Seed Data)

### 7.1 Paket Servis

1. **Ganti Pelumas Cepat:** Durasi 15 Menit | Jasa Rp 15.000 | Pengecekan level pelumas dan kuras oli mesin/gardan.
2. **Servis Ringan / Rutin:** Durasi 30 Menit | Jasa Rp 65.000 | Pengecekan filter udara, rem depan-belakang, celah busi, tekanan ban, pelumasan standar.
3. **Servis Berkala / Lengkap (Tune Up):** Durasi 45 Menit | Jasa Rp 110.000 | Servis ringan + infus injektor/karburator cleaner, cek kelistrikan & aki, reset memori ECU.
4. **Servis Transmisi CVT:** Durasi 35 Menit | Jasa Rp 55.000 | Bongkar bak CVT, bersihkan mangkok kampas ganda, cek roller & v-belt, pemberian pelumas CVT khusus.
5. **Perbaikan Khusus & Keluhan Berat:** Durasi 60 Menit | Jasa Rp 95.000 | Penanganan khusus kendala suara kasar mesin, kelistrikan mati total, atau komstir/suspensi aus.

### 7.2 Suku Cadang & Pelumas Cepat

1. **Oli Mesin MPX 2 (0.8L):** Rp 54.000 (Pelumas standar skutik).
2. **Oli Mesin Sintetik SPX 2 (0.8L):** Rp 67.000 (Pelumas sintetik performa tinggi).
3. **Oli Gardan Scooter (120ml):** Rp 18.000 (Pelumas transmisi akhir matik).
4. **Busi Standar NGK / Denso:** Rp 25.000.
5. **Kampas Rem Cakram / Tromol:** Rp 45.000.

---

## 8. Kriteria Penerimaan Sistem (Acceptance Criteria)

| ID        | Modul Fitur                  | Kriteria Lulus (Pass Criteria)                                                                                                    |
| --------- | ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **AC-01** | Splash & Login               | Berhasil menginisialisasi sesi; transisi ke Dual-Tab Login (OTP & Password) dengan kode +62.                                      |
| **AC-02** | Sign Up & Email Verification | Pengguna baru berhasil mendaftar; sistem menolak login sebelum email diverifikasi di Supabase Auth.                               |
| **AC-03** | Seleksi Multi-Kendaraan      | Pengguna dapat memilih $\ge 2$ kendaraan; indikator jumlah motor di bottom bar tampil akurat.                                     |
| **AC-04** | Tambah Motor Cepat           | Menambah kendaraan baru melalui 3 input field teks langsung tersimpan ke Supabase dan masuk ke daftar seleksi.                    |
| **AC-05** | Konfigurasi Mandiri          | Pengguna dapat mengisi paket servis, part, dan catatan keluhan yang berbeda antara Unit 1 dan Unit 2 tanpa tumpang tindih.        |
| **AC-06** | Jadwal & Antrean             | 1 tanggal dan jam kedatangan mengikat seluruh motor; penomoran antrean pit servis (Antrean #01, #02) tertera jelas.               |
| **AC-07** | Ringkasan Biaya              | Layar checkout menyajikan kalkulasi subtotal per unit dan akumulasi total biaya/durasi secara presisi.                            |
| **AC-08** | Status Induk & Tracking Unit | Tiket terbit dengan status induk serta status stepper terpisah per unit yang terbarui otomatis via Supabase Realtime.             |
| **AC-09** | Dev Testing Simulation       | Menekan tombol dev simulator di tiket berhasil memicu perubahan status unit di database dan menggerakkan stepper real-time di UI. |

---

## 9. Kebutuhan Non-Fungsional (Non-Functional Requirements)

1. **Pixel Precision & Safe Layout:** Desain UI presisi sesuai panduan `Design.md`, menerapkan penataan aman (_Safe Area_) dan bebas dari galat visual `RenderFlex overflowed` di segala rasio layar ponsel Android.
2. **Kinerja Reaktif:** State management Riverpod harus mengisolasi rebuild widget hanya pada komponen yang datanya berubah.
3. **Keamanan & Validasi Supabase:** Skema database dilindungi Row Level Security (RLS) di mana pengguna hanya dapat memanipulasi armada dan transaksi miliknya sendiri.

---

## 10. Batasan Sistem (Out of Scope for MVP)

Untuk mempertahankan fokus pada penilaian inti penugasan dalam 7 hari kerja:

- Tidak ada integrasi SDK payment gateway perbankan nyata (transaksi menggunakan mock status).
- Tidak ada pelacakan GPS montir / live map rute bengkel.
- Tidak ada fitur percakapan langsung (_chatting_) dengan teknisi bengkel.

---

## 11. Luaran Wajib Penugasan (Mandatory Deliverables)

1. **Public Link Figma:** Mencakup antarmuka lengkap dari Splash, Login, Home, Multi-Vehicle Selection, Service Configurator, Schedule, Checkout, hingga Ticket & Live Tracking.
2. **Public GitHub Repository:** Kode sumber Flutter dengan Clean Architecture berbasis fitur, Riverpod, dan riwayat commit teratur.
3. **Dokumentasi Instalasi (`README.md`):** Panduan konfigurasi Flutter SDK, setup file environment Supabase, dan perintah instalasi lokal.
4. **Installer APK Siap Pasang:** File rilis `app-release.apk` siap uji pada perangkat Android.
5. **Log Transkrip AI:** Tautan publik riwayat percakapan perumusan instruksi.
