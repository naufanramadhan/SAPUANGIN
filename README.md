# SAPUANGIN — Vehicle Dynamics

Riset pelebaran track depan kendaraan formula, dengan input Excel dan model MATLAB/Octave.

- [Folder kode dan panduan lengkap](Geometry_updated/README.md)
- [Hasil eksekusi dan batas interpretasi](Geometry_updated/RESULTS.md)
- [Bukti validasi model](Geometry_updated/VALIDATION.md)
- [Paket pembaruan ZIP](Geometry_updated.zip)
- [Arsip unggahan awal](Geometry.zip)

## Menjalankan di MATLAB

Buka folder `Geometry_updated` sebagai current folder, lalu jalankan:

```matlab
main_trackwidth_analyzer
```

Studi membandingkan track depan 1200–1280 mm dengan track belakang tetap 1140 mm,
untuk skenario wheel rate tetap dan roll stiffness tiap axle tetap.
Input berada di kolom E sheet `02_INPUT_VARIABLES` dan sheet `06_SIMULATION_CONFIG`.
Kolom proposed F belum digunakan.

Kode numerik sudah dieksekusi pada GNU Octave 9.4.0 dan 33 pemeriksaan model lulus.
Eksekusi pada MATLAB berlisensi belum diverifikasi. Hasil belum mengevaluasi
respons yaw transien, torsi steering, atau geometri hardpoint arm aktual.
