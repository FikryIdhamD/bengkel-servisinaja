# Design System & UI/UX Guidelines (Design.md)

**Nama Produk:** PitStop by Servisin Aja

**Klien / Penugasan:** PT KARYA PUTRA WARDJITO • SERVISIN AJA

**Target Platform:** Flutter Mobile Application (Android & iOS)

**Dokumen Induk PRD:** `PRD.md`

**Aset Sumber & Brand Identity:** Website Resmi Servisin Aja & Tangkapan Layar Aplikasi Acuan

---

## 1. Fondasi Desain Sistem (Design System Foundations)

### 1.1 Palet Warna (Color Tokens)

Mengadopsi identitas visual resmi _Servisin Aja_ dengan rasio kontras tinggi (WCAG AA compliant) untuk kemudahan navigasi di area bengkel maupun penggunaan luar ruangan:

| Token Nama              | Nilai Hex | Peran Visual & Komponen Terkait                                                         |
| ----------------------- | --------- | --------------------------------------------------------------------------------------- |
| `color-primary-orange`  | `#FF6600` | Warna aksi utama: Tombol primer, tab login aktif, border kartu terpilih, stepper aktif. |
| `color-primary-dark`    | `#E05A00` | Keadaan tombol saat ditekan (_pressed/active state_).                                   |
| `color-primary-surface` | `#FFF3EB` | Latar kartu kendaraan terpilih (tint 5% oranye), badge antrean aktif.                   |
| `color-charcoal-dark`   | `#3E4347` | Elemen simpul atas logo monogram "S", teks judul utama (_headline_).                    |
| `color-background`      | `#FFFFFF` | Latar belakang kanvas splash, login, modal sheet, dan container utama.                  |
| `color-surface-grey`    | `#F8F9FA` | Latar belakang field input, bar status, background kartu non-aktif.                     |
| `color-border`          | `#E0E0E0` | Garis tepi (_border_) field input, kartu kendaraan, pemisah seksi form.                 |
| `color-text-primary`    | `#1A1D1F` | Teks judul utama, isi field input, label harga.                                         |
| `color-text-secondary`  | `#757575` | Sub-headline, teks placeholder, teks copyright, label pembantu.                         |
| `color-disabled`        | `#DEDEDE` | Latar tombol saat kondisi form belum tervalidasi.                                       |
| `color-status-waiting`  | `#F59E0B` | Status "Menunggu Antrean" / "Menunggu Kedatangan".                                      |
| `color-status-progress` | `#0284C7` | Status "Sedang Dikerjakan Mekanik".                                                     |
| `color-status-check`    | `#8B5CF6` | Status "Pengecekan Akhir & QC".                                                         |
| `color-status-success`  | `#10B981` | Status "Selesai Siap Diambil", ikon centang validasi.                                   |

### 1.2 Tipografi (Typography Scale)

Sistem tipografi menggunakan font **Plus Jakarta Sans** (alternatif: **Inter**) untuk mendukung estetika modern dan keterbacaan tinggi pada layar mobile:

- **Display Title:** Bold (700), Ukuran 24sp, Line Height 32sp (Judul Splash & Hero Login).
- **Headline 1:** Bold (700), Ukuran 20sp, Line Height 28sp (Judul Halaman Alur Servis, Nomor Antrean).
- **Headline 2:** Semi-Bold (600), Ukuran 16sp, Line Height 24sp (Judul Kartu Kendaraan, Nama Paket Servis).
- **Body 1 (Regular / Medium):** Regular (400) / Medium (500), Ukuran 14sp, Line Height 20sp (Teks form, catatan keluhan, deskripsi layanan).
- **Body 2 (Subtext / Placeholder):** Regular (400), Ukuran 13sp, Line Height 18sp, Warna `#757575`.
- **Button Text:** Semi-Bold (600), Ukuran 14sp, Line Height 20sp, Letter Spacing +0.2px.
- **Caption / Microcopy:** Regular (400), Ukuran 11sp, Line Height 16sp, Warna `#757575` (Info copyright, metadata tiket).

### 1.3 Sistem Spasi & Radius (Spacing & Corner Radius)

- **Grid Dasar:** Kelipatan 4dp dan 8dp (`4dp`, `8dp`, `12dp`, `16dp`, `20dp`, `24dp`, `32dp`).
- **Margin Layar:** `20dp` konsisten di sisi kiri dan kanan (horizontal padding).
- **Radius Komponen:**
  - Form Input & Tombol Utama: `10dp` s/d `12dp`.
  - Kartu Informasi & Tab Container: `12dp` s/d `14dp`.
  - Modal Bottom Sheet: `20dp` (hanya sudut atas kiri dan kanan).
