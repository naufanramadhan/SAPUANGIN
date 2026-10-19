# Hasil eksekusi versi pembaruan

## Pembaruan setelah konfirmasi data sumber

Run terbaru: `output/study_20261019_171408/`, dengan lebar ban yang disetujui pengguna
**152.4 mm**. Profil acuan adalah tabel `Parameter SAS 8` pada
`VD CALCULATION OLD 2 .xlsx / Analisis OptimumK`. Input utama profil tersebut
sudah sesuai dengan model, sehingga massa, distribusi bobot dan dimensi dasar
tidak diubah. Kedua workbook unggahan baru tetap identik dengan sumber aslinya.

Perubahan 205 → 152.4 mm meningkatkan perkiraan clearance sebesar **26.3 mm per
sisi**. Waktu lap dan kapasitas lateral tetap sama dalam model ini, karena semua
kandidat sudah memenuhi batas clearance dan path yang dipakai tetap. Ini tidak
membuktikan bahwa lebar ban tidak berpengaruh pada mobil nyata; model ban belum
memakai section width sebagai input karakteristik gaya ban.

Run awal berikut dipertahankan sebagai arsip dengan inputnya sendiri.

Model `.m` dijalankan menggunakan GNU Octave 9.4.0. Tidak ada MATLAB berlisensi
di lingkungan eksekusi ini. Output run yang disertakan:
`output/study_20261018_231501/`. Nama folder memakai waktu mesin eksekusi.

## Hasil nominal, track belakang tetap 1140 mm

| Skenario dan ukuran | Kapasitas lateral | Estimasi satu lap spline | Satu lap skidpad |
|---|---:|---:|---:|
| Baseline depan 1200 mm, kedua skenario | 1.45668 g | 76.3192 s | 5.15131 s |
| Depan 1280 mm, wheel rate tetap | 1.46385 g | 76.1656 s | 5.13868 s |
| Depan 1280 mm, roll stiffness tiap axle tetap | 1.45668 g | 76.3192 s | 5.15131 s |

Pada skenario wheel rate tetap, kandidat 1280 mm menghemat sekitar 0.154 detik
atau 0.20% terhadap baseline dalam model yang sama. Axle belakang menjadi pembatas
kapasitas nominal. Ketika track depan diperlebar dengan wheel rate tetap,
fraksi roll stiffness depan meningkat dari 65.22% menjadi 68.09%, sehingga
load transfer belakang berkurang dan kapasitas axle pembatas membaik.

Saat roll stiffness tiap axle tetap, rear track, rear load transfer dan kapasitas
axle belakang tetap dalam kasus nominal ini. Semua 17 kandidat seri secara numerik;
1200 mm yang muncul sebagai indeks pertama bukan bukti bahwa lebar itu optimum.

**Kesimpulan terbatas:** manfaat nominal sangat bergantung pada pembagian roll
stiffness. Hasil ini belum mengukur respons steering/yaw atau kelincahan slalom.
1280 mm berada di batas sweep, bukan optimum yang sudah dikelilingi oleh kandidat
yang lebih buruk pada kedua sisi.

## Sensitivitas

Terdapat 12 pembandingan baseline–1280 mm: enam input per skenario. Contoh
perturbasi penuh kurva mu(Fz) ±10% dan tinggi CG ±20 mm dipilih untuk eksplorasi,
bukan berasal dari kalibrasi ketidakpastian.

- Dengan wheel rate tetap dan MR default, keuntungan waktu pada empat kombinasi
  perturbasi sekitar 0.115–0.194 detik.
- Dengan roll stiffness tetap, beberapa kombinasi tetap seri; kombinasi grip dan
  CG tinggi menghasilkan keuntungan sekitar 0.384 detik. Kesimpulan nominal
  tentang hasil seri tidak berlaku untuk semua kombinasi input.
- Interpretasi MR alternatif memberi perubahan waktu sekitar -0.220 detik
  pada skenario wheel rate tetap. Definisi MR perlu dikonfirmasi dari pengukuran.

Angka sensitivitas tersebut bukan jaminan performa kendaraan aktual.

## Hal yang belum bisa diputuskan dari hasil ini

- Apakah 1280 mm memperlambat respons berganti arah.
- Berapa steering torque, caster dan scrub radius terbaik dengan rack yang sama.
- Panjang/hardpoint arm dan tie-rod, camber gain, bump steer serta roll-center migration.
- Massa tambahan, kekuatan struktur dan swept envelope lengkap.

Target Excel 1.7 g tetap disimpan sebagai evaluasi diagnostik. Walaupun beberapa
kandidat memiliki beban roda positif pada target itu, kapasitas ban nominal model
hanya sekitar 1.46 g. Beban positif saja tidak berarti target 1.7 g dapat dicapai.

Waktu run baru tidak dibandingkan langsung dengan hasil ZIP lama. Versi ini memakai
spline mentah 1022.43 m, keseimbangan gaya per axle, dan path yang tidak berubah
antar kandidat. Model lama mengubah panjang menjadi 1050 m dan memakai perlakuan
curvature yang berbeda.
