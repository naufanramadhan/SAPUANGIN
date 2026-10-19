# Perubahan dari Geometry.zip

## Pemeriksaan data kendaraan berikutnya

- Pengguna memilih tabel `Parameter SAS 8` pada `OLD 2 / Analisis OptimumK`.
- Massa 224.3 kg, distribusi depan 0.5, track 1200/1140 mm, wheelbase 1560 mm,
  serta parameter tabel lain yang sudah cocok dipertahankan.
- Lebar ban pada konfigurasi turunan diubah **205 → 152.4 mm** sesuai konfirmasi
  eksplisit pengguna. Workbook sumber tidak diubah atau dihitung ulang.
- Ditambah pemetaan 55 parameter, 25 konfigurasi, dan 16 temuan sumber terpisah.
- Camber, caster, MR, kurva ban dan parameter lain yang belum jelas tidak dikoreksi.
- Lihat `reference_data/README.md` dan aturan sumber pada `../AGENTS.md`.

## Pembaruan model awal

- Input proposed F tetap dipertahankan dan dikecualikan dari studi.
- Rear track dikunci pada baseline untuk studi pelebaran depan.
- Dua skenario roll stiffness menggantikan satu sweep yang menggabungkan perubahan axle.
- Kapasitas lateral mengharuskan kedua axle memenuhi demand steady-state serta
  membatasi kondisi wheel lift; tidak menjumlahkan seluruh grip sebagai satu batas.
- Perhitungan sprung mass tiap axle dan roll-axis height dibuat konsisten dengan
  total axle mass dan unsprung mass.
- Panjang lintasan dan curvature diperlakukan konsisten; shortcut radius berbasis
  clearance dihapus. Semua kandidat memakai path yang sama.
- Solver speed profile memeriksa konvergensi periodic dan kelayakan hasil.
- Steering skidpad memakai geometri ideal yang konsisten dan menyatakan kondisi
  sudut tidak cukup sebagai infeasible.
- Perkiraan buckling SF, batas CV dan klaim geometri optimum dihapus dari seleksi
  karena panjang arm/hardpoint belum diteliti.
- Estimasi delta yaw inertia diberi label proxy dan tidak dianggap respons yaw.
- Definisi motion ratio menjadi eksplisit, dengan sensitivitas dua interpretasi.
- Ditambah sensitivitas input, snapshot input, CSV, MAT, grafik, dan pemeriksaan model.
- Ditambah jalur eksekusi Octave tanpa ketergantungan pada `readcell` atau `table`.

Arsip pembaruan berisi file aktif untuk workflow baru. Script dan output lama
tetap tersedia pada ZIP unggahan asli; folder `.git`, log debug lokal dan output
lama tidak disalin ke paket baru.