- **Sistem Elevasi (Elevation & Shadows):**
  - `Card Elevation`: `0dp` (menggunakan border solid `1dp solid #E0E0E0` flat design) atau `elevation: 1` dengan bayangan `rgba(0, 0, 0, 0.04)`.
  - `Floating Bar Elevation`: `elevation: 6` dengan bayangan `0px -4px 16px rgba(0, 0, 0, 0.08)`.

---

## 2. Pustaka Komponen UI (Reusable UI Component Library)

### 2.1 Tab Segmented Control (Dual Mode Login Switcher)

Komponen pemilih tab autentikasi yang membedakan metode masuk akun:

- **Wadah Pembungkus (Outer Box):** Tinggi 48dp, padding 4dp, warna latar `#FFFFFF`, border `1dp solid #E0E0E0`, radius 10dp.
- **Status Tab Aktif:** Latar belakang solid oranye `#FF6600`, teks warna putih bold, border radius 8dp.
- **Status Tab Non-Aktif:** Latar transparan, teks abu-abu netral `#757575`, font-weight regular.
- **Feedback Animasi:** Transisi perpindahan indikator aktif menggunakan durasi kurva linear `200ms`.

### 2.2 Input Field Nomor Telepon Indonesia (+62 Prefix)

- **Tinggi & Struktur:** Tinggi 48dp, radius 10dp, border `1dp solid #E0E0E0`, latar belakang `#FFFFFF`.
- **Prefix Kiri:**
  - Ikon Bendera Indonesia 🇮🇩 (rasio 16x11dp).
  - Teks tebal `+62` warna `#1A1D1F`.
  - Garis pembatas vertikal tinggi 24dp warna `#E0E0E0`.
- **Field Input Kanan:** Placeholder _"Masukkan Nomer Telepon Anda"_ warna `#757575` ukuran 13sp, keyboard tipe `TextInputType.phone`.

### 2.3 Input Field Standar & Password

- **Tinggi:** 48dp, border `1dp solid #E0E0E0`, radius 10dp.
- **Field Password:** Dilengkapi ikon mata interaktif di sisi kanan (_eye toggle icon_) untuk mengubah status _obscureText_ (tampil/sembunyi).
- **State Fokus:** Border berubah menjadi warna oranye `#FF6600` dengan ketebalan 1.5dp.

### 2.4 Tombol Utama Penuh (Full-Width Primary Button)

- **Tinggi:** 48dp (memenuhi target sentuh aksesibilitas minimum).
- **State Aktif:** Warna latar `#FF6600`, teks putih tebal, radius 10dp, efek ripple saat disentuh.
- **State Disabled:** Warna latar `#DEDEDE`, teks putih `#FFFFFF`, kursor dinonaktifkan.
- **State Loading:** Menampilkan `CircularProgressIndicator` ukuran 20dp warna putih di bagian tengah.

### 2.5 Kartu Seleksi Kendaraan (Multi-Vehicle Selectable Card)

- **Dimensi & Border:** Padding 16dp, radius 12dp, border default `1dp solid #E0E0E0`.
- **State Terpilih (Checked):** Border berubah menjadi `1.5dp solid #FF6600`, warna latar berubah menjadi `#FFF3EB`.
- **Elemen Konten:**
  - Badge Nomor Polisi (misal: `B 1234 ABC`) dengan latar abu-abu gelap.
  - Nama Model & Tahun Motor (misal: `Honda Vario 160 • 2023`).
  - Checkbox lingkaran di sudut kanan atas dengan tanda centang oranye.

### 2.6 Tab Switcher Kendaraan (Sticky Horizontal Header)

Solusi UX untuk mengatasi formulir bertingkat yang melelahkan (_anti form-fatigue_):

- Diletakkan melayang di bawah app bar (_sticky top_).
- Menyajikan deretan kartu tab unit yang dipilih: `[ Unit 1: Vario 160 ]  [ Unit 2: BeAT FI ]`.
- **Status Tab:** Tab aktif diberi garis tebal oranye `#FF6600` di bagian bawah dan badge ikon centang hijau kecil saat form unit tersebut selesai dikonfigurasi.

### 2.7 Floating Dev Testing Button (Simulator Status Real-Time)

Komponen pengujian fungsionalitas Supabase Realtime bagi tim penilai teknis:

- **Bentuk & Posisi:** Lingkaran melayang diameter 48dp di sudut kanan bawah layar tiket pelacakan.
- **Gaya Visual:** Warna latar `#3E4347` dengan ikon terminal/bug warna oranye `#FF6600`.
- **Interaksi:** Memunculkan _modal bottom sheet_ untuk mengubah status unit di database secara instan.

