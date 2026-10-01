# Product Requirement Document (PRD)

**Nama Produk:** PitStop by Servisin Aja  
**Klien / Penugasan:** PT KARYA PUTRA WARDJITO • SERVISIN AJA  
**Posisi Evaluasi:** Mobile Developer & UI/UX Designer  
**Target Platform:** Mobile Application (Flutter — Android & iOS)  
**Teknologi & Arsitektur:** Flutter 3.x, Dart 3.x, Riverpod (State Management), GoRouter (Declarative Routing), Supabase (Auth, PostgreSQL DB, Realtime WebSocket)  
**Dokumen Desain Terkait:** `Design.md` *(Design System, Komponen, dan Spesifikasi UI/UX)*  
**Versi Dokumen:** 2.0 (Final Release State)  

---

## 1. Ikhtisar Produk & Latar Belakang Masalah

Pada aplikasi purna jual servis kendaraan roda dua terkemuka di industri saat ini (seperti aplikasi referensi Honda MotorkuX), alur pemesanan umumnya memiliki batasan mendasar: **hanya mengizinkan 1 unit motor per transaksi pemesanan**. 

Keterbatasan ini menciptakan friksi tinggi (*high friction*) bagi pelanggan yang memiliki lebih dari satu armada kendaraan di rumah tangga, maupun bagi staf operasional UMKM yang mengelola kendaraan kurir atau logistik. Pengguna terpaksa mengulang formulir dari awal berkali-kali untuk setiap motor.

**PitStop by Servisin Aja** memecahkan masalah ini melalui fitur unggulan **Multi-Vehicle Booking in One Flow**. Melalui inovasi ini, pengguna dapat:
1. Memilih lebih dari satu kendaraan (misal: Honda Vario 160 & Yamaha NMAX 155) dalam satu keranjang pemesanan.
2. Mengonfigurasi kebutuhan jenis servis, paket suku cadang/oli, dan catatan keluhan yang berbeda per unit secara mandiri tanpa membuat formulir rumit.
3. Menentukan lokasi bengkel resmi dan satu slot jadwal kedatangan terpadu dengan penomoran antrean pit servis yang transparan.
4. Memperoleh tiket digital terpadu dengan kemampuan melacak progres pengerjaan masing-masing unit motor secara independen dan *real-time*.

---

## 2. Ruang Lingkup Aplikasi & 4 Pilar Tantangan Utama

Sesuai kriteria dokumen penugasan teknis (*Technical & UI/UX Assessment*), aplikasi mencakup alur lengkap dari Splash, Autentikasi, 4 Layar Navigasi Utama, Alur Booking Multi-Kendaraan, hingga Tiket & Pelacakan Realtime:

