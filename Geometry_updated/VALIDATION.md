# Bukti eksekusi dan batas validasi

## Yang dieksekusi

- MATLAB-compatible `.m` model, melalui **GNU Octave 9.4.0** di Linux.
- Entry point `main_trackwidth_analyzer` dan rangkaian input–model–CSV–MAT.
- 17 kandidat track depan, 2 skenario: **34 kombinasi**.
- **12 pembandingan** sensitivitas baseline–kandidat maksimum.
- `tests/run_model_checks.m`: **33 pemeriksaan lulus** pada GNU Octave.
  Log: `output/model_checks.txt`.
- Audit CSV: seluruh 34 kombinasi nominal konvergen dan lolos batas event yang
  diterapkan; track belakang 1140 mm; utilisation kedua axle tidak melebihi 1.
- File MAT dibuka kembali menggunakan SciPy untuk memeriksa struktur hasil dan engine.
- Grafik dirender oleh Python/Matplotlib dari CSV yang benar-benar dihasilkan
  kode `.m`; tidak ada implementasi fisika Python pengganti.
- Workbook dibaca kembali, snapshot SHA256 diperiksa. Semua bagian workbook
  selain `xl/worksheets/sheet6.xml` identik secara byte dengan workbook asli.

## Yang diperiksa oleh suite

Konservasi total gaya vertikal dan momen overturning, simetri belok kiri/kanan,
kesamaan kedua skenario pada baseline, kondisi mu konstan dengan axle pembatas
yang diketahui, wheel-lift/axle-capacity boundary, steering dan corridor infeasible,
scaling panjang/curvature, waktu lap lingkaran analitik, feasibility pada spline
tersedia, kelanjutan solusi periodic, definisi MR pada rasio satu, penolakan
equivalent spring yang tidak dapat direalisasikan, dan penolakan snapshot Excel kedaluwarsa.

Pemeriksaan snapshot khusus Octave; saat suite dijalankan di MATLAB jumlahnya
32 karena MATLAB membaca workbook secara langsung.

## Yang belum diverifikasi

- Eksekusi pada MATLAB berlisensi dan plotting native MATLAB. Kode ditulis dengan
  API MATLAB standar R2019b+, tetapi keberhasilan di Octave tidak membuktikan
  seluruh perilaku native MATLAB.
- Validasi model terhadap mobil nyata, data TTC terkalibrasi, track JSAE resmi,
  atau pengukuran steering/rack.
- Respons yaw transien, handling balance berbasis slip angle, optimasi hardpoint,
  struktur arm, dan performa dinamik kendaraan aktual.

Octave lokal menampilkan pesan shutdown `ignoring const execution_exception&`
setelah proses selesai. Command mengembalikan exit code 0; output numerik dan
assertion suite selesai. Pesan tersebut tidak diperlakukan sebagai bukti kegagalan
atau sebagai pengganti pemeriksaan hasil.