---

## 3. Spesifikasi Tata Letak Layar (Screen-by-Screen Specifications)

### 3.1 Layar 1: Splash Screen

- **Latar Belakang:** Latar putih bersih (`#FFFFFF`).
- **Zona Tengah Layar (_Center-Screen_):**
  - Logo Monogram "S" Servisin Aja: Simpul atas abu-abu gelap `#3E4347` bersilangan dengan simpul bawah oranye terang `#FF6600`.
  - Teks Merek: **"Servisinaja"** warna oranye bold tepat di bawah simbol logo.
  - Slogan / Tagline: _"Vehicle at Your Fingertips"_ warna gelap ukuran 12sp reguler.
- **Zona Dasar Layar (_Bottom-Footer_):**
  - Teks Hak Cipta: _"© 2026 Servisin Aja. All rights reserved."_ warna `#757575` ukuran 11sp.
- **Logika Transisi:** Durasi tayang 1.5 detik. Sistem mengecek sesi Supabase:
  - Jika ada sesi aktif $\rightarrow$ Navigasi ke Layar Beranda (Home).
  - Jika sesi kosong $\rightarrow$ Navigasi ke Layar Login.

### 3.2 Layar 2: Layar Login (Dual-Tab OTP & Password)

- **Header Atas:**
  - Logo mini monogram "S" bersanding dengan teks merek "Servisin Aja" di sudut kiri atas.
- **Grup Judul Layar (_Headline Group_):**
  - Baris 1: Teks **"Masuk ke"** (Font Bold, 24sp, warna hitam `#1A1D1F`).
  - Baris 2: Teks **"Akun anda"** (Font Bold, 24sp, warna oranye `#FF6600`).
  - Sub-teks: _"Masukkan nomor telepon dan kata sandi anda"_ warna abu-abu `#757575` ukuran 13sp.
- **Dual-Tab Switcher Container:**
  - Tab Kiri: **"Login via OTP"**.
  - Tab Kanan: **"Login Password"**.
  - Tab aktif bersolid oranye `#FF6600`, teks putih; tab non-aktif transparan, border abu-abu.
- **Form Kontrol (Kondisional Tab):**
  - _Input Nomor Telepon:_ Selalu tampil di kedua tab. Format permanen `+62` bendera 🇮🇩.
  - _Input Password:_ Hanya tampil jika tab **"Login Password"** aktif. Dilengkapi ikon mata visibilitas.
- **Tombol Submit:** Tombol penuh teks **"Masuk"** (disabled abu-abu jika input belum valid, oranye saat aktif).
- **Aksesori & Navigasi Tambahan:**
  - Teks Tautan Bawah: _"Belum punya akun? "_ + _"Daftar Sekarang"_ (warna oranye tebal) mengarah ke Layar Registrasi.
  - Ikon Pengaturan: Tombol gerigi (_settings gear icon_) di sudut kanan bawah layar.

### 3.3 Layar 3: Layar Registrasi Akun (Sign Up) & Verifikasi Email

- **Header:** Tombol kembali (_back arrow_) dan judul halaman "Daftar Akun Baru".
- **Formulir Input Registrasi:**
  1. _Nama Lengkap:_ Placeholder _"Masukkan nama lengkap sesuai KTP"_.
  2. _Nomor Telepon:_ Prefix `+62` permanen.
  3. _Email:_ Input teks format email valid.
  4. _Kata Sandi:_ Field password dengan indikator kekuatan kata sandi minimal 6 karakter.
- **Tombol Submit:** "Daftar Akun" warna oranye.
- **Layar Status Verifikasi Email (Modal / Halaman Transisi):**
  - Ilustrasi surat/amplop digital.
  - Judul: "Cek Email Anda".
  - Deskripsi: _"Tautan konfirmasi telah dikirimkan ke alamat email Anda. Silakan klik verifikasi sebelum masuk ke aplikasi."_
  - Tombol: "Kembali ke Halaman Masuk".

### 3.4 Layar 4: Beranda & Garasi Pengguna (Home Screen)

- **Top Bar:** Avatar pengguna, teks "Halo, [Nama Pengguna]", status verifikasi akun, dan ikon lonceng notifikasi.
- **Banner Promosi / Edukasi:** Kartu bergradasi oranye menampilkan pesan: _"Servis Banyak Motor Sekaligus Lebih Praktis di PitStop by Servisin Aja"_.
- **Seksi Garasi Saya (_My Garage Carousel_):** Menampilkan kartu motor yang terdaftar milik pengguna.
- **Tombol Aksi Utama (Hero CTA):** Tombol balok besar dengan ikon kunci inggris bertuliskan **"Booking Servis Multi-Unit Sekarang"**.

