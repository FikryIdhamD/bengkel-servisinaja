# Design System & UI/UX Guidelines (Design.md)

**Nama Produk:** PitStop by Servisin Aja  
**Klien / Penugasan:** PT KARYA PUTRA WARDJITO • SERVISIN AJA  
**Posisi Evaluasi:** Mobile Developer & UI/UX Designer  
**Target Platform:** Flutter Mobile Application (Android & iOS)  
**Dokumen Induk PRD:** `PRD.md`  
**Referensi Brand & Visual:** Website Resmi Servisin Aja ([www.servisinaja.id](https://www.servisinaja.id)) & Alur Industri MotorkuX  
**Versi Dokumen:** 2.0 (Final Release State)  

---

## 1. Fondasi Desain Sistem (Design System Foundations)

### 1.1 Brand Identity & Color Tokens

Palet warna mengadopsi identitas visual resmi *Servisin Aja* dengan kombinasi warna oranye energik dan abu-abu arang berkarakter otomotif modern, memenuhi standar kontras WCAG AA:

| Token Warna | Nilai Hex | Peran & Penggunaan Komponen |
| :--- | :--- | :--- |
| `AppColors.primaryOrange` | `#FF6600` | Warna brand utama: Tombol primer, tab aktif, border elemen terpilih, ikon aksen, indikator stepper aktif. |
| `AppColors.primaryDark` | `#E05A00` | State tombol ditekan (*active/pressed state*), header aksen gelap. |
| `AppColors.primarySurface` | `#FFF3EB` | Latar kartu kendaraan terpilih (tint 5% oranye), badge antrean pit, container ikon aksen. |
| `AppColors.charcoalDark` | `#3E4347` | Aksen monogram logo 'S', teks judul tebal, plat nomor kendaraan. |
| `AppColors.textPrimary` | `#1A1D1F` | Teks judul utama (*headline*), isi field input, harga item. |
| `AppColors.textSecondary` | `#757575` | Sub-headline, placeholder, label waktu pengerjaan, teks pembantu. |
| `AppColors.background` | `#FFFFFF` | Latar kanvas utama, kartu, modal sheet. |
| `AppColors.surfaceGrey` | `#F8F9FA` | Latar belakang field input, bar status, background tab non-aktif. |
| `AppColors.border` | `#E0E0E0` | Garis tepi (*border*) field input, pemisah list, kartu default. |
| `AppColors.statusWaiting` | `#F59E0B` | Status *"Menunggu Antrean"* / *"Menunggu Kedatangan"* (Amber). |
| `AppColors.statusProgress`| `#0284C7` | Status *"Sedang Dikerjakan Mekanik"* (Sky Blue). |
| `AppColors.statusCheck` | `#8B5CF6` | Status *"Pengecekan Akhir & QC"* (Purple). |
| `AppColors.statusSuccess` | `#10B981` | Status *"Selesai Siap Diambil"*, centang validasi akun (Emerald Green). |

### 1.2 Skala Tipografi (Typography Scale)

Menggunakan keluarga font **Plus Jakarta Sans** (fallback: **Inter**) untuk memastikan keterbacaan tinggi di berbagai resolusi layar ponsel:

- **Display Title:** Bold (700), 24sp / Line Height 32sp (Hero splash & judul onboarding).
- **Headline 1:** Bold (700), 20sp / Line Height 28sp (Judul halaman alur servis, nomor booking, nama bengkel).
- **Headline 2:** Semi-Bold (600), 16sp / Line Height 24sp (Judul kartu kendaraan, nama paket servis, subjudul seksi).
- **Body 1 (Regular / Medium):** Regular (400) / Medium (500), 14sp / Line Height 20sp (Teks form, catatan keluhan, deskripsi layanan).
- **Body 2 (Subtext / Caption):** Regular (400), 12sp–13sp / Line Height 18sp, Warna `#757575` (Estimasi durasi, plat nomor, placeholder).
- **Button Text:** Semi-Bold (600), 14sp, Letter Spacing +0.2px (Teks pada PrimaryButton).
- **Badge / Microcopy:** Semi-Bold (600), 10sp–11sp (Nomor Antrean Pit, tag status pengerjaan).

### 1.3 Sistem Spasi & Radius (Spacing & Border Radius)

- **Grid Spasi:** Kelipatan 4dp dan 8dp (`4dp`, `8dp`, `12dp`, `16dp`, `20dp`, `24dp`, `32dp`).
- **Margin Layar:** `16dp` hingga `20dp` horizontal padding konsisten di seluruh layar.
- **Corner Radius:**
  - Input field & tombol primer: `10dp`–`12dp`.
  - Kartu kendaraan, paket servis, & workshop: `12dp`–`16dp`.
  - Modal Bottom Sheet: `20dp`–`24dp` (hanya sudut atas kiri dan kanan).
  - Chip & Badges: `6dp`–`8dp`.

---

## 2. Pustaka Komponen UI (Reusable UI Components)

### 2.1 AppLogo (`app_logo.dart`)
- Logo resmi PitStop Servisin Aja dengan monogram huruf 'S' khas bernuansa oranye (`#FF6600`) dan abu-abu arang (`#3E4347`).
- Mendukung varian ukuran (`compact` 40dp untuk appbar, `medium` 64dp, dan `hero` 96dp untuk splash & login).

### 2.2 Segmented Tab Control (`segmented_tab_control.dart`)
- Digunakan pada layar login (*Login via Password* vs *Login via OTP*) dan tiket (*Tiket Aktif* vs *Riwayat*).
- Transisi animasi mulus (*animated sliding indicator*) dengan sudut melengkung 10dp.

### 2.3 Custom Text Field (`custom_text_field.dart`)
- Tinggi 48dp (aksesibilitas ramah sentuhan).
- Mendukung prefix khusus kode negara Indonesia (`+62` dengan bendera merah putih 🇮🇩).
- Mendukung toggle visibilitas password (*eye icon*).
- State fokus bergaris oranye tegas (`#FF6600`).

### 2.4 Primary Button (`primary_button.dart`)
- Tombol aksi utama dengan latar oranye penuh `#FF6600`, teks putih tebal, radius 12dp.
- Mendukung state *disabled* (abu-abu `#DEDEDE`) dan state *loading* (spinner putih melingkar).

### 2.5 Vehicle Card (`vehicle_card.dart`)
- Kartu representasi unit kendaraan di Garasi dan Beranda.
- Menampilkan plat nomor dalam badge hitam (`#3E4347`), merk/model, tahun, dan tag status servis.

### 2.6 Sticky Unit Switcher (`sticky_unit_switcher.dart`)
- Bilah navigasi horizontal yang menempel (*sticky*) di bagian atas layar konfigurasi servis.
- Memungkinkan pengguna berpindah antar kendaraan yang dipilih dalam alur pemesanan secara instan tanpa kehilangan input.

### 2.7 Promo Carousel (`promo_carousel.dart`)
- Slider kartu promosi interaktif pada Beranda dengan pagination dot oranye yang responsif.

### 2.8 Dev Floating Button & Bottom Sheet (`dev_floating_button.dart` & `dev_simulation_bottom_sheet.dart`)
- Tombol utilitas terapung di halaman tiket pelacakan.
- Membuka modal kontrol pengujian yang memungkinkan evaluator memilih kendaraan dan mengubah status tahapan montir secara langsung di Supabase guna menguji reaktivitas real-time.

---

## 3. Spesifikasi UI/UX Halaman (Screen Specifications)

### 3.1 Layar Autentikasi (Splash, Login, Register)
- **Splash Screen:** Monogram logo hero, animasi fade-in lembut, verifikasi sesi Supabase di latar belakang, footer hak cipta 2026.
- **Login Screen:** Dual-tab segmented control (Password / OTP), input field `+62`, tombol login oranye, link pendaftaran akun.
- **Register Screen:** Input nama lengkap, nomor HP, email, password. Pendaftaran berhasil otomatis menyuntikkan 2 kendaraan starter (*Honda Vario 160* & *Yamaha NMAX 155*) ke garasi pengguna untuk pengujian instan.

### 3.2 Layar Navigasi Utama (Main Shell Layout)
- **Beranda (Home):**
  - Top Bar: Avatar profil, status akun terverifikasi, lonceng notifikasi.
  - Pita lokasi: *"Lokasi Saat Ini: Jakarta, Indonesia"*.
  - Carousel banner promo & tips perawatan.
  - Seksi *Garasi Saya* bergulir horizontal dengan plat nomor kontras.
  - Seksi *Bengkel Terdekat* lengkap dengan rating bintang dan jarak tempuh.
  - Center Docked FAB: Tombol oranye melayang berikon kunci inggris sebagai tombol cepat booking servis.
- **Garasi (Garage):**
  - Daftar seluruh armada motor pengguna.
  - Tombol modal sheet *"Tambah Motor Baru"*.
  - Tautan menuju *Vehicle Detail Screen* dengan spesifikasi dan riwayat servis.
- **Tiket (Ticket List):**
  - Tab pemisah: *Tiket Aktif* dan *Riwayat Selesai*.
  - Kartu tiket mencantumkan kode booking, nama bengkel, tanggal, jumlah armada motor, dan tombol *"Lihat Pelacakan"*.
- **Profil (Profile):**
  - Identitas pengguna, status nomor telepon terverifikasi.
  - Menu: Pusat Bantuan, Kebijakan Privasi, Tentang Aplikasi, dan Keluar Akun.

### 3.3 Alur Inti Multi-Vehicle Booking
1. **Layar 1: Seleksi Multi-Kendaraan (`/vehicle-selection`)**
   - Checkbox interaktif di setiap kartu motor.
   - Tombol instan modal sheet `+ Tambah Motor Baru`.
   - Bottom bar mengambang: Counter *"X Kendaraan Terpilih"* & tombol *"Lanjut ke Servis"*.
2. **Layar 2: Konfigurasi Servis per Unit (`/service-configuration`)**
   - Sticky tab switcher kendaraan di bagian atas.
   - Pilihan 5 paket servis standar dalam kartu interaktif (ikon, nama paket, durasi, harga jasa).
   - Opsi checklist suku cadang/oli pelumas tambahan.
   - Form catatan keluhan bebas per unit.
   - Tombol lanjut hanya aktif jika setiap unit telah memiliki paket servis terpilih.
3. **Layar 3: Penjadwalan & Bengkel Terpadu (`/schedule`)**
   - Pemilihan cabang bengkel resmi PitStop Servisin Aja.
   - Pemilihan tanggal kalender dan slot jam kedatangan.
   - Penomoran otomatis antrean pit berurutan per unit (`Unit 1: Pit #01`, `Unit 2: Pit #02`).
   - Ringkasan akumulasi total estimasi durasi servis.
4. **Layar 4: Ringkasan Pemesanan & Checkout (`/summary-checkout`)**
   - Itemized cost breakdown: Rincian jasa & suku cadang per masing-masing motor.
   - Rekap total tagihan akhir.
   - Pilihan metode pembayaran (*Bayar di Bengkel*, *Virtual Account*, *QRIS*).
   - Tombol konfirmasi dengan animasi dialog sukses.

### 3.4 Layar Tiket & Pelacakan Status Real-Time (`/tracking/:id`)
- Baris atas: Kode booking resmi (`#PSA-YYYYMMDD-XXX`) & QR Code digital check-in.
- Rincian bengkel kedatangan dan jam reservasi.
- Tab switcher unit motor dalam tiket.
- Stepper 4 tahapan pengerjaan per kendaraan:
  1. `Menunggu Antrean`
  2. `Sedang Dikerjakan`
  3. `Pengecekan Akhir`
  4. `Selesai`
- Dev Simulation Floating Button: Fitur penguji untuk memperbarui status pengerjaan secara langsung dan melihat reaksi antarmuka seketika tanpa perlu membuka portal admin bengkel.

---

## 4. Jaminan Kualitas Visual & Safe Layout (Bonus Points Compliance)

1. **Responsif & Bebas Overflow:** Menggunakan kombinasi `LayoutBuilder`, `SingleChildScrollView`, `Flexible`, dan `SafeArea` untuk menjamin tidak ada garis hitam-kuning (*yellow-black bars / RenderFlex overflowed*) pada berbagai rasio layar Android (16:9, 18:9, 19.5:9, 20:9).
2. **Pixel Precision:** Jarak antar komponen, padding form, dan rasio kartu di Flutter diimplementasikan presisi sesuai kanvas desain Figma.
3. **State Feedback:** Seluruh aksi pengguna memiliki visual feedback yang jelas (ripple effect, spinner saat loading, shimmer pada pemuatan data, dialog konfirmasi sebelum keluar/membatalkan).
