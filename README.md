# Cartenz Data Waster

Internal tool untuk **stress test koneksi data** (VPN / mobile data) dengan trafik upload & download yang realistis.  
Aplikasi ini ditulis menggunakan **Flutter** dan saat ini ditargetkan untuk perangkat **Android**.

> ⚠️ **Peringatan:** Aplikasi ini dapat menghabiskan kuota data dengan sangat cepat.  
> Gunakan hanya pada SIM uji / profil VPN uji dan di lingkungan yang terkontrol.

---

## ✨ Fitur Utama

### 1. Dashboard

Halaman utama untuk menjalankan tes:

- **Mode Download / Upload**
  - Tombol switch terpisah untuk _Download_ dan _Upload_.
  - Bisa pilih hanya download, hanya upload, atau keduanya sekaligus.
- **Data size (MB, 0 = infinite)**
  - Menentukan total data yang ingin dihabiskan.
  - Nilai `0` berarti _infinite mode_ (jalan terus sampai di-_Stop_ manual).
- **Concurrent connections**
  - Jumlah koneksi paralel HTTP.
  - Semakin tinggi nilainya, semakin agresif beban ke jaringan.
- **Live Statistics**
  - Total data yang sudah digunakan (download + upload).
  - Kecepatan saat ini (MB/s).
  - Breakdown Downloaded / Uploaded secara terpisah.
- **Status Bar**
  - Menampilkan status singkat: `Idle`, `Running traffic test…`, atau `Completed`.

---

### 2. Speed Graph

Halaman grafik untuk memonitor throughput secara realtime:

- Grafik garis untuk **Download** dan **Upload** (warna berbeda).
- Menampilkan **current**, **average**, dan **max** speed (MB/s).
- History hingga **60 detik terakhir** (sampling 1 detik).
- Grid dan background bertema **dark / biru tua** sesuai branding Cartenz.

---

### 3. About

Halaman informasi aplikasi:

- Nama & deskripsi singkat:
  - _Cartenz Data Waster – Internal tool to stress test VPN, quota policy, and bandwidth shaping._
- Informasi versi:
  - Contoh: `1.0.0 (Cartenz-Internal)`
- Informasi backend:
  - Domain backend (misal: `waster.anya-vpn.my.id`)
  - Stack singkat: `Node.js + Nginx + HTTPS (Let's Encrypt)`
- Catatan penggunaan & peringatan konsumsi data.

---

### 4. Foreground Notification

Saat **Start Test** dijalankan:

- Aplikasi menampilkan **notifikasi foreground**:
  - Judul: `Cartenz Data Waster`
  - Isi: status seperti `Running test • 1.75 MB/s • 25.75 MB used`
- Tes tetap berjalan meski user:
  - Menekan tombol home,
  - Berpindah ke aplikasi lain,
  - Layar dikunci (selama Android tidak memaksa menghentikan proses).

---

## 🏗️ Arsitektur Singkat

- **Frontend**: Flutter (Dart), Material 3, desain dark mode Cartenz.
- **Backend**: Node.js + Express  
  Endpoint utama:
  - `GET /health` – health check.
  - `GET /waste-download` – download random bytes.
  - `POST /waste-upload` – upload random bytes.  
  Biasanya di-_proxy_ lewat **Nginx + HTTPS (Let’s Encrypt)**.

Di sisi app, base URL backend diset melalui konstanta:

```dart
static const String baseUrl = 'https://waster.anya-vpn.my.id';