### 3.5 Layar 5: Seleksi Multi-Kendaraan (Product Challenge 1)

- **Judul Seksi:** "Pilih Kendaraan Servis" dengan deskripsi _"Centang motor yang ingin diservis dalam sesi pemesanan ini"_.
- **Daftar Armada Pengguna:**
  - Deretan kartu kendaraan dengan checkbox interaktif di sudut kanan atas.
  - Menampilkan plat nomor, tipe motor, dan tahun pembuatan.
- **Kartu Registrasi Motor Instan:**
  - Kartu berpola garis putus-putus (_dashed border_) berlabel **"+ Tambah Motor Baru"**.
  - _Modal Bottom Sheet Tambah Motor:_
    - Input 1 (Text): Nomor Polisi (misal: `B 1234 ABC`).
    - Input 2 (Text): Merk & Model Motor (misal: `Honda Vario 160`).
    - Input 3 (Text): Tahun Pembuatan (misal: `2023`).
    - Tombol "Simpan ke Garasi & Pilih" (langsung menyimpan ke Supabase dan otomatis mencentang unit).
- **Floating Bottom Bar:**
  - Label teks: _"X Kendaraan Dipilih"_.
  - Tombol: _"Lanjut ke Layanan"_ (otomatis disabled jika 0 kendaraan dicentang).

### 3.6 Layar 6: Konfigurasi Servis & Keluhan per Unit (Product Challenge 2)

- **Sticky Unit Switcher (Bilah Atas):** Tab horizontal menampilkan seluruh motor yang dicentang pada langkah sebelumnya (misal: `[ Unit 1: Vario 160 ]` dan `[ Unit 2: BeAT FI ]`).
- **Form Konfigurasi Dinamis (Tergantung Tab Unit yang Aktif):**
  1. _Pilihan Paket Servis Utama (Radio List):_
  - Ganti Pelumas Cepat (15 Menit - Rp 15.000)
  - Servis Ringan / Rutin (30 Menit - Rp 65.000)
  - Servis Berkala / Tune Up (45 Menit - Rp 110.000)
  - Servis Transmisi CVT (35 Menit - Rp 55.000)
  - Perbaikan Khusus & Keluhan Berat (60 Menit - Rp 95.000)
  2. _Pilihan Suku Cadang & Pelumas Cepat (Checkbox / Filter Chips):_
  - Oli Mesin MPX 2 (0.8L) - Rp 54.000
  - Oli Mesin Sintetik SPX 2 (0.8L) - Rp 67.000
  - Oli Gardan Scooter (120ml) - Rp 18.000
  - Busi Standar - Rp 25.000
  - Kampas Rem - Rp 45.000
  3. _Field Keluhan & Catatan Khusus:_
  - Form isian bebas (_multi-line text area_ min tinggi 100dp) dengan placeholder: _"Tuliskan gejala kerusakan, kendala mesin, atau keluhan khusus teknisi pada motor ini..."_.
- **Indikator Validasi Tab:** Tab unit akan mendapatkan centang hijau jika paket servis telah ditentukan.
- **Bilah Bawah:** Tombol "Lanjut ke Jadwal Bengkel" hanya aktif jika seluruh unit yang dipilih sudah tuntas dikonfigurasi.

### 3.7 Layar 7: Jadwal, Lokasi Bengkel & Penomoran Antrean (Product Challenge 3)

- **Pemilihan Cabang Bengkel:** Kartu pilihan cabang bengkel resmi PitStop by Servisin Aja dilengkapi detail alamat kota.
- **Pemilihan Tanggal Kedatangan:** _Horizontal calendar strip_ menampilkan 7 hari ke depan (nama hari, tanggal, dan bulan).
- **Pemilihan Slot Jam Kedatangan:** Grid tombol jam (09:00, 10:00, 11:00, 13:00, 14:00, 15:00).
- **Informasi Penomoran Antrean Pit Transparan:**
  - Box informasi berlatar `#FFF3EB` menampilkan penomoran antrean berurutan pada jam yang sama:
    - _Motor 1 (Vario 160):_ Jam Kedatangan 10:00 WIB • **Nomor Antrean #01**
    - _Motor 2 (BeAT FI):_ Jam Kedatangan 10:00 WIB • **Nomor Antrean #02**