| Pilar / Modul | Deskripsi & Implementasi Fungsional |
| :--- | :--- |
| **Pilar 1: Multi-Vehicle Selection & Management** | • Daftar kendaraan pengguna dimuat dinamis dari database Supabase.<br>• Seleksi multi-unit menggunakan checkbox interaktif dengan ringkasan jumlah kendaraan di floating action bar.<br>• Modal sheet instan *"Tambah Motor Baru"* langsung di alur booking (Plat Nomor, Model/Tipe, Tahun) tanpa meninggalkan alur transaksi.<br>• **Fitur Evaluator:** Saat pengguna baru mendaftar (Register), sistem secara otomatis meng-generate 2 kendaraan default (`Honda Vario 160` & `Yamaha NMAX 155`) agar penguji dapat langsung menguji pemesanan multi-unit tanpa repot. |
| **Pilar 2: Keluhan & Servis Spesifik per Unit** | • *Sticky Unit Switcher Tab* di bagian atas layar untuk berpindah antar kendaraan terpilih secara instan.<br>• Konfigurasi mandiri per unit kendaraan:<br>&nbsp;&nbsp;- Pilihan 5 paket servis standar (Ganti Oli Cepat, Servis Ringan, Servis Berkala Tune-up, Servis CVT, Perbaikan Khusus).<br>&nbsp;&nbsp;- Pilihan suku cadang & pelumas cepat (Oli MPX2/SPX2, Oli Gardan, Busi, Kampas Rem).<br>&nbsp;&nbsp;- Catatan keluhan dan kendala bebas (*free-text complaints*) spesifik per unit.<br>• Validasi terpadu: Semua unit wajib memiliki minimal 1 paket servis terpilih sebelum melanjutkan. |
| **Pilar 3: Jadwal & Form Booking Terpadu** | • Pemilihan 1 cabang bengkel resmi PitStop by Servisin Aja.<br>• Pemilihan 1 tanggal servis dan 1 slot jam kedatangan yang mengikat seluruh kendaraan terpilih.<br>• Penomoran antrean pit otomatis berurutan pada jam yang sama (contoh: Unit 1 Antrean Pit #01, Unit 2 Antrean Pit #02).<br>• Kalkulasi akumulasi durasi estimasi servis seluruh unit secara transparan.<br>• Kalkulasi ringkasan rincian biaya (Jasa + Suku Cadang per unit).<br>• Opsi metode pembayaran: *Bayar di Bengkel (Kasir)*, *Simulasi Virtual Account (BCA/Mandiri/BRI)*, dan *Simulasi QRIS*. |
| **Pilar 4: Tiket Konfirmasi & Status Pelacakan** | • Tiket servis terpadu dengan Kode Booking unik (`#PSA-YYYYMMDD-XXX`) dan QR Code check-in bengkel.<br>• Status transaksi induk booking (`Menunggu Kedatangan`, `Diproses`, `Selesai`, `Dibatalkan`).<br>• Pelacakan status pengerjaan bertingkat (*4-stage stepper*) independen per unit motor: `Menunggu Antrean` ➔ `Sedang Dikerjakan` ➔ `Pengecekan Akhir` ➔ `Selesai`.<br>• Sinkronisasi reaktif berbasis **Supabase Realtime**.<br>• **Dev Simulation Floating Button & Bottom Sheet:** Alat uji khusus bagi tim penilai untuk mensimulasikan perubahan status montir/mekanik per kendaraan langsung ke database dan memverifikasi reaktivitas UI secara langsung. |
| **Layar Navigasi Utama (Main Shell Layout)** | • *Beranda (Home):* Profil singkat, pita lokasi, promo carousel interaktif, garasi ringkas, rekomendasi bengkel terdekat, dan Center Docked FAB Booking.<br>• *Garasi (Garage):* Manajemen seluruh armada, tambah kendaraan, dan halaman rincian kendaraan (`/vehicle/:id`) lengkap dengan riwayat servis.<br>• *Tiket (Tickets):* Riwayat booking aktif dan selesai.<br>• *Profil (Profile):* Detail akun pengguna, status verifikasi telepon via OTP, navigasi ke Pusat Bantuan, Kebijakan Privasi, dan Tentang Servisin Aja. |
| **Layar Pendukung (Bonus Points)** | • Layar Notifikasi (`/notifications`) dengan riwayat status servis dan info promo.<br>• Direktori Daftar Bengkel (`/workshop-list`) dan Detail Profil Bengkel (`/workshop/:id`) dengan jam operasional, fasilitas, dan rating ulasan. |

---

## 3. Spesifikasi Fungsional Rinci (Functional Requirements)

### 3.1 Modul Autentikasi & Akun
- **FR-AUTH-01 (Splash & Sesi):** Mengecek status sesi pengguna via Supabase Auth. Jika ada sesi aktif, otomatis mengarahkan ke `/home`. Jika belum, mengarahkan ke `/login`.
- **FR-AUTH-02 (Dual-Tab Login):**
  - *Tab Login Password:* Memvalidasi kombinasi Email / Nomor Telepon dan Password.
  - *Tab Login OTP:* Mengirimkan simulasi/kode OTP ke nomor ponsel berawalan `+62`.
- **FR-AUTH-03 (Pendaftaran Akun & Default Vehicle Seeding):** 
  - Form registrasi mewajibkan input: Nama Lengkap, Nomor Telepon, Email, dan Password.
  - Saat pendaftaran berhasil, sistem membuat record di tabel `profiles` dan secara otomatis memasukkan 2 unit motor starter (`Honda Vario 160` - `B 1234 ABC` dan `Yamaha NMAX 155` - `B 5678 XYZ`) ke tabel `vehicles` untuk memudahkan penguji menjalankan skenario multi-booking.
- **FR-AUTH-04 (Verifikasi Email & Telepon):** Dialog aktivasi akun via Supabase email verification, serta verifikasi nomor HP via OTP di halaman profil.

### 3.2 Modul Garasi (Garage Management)
- **FR-GAR-01 (Daftar Armada):** Menampilkan seluruh kendaraan pengguna dengan kartu visual plat nomor, nama motor, tahun, dan tag status servis terakhir.
- **FR-GAR-02 (Tambah Motor Baru):** Modal sheet input teks sederhana (Plat Nomor, Model Kendaraan, Tahun Pembuatan) yang langsung tersimpan ke Supabase.
- **FR-GAR-03 (Detail Kendaraan):** Halaman rincian kendaraan menampilkan spesifikasi motor, nomor rangka/mesin, dan linimasa riwayat servis berkala.

### 3.3 Modul Alur Multi-Vehicle Booking
- **FR-BKG-01 (Seleksi Multi-Unit):** Checkbox multi-pilih dengan proteksi minimal 1 kendaraan terpilih. Floating action bar menampilkan counter: *"X Kendaraan Terpilih"*.
- **FR-BKG-02 (Konfigurasi Independen per Unit):**
  - Menggunakan Riverpod `serviceConfigurationProvider` berstruktur `Map<String, VehicleConfigDraft>` berdasar vehicle ID.
  - Form tidak saling menimpa (*isolated state*).
  - 5 Katalog Servis Standar:
    1. *Ganti Pelumas Cepat (Fast Pit)*: 15 menit | Rp 15.000
    2. *Servis Ringan / Rutin*: 30 menit | Rp 65.000
    3. *Servis Berkala / Lengkap (Tune Up)*: 45 menit | Rp 110.000
    4. *Servis Transmisi CVT*: 35 menit | Rp 55.000
    5. *Perbaikan Khusus & Keluhan Berat*: 60 menit | Rp 95.000
  - Katalog Sparepart: Oli Mesin MPX 2 (Rp 54.000), SPX 2 (Rp 67.000), Oli Gardan (Rp 18.000), Busi (Rp 25.000), Kampas Rem (Rp 45.000).
  - Catatan teks keluhan khusus per unit.
- **FR-BKG-03 (Jadwal, Bengkel & Antrean Terpadu):**
  - Pengguna memilih 1 bengkel cabang resmi dan 1 tanggal kedatangan.
  - Memilih slot waktu kedatangan (misal: `09:00 - 10:00`).
  - Sistem mengalokasikan nomor antrean pit berurutan per unit (`Unit 1: Pit #01`, `Unit 2: Pit #02`).
  - Menghitung total estimasi durasi servis akumulatif.
- **FR-BKG-04 (Ringkasan & Checkout):**
  - Breakdown rincian biaya transparan per kendaraan (jasa + part).
  - Pilihan metode pembayaran (*Bayar di Bengkel / Kasir*, *Virtual Account*, *QRIS*).
  - Menyimpan transaksi ke tabel `bookings`, `booking_vehicle_items`, dan `booking_item_parts` di Supabase.

### 3.4 Modul Tiket & Pelacakan Status Real-Time
- **FR-TRK-01 (Tiket Terpadu):** Menampilkan Kode Booking unik, QR Code bengkel, waktu servis, lokasi bengkel, dan rincian total pembayaran.
- **FR-TRK-02 (Pelacakan Progres per Unit):** Kartu status mandiri per kendaraan dengan stepper visual 4 tahap:
  1. `Menunggu Antrean` *(Oranye)*
  2. `Sedang Dikerjakan` *(Biru)*
  3. `Pengecekan Akhir` *(Ungu)*
  4. `Selesai` *(Hijau)*
- **FR-TRK-03 (Supabase Realtime Stream):** Menggunakan `StreamProvider` yang mendengarkan perubahan realtime PostgreSQL pada tabel `bookings` dan `booking_vehicle_items`.
- **FR-TRK-04 (Dev Simulation Bottom Sheet):** Floating button alat uji pengembang di pojok kanan bawah tiket. Penguji dapat memilih kendaraan mana yang ingin diubah statusnya, lalu status terupdate langsung ke Supabase dan UI tiket teranimasi secara reaktif.

---

## 4. Arsitektur Data: Dynamic vs Static Dummy

Untuk transparansi teknis dan kemudahan pengujian, berikut pembagian data dinamis (Supabase) dan data tiruan (dummy/statis):

| Komponen / Fitur | Status Data | Sumber & Keterangan |
| :--- | :--- | :--- |
| **Autentikasi Akun** | **Dinamis** | Terhubung penuh dengan Supabase Auth (Sign Up, Sign In, Session). |
| **Garasi Kendaraan** | **Dinamis** | Tabel `vehicles` di Supabase. CRUD kendaraan tersimpan permanen per user. Auto-seeding 2 motor saat register. |
| **Booking & Checkout** | **Dinamis** | Tabel `bookings`, `booking_vehicle_items`, `booking_item_parts` di Supabase. |
| **Tracking Stepper & Dev Simulator** | **Dinamis** | Realtime stream dari Supabase. Dev Simulator memutasi tabel Supabase secara langsung. |
| **Katalog Servis & Suku Cadang** | **Statis / Master Data** | Disediakan via in-memory provider berbasis standar harga Servisin Aja untuk memastikan keandalan saat offline. |
| **Daftar Bengkel Resmi** | **Semi-Dinamis / Seed** | Data master bengkel resmi Jabodetabek (`dummy_workshops.dart`) dengan rating dan ulasan. |
| **Banner Promosi & Edukasi** | **Statis Dummy** | Banner carousel di HomeScreen dengan materi promo Servisin Aja. |
| **Notifikasi** | **Statis Dummy** | Data notifikasi mock (`dummy_notifications.dart`) untuk simulasi notifikasi masuk. |
| **Halaman Sekunder Profil** | **Statis Dummy** | Pusat Bantuan, Kebijakan Privasi, dan Tentang Servisin Aja. |

---

## 5. Skema Basis Data PostgreSQL (Supabase)

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

-- 4. TRANSAKSI INDUK BOOKING
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_code VARCHAR(30) UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    workshop_id VARCHAR(50) NOT NULL,
    workshop_name VARCHAR(100) NOT NULL,
    booking_date DATE NOT NULL,
    booking_time VARCHAR(20) NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    total_duration_minutes INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL DEFAULT 'BAYAR_DI_BENGKEL',
    status VARCHAR(30) NOT NULL DEFAULT 'Menunggu Kedatangan',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. DETAIL KENDARAAN PEMESANAN (MULTI-VEHICLE ITEMS)
CREATE TABLE public.booking_vehicle_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE RESTRICT,
    vehicle_name VARCHAR(100) NOT NULL,
    plate_number VARCHAR(20) NOT NULL,
    service_type_name VARCHAR(100) NOT NULL,
    queue_number INT NOT NULL,
    complaints TEXT,
    service_price NUMERIC(12, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Menunggu Antrean',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. SUKU CADANG PER KENDARAAN
CREATE TABLE public.booking_item_parts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_vehicle_item_id UUID NOT NULL REFERENCES public.booking_vehicle_items(id) ON DELETE CASCADE,
    part_name VARCHAR(100) NOT NULL,
    part_price NUMERIC(12, 2) NOT NULL
);

-- 7. REPLIKASI SUPABASE REALTIME
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
ALTER PUBLICATION supabase_realtime ADD TABLE public.booking_vehicle_items;
```

---

## 6. Kriteria Kualitas & Verifikasi Pengujian (Acceptance Checklist)

- [x] **AC-01 (Splash & Autentikasi):** Splash screen branding Servisin Aja, dual-tab login (+62 prefix), register auto-provisioning 2 motor starter.
- [x] **AC-02 (Pilar 1 - Multi-Vehicle Selection):** Pilihan multi-kendaraan dengan visual checkbox, penambahan motor instan via modal sheet.
- [x] **AC-03 (Pilar 2 - Konfigurasi Spesifik Unit):** Sticky unit switcher tab, konfigurasi independen 5 paket servis, checklist suku cadang, dan catatan keluhan bebas.
- [x] **AC-04 (Pilar 3 - Jadwal & Antrean Terpadu):** 1 jadwal terpadu, antrean pit sekuensial (#01 & #02), kalkulasi akumulatif total durasi & estimasi biaya.
- [x] **AC-05 (Pilar 4 - Tiket & Pelacakan):** Tiket booking dengan QR Code, status induk, pelacakan bertingkat per unit via Supabase Realtime.
- [x] **AC-06 (Dev Simulation Button):** Floating button uji di halaman tiket untuk mengubah status unit motor langsung dan melihat reaktivitas UI seketika.
- [x] **AC-07 (Safe Layout & Responsif):** Tidak ada overflow visual (`RenderFlex overflowed`) pada beragam rasio resolusi perangkat Android.