- **Kalkulasi Durasi Terpadu:** Box ringkasan menampilkan estimasi durasi total seluruh armada (misal: "Est. Total 75 Menit Pengerjaan Antrean").

### 3.8 Layar 8: Ringkasan Pemesanan & Mock Checkout

- **Ringkasan Reservasi:** Nama bengkel cabang, tanggal, dan slot jam kedatangan.
- **Rincian Transparan per Kendaraan:**
  - _Kartu Rincian Unit 1:_ Paket Servis + Part Tambahan + Subtotal Biaya Unit 1.
  - _Kartu Rincian Unit 2:_ Paket Servis + Part Tambahan + Subtotal Biaya Unit 2.
- **Kalkulasi Akhir:** Akumulasi total biaya pengerjaan dan suku cadang secara keseluruhan.
- **Pilihan Opsi Pembayaran (Frontend Radio Button):**
  1. _Bayar di Bengkel (Kasir)_ - Pilihan Default.
  2. _Simulasi Transfer Virtual Account (BCA / Mandiri / BRI)_.
  3. _Simulasi Dompet Digital / QRIS Universal_.
- **Tombol Konfirmasi:** Tombol lebar oranye bertuliskan **"Konfirmasi Pemesanan & Buat Tiket"**.

### 3.9 Layar 9: Tiket Booking & Pelacakan Status Real-Time (Product Challenge 4)

- **Kepala Tiket (_Ticket Header_):**
  - Nomor Transaksi Booking unik (misal: `#PSA-20260928-001`).
  - QR Code digital terpusat untuk proses validasi _check-in_ fisik oleh mekanik di bengkel.
  - Status Induk Pemesanan: Badge status (`Menunggu Kedatangan`, `Diproses`, `Selesai`).
- **Kartu Pelacak Status Independen per Unit Motor:**
  Masing-masing motor memiliki panel kartu mandiri dengan 4 tahap _stepper progress_:
  - _Tahap 1:_ **Menunggu Antrean** (Icon jam, badge kuning)
  - _Tahap 2:_ **Sedang Dikerjakan** (Icon kunci inggris, badge biru info)
  - _Tahap 3:_ **Pengecekan Akhir & QC** (Icon checklist inspeksi)
  - _Tahap 4:_ **Selesai & Siap Diambil** (Icon motor siap, badge hijau sukses)
- **Karakteristik Real-Time:** Widget terikat pada _StreamProvider_ Supabase Realtime; posisi stepper bergeser secara live dengan animasi transisi tanpa memuat ulang layar (_no screen reload_).
- **Floating Action Button (Dev Testing Simulation):** Tombol melayang di sudut kanan bawah untuk membuka modal simulasi perubahan status pengerjaan.

### 3.10 Modal Dev Testing Simulation (Bottom Sheet Pengujian)

- **Tujuan:** Mempermudah tim penilai memvalidasi aspek reaktivitas _real-time status tracker_ secara langsung di aplikasi APK.
- **Elemen Kontrol:**
  - Dropdown Pemilih Motor (Pilih Unit 1 atau Unit 2).
  - Tombol Status:
    - `Set ke 'Menunggu Antrean'`
    - `Set ke 'Sedang Dikerjakan'`
    - `Set ke 'Pengecekan Akhir'`
    - `Set ke 'Selesai'`
  - Eksekusi: Melakukan update query ke tabel `booking_vehicle_items` di Supabase untuk memicu event _postgres changes_ secara instan.

---

## 4. Prinsip UX, Tata Letak Aman & Aksesibilitas

1. **Safe Layout & Anti-Overflow Guarantee:** Seluruh tata letak formulir dan ringkasan dibungkus menggunakan `SingleChildScrollView` atau `ListView` dengan `BouncingScrollPhysics`. Hal ini menjamin aplikasi terbebas 100% dari galat visual `RenderFlex overflowed` (garis belang kuning-hitam) pada perangkat Android dengan rasio layar berbeda.
2. **Touch Target Accessibility:** Seluruh tombol navigasi, checkbox, radio button, dan tab memiliki area sentuh minimal 48 x 48dp untuk mencegah salah klik saat pengguna mengoperasikan ponsel.
3. **Form Ergonomics:** Field isian keluhan kerusakan menggunakan jenis keyboard multi-line dengan aksi keyboard selesai (_done action_), serta dilengkapi penghitung karakter dinamis (_character counter_).
4. **Feedback Interaksi Visual:** Setiap elemen tombol memiliki respon sentuh (_ink ripple feedback_) serta status disabled yang kontras sehingga pengguna mengetahui secara tepat kapan data form sudah valid untuk dilanjutkan.
