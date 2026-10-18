# Geometry — studi pelebaran track depan

Versi ini menyiapkan penyaringan track depan 1200–1280 mm sebelum riset
hardpoint arm. Konsep pengguna: arm diperpanjang, upright, wheel offset,
spacer dan rack dipertahankan. Track belakang ditahan pada baseline 1140 mm.
Angka track berasal dari jarak antar wheel centre, bukan lebar luar ban.

**Hasilnya kandidat berdasarkan asumsi model, bukan track width optimum final,
bukti kelincahan transien, atau persetujuan desain untuk diproduksi.**

## Jalankan di MATLAB

MATLAB R2019b atau lebih baru, tanpa toolbox tambahan untuk model ini.
Buka folder ini sebagai current folder, lalu:

```matlab
main_trackwidth_analyzer
```

Alternatif yang mengembalikan hasil sebagai struct:

```matlab
study = run_trackwidth_study(pwd);
```

MATLAB membaca workbook langsung menggunakan `readcell(...,'UseExcel',false)`.
Jika Anda mengubah formula input, hitung ulang dan simpan workbook di Excel
sebelum menjalankan model. Hasil baru masuk ke `output/study_<timestamp>/`.
MATLAB juga membuat dashboard PNG.

## Input yang digunakan

File: `input/FSAE_VD_3_KASAR .xlsx`.

- `02_INPUT_VARIABLES`, **kolom E**: baseline kendaraan.
- `06_SIMULATION_CONFIG`: rentang sweep, batas kecepatan, lintasan dan pengaturan studi.
- Kolom F proposed tetap merupakan pekerjaan yang belum selesai dan **tidak dibaca**.
- Sheet dashboard/perhitungan Excel lama tetap dipertahankan sebagai dokumen asal.
  Sheet itu **tidak disinkronkan** dengan model baru; lihat CSV/PNG output baru.
- Tidak ada perubahan pada input baseline, formula maupun cache sheet 1–5.
  Hanya XML sheet konfigurasi ke-6 yang diubah dari workbook sumber.

Default sweep 1200–1280 mm setiap 5 mm, dengan baseline dan titik akhir selalu
disertakan. Track belakang wajib tetap; jika ingin studi dual-axle, buat studi
terpisah agar pertanyaan riset tidak berubah tanpa disadari.

## Dua skenario

1. `fixed_wheel_rate`: spring rate, motion ratio dan karakteristik ban tetap.
   Roll stiffness depan meningkat saat track depan diperlebar.
2. `fixed_axle_roll_stiffness`: roll stiffness tiap axle ditahan pada baseline.
   Model menghitung effective ride rate dan equivalent spring rate yang diperlukan
   secara matematis. Angka spring ini merupakan pembanding sensitivitas, bukan
   rekomendasi komponen sebelum motion ratio dan geometri aktual diketahui.

Keduanya mempertahankan roll center, massa, CG, alignment, ban dan geometri dasar
sebagai asumsi penyaringan. Panjang arm tidak ditentukan dari faktor track width;
scrub radius dan caster tidak dioptimalkan dalam model ini.

## Asumsi yang harus dikonfirmasi

**Motion ratio:** label Excel asli menulis `Wheel / Spring`, tetapi rumus MATLAB
asli memakai `K_spring * IR^2`. Untuk menjaga pembandingan baseline, default baru
secara eksplisit `spring_over_wheel`, yaitu displacement spring / displacement wheel.
Jika angka pengukuran Anda sebenarnya wheel / spring, ubah konfigurasi ke
`wheel_over_spring`; model kemudian memakai `K_spring / IR^2`.
Sensitivitas kedua interpretasi disimpan, bukan dipilih otomatis.

**Lintasan:** file `fast_lane.ai` dibaca sebagai spline Assetto Corsa. Kesesuaiannya
dengan track JSAE belum diverifikasi. Default `path_scale_mode=raw` memakai
panjang geometris sekitar 1022.43 m, sehingga waktu baru tidak dapat dibandingkan
langsung dengan output lama sepanjang 1050 m. Jika memilih
`uniform_to_declared_length`, koordinat dan jarak sama-sama diskalakan;
curvature berubah konsisten. Semua kandidat menggunakan path yang sama.
Model belum mengoptimalkan racing line.

**Ban dan massa:** mu/load sensitivity berasal dari baseline pengguna dan belum
divalidasi terhadap data pengujian. Massa tambahan arm belum dihitung. Model
tidak memiliki kurva gaya terhadap slip angle, aero, full combined-slip tyre model,
distribusi pengereman atau longitudinal load transfer tiap roda.

**Steering:** angka maksimum 35 derajat adalah batas ideal yang diwarisi input,
bukan kemampuan rack aktual yang sudah diukur. Sudut skidpad merupakan referensi
Ackermann ideal, menggunakan track depan untuk kedua roda depan. Rack travel,
steering arm, tie-rod, steering ratio, torque, bump steer dan jacking belum dimodelkan.

**Ruang lintasan:** endurance memakai pemeriksaan lebar sederhana. Skidpad memakai
radius wheel centre ditambah setengah section width ban dan margin yang dikonfigurasi.
Keduanya belum memvalidasi seluruh swept envelope bodi, footprint ban, dan cone
aktual. Minimum turning radius rack aktual belum dapat dipastikan.

**Arm dan struktur:** tidak ada buckling SF, validasi CV, atau klaim geometri aman
dari perkiraan panjang arm. Tunggu hardpoint, panjang anggota struktur, load path,
material dan joint aktual. `GeometryValidated=0` pada seluruh output.

**Kelincahan:** belum ada integrasi sideslip, yaw rate, driver atau respons slalom.
`YawResponseEvaluated=0`. Delta yaw inertia hanya proxy massa unsprung depan yang
dimodelkan sebagai massa titik di wheel centre; bukan total inertia, tidak mencakup massa arm tambahan,
dan tidak digunakan untuk menghitung waktu lap.

## Perbaikan numerik utama

- Kebutuhan gaya lateral kedua axle wajib terpenuhi sesuai keseimbangan gaya dan
  momen yaw steady state. Kelebihan grip satu axle tidak menutupi kekurangan axle lain.
- Kapasitas dibatasi oleh axle pertama yang saturasi atau wheel lift pertama.
- Massa sprung tiap axle diturunkan dari distribusi bobot total dan unsprung mass,
  sehingga keseimbangan momen overturning tetap terpenuhi.
- Batas steering skidpad menghasilkan status infeasible dan waktu `Inf` jika
  sudut tidak mencukupi; menurunkan kecepatan tidak mengubah kebutuhan sudut Ackermann ideal.
- Solver periodic forward/backward memeriksa konvergensi, beban roda dan axle utilisation.
- Perubahan curvature karena clearance tanpa mengubah path dan panjangnya dihapus.
- Output menandai kandidat yang seri secara numerik dan hasil terbaik di batas sweep.

## Membaca hasil

- `track_width_study.csv`: semua kandidat dan dua skenario, termasuk kondisi target
  1.7 g. `LapScreened`/`SkidpadScreened` hanya berarti lolos batas model sederhana.
  Angka negatif `TargetMinWheelLoad_N` adalah peringatan bahwa target tersebut
  melewati batas model; bukan beban fisik roda yang tetap menapak.
- `track_width_study.mat`: struct `study`, input, trace, hasil tiap roda dan sensitivitas.
- `trace_*.csv`: kecepatan baseline dan kandidat maksimum pada path yang sama.
- `sensitivity_baseline_vs_candidate.csv`: contoh perturbasi mu curve ±10%, tinggi CG
  ±20 mm, dan interpretasi MR alternatif. Nilainya merupakan skenario eksplorasi,
  **bukan ketidakpastian terukur atau confidence interval**. Besar perturbasi dapat
  diedit di konfigurasi Excel. Set `run_sensitivity=0` untuk melewatinya.
- `inputs_used.xlsx`/`inputs_used.json`: salinan input run agar hasil dapat ditelusuri.
- `RUN_NOTES.txt`: engine eksekusi dan batas interpretasi.

## Eksekusi GNU Octave

File `.m` numerik juga dapat dijalankan dengan GNU Octave 9.4. Karena tidak memakai
MATLAB Excel API, Octave membutuhkan snapshot JSON dari workbook terbaru:

```bash
python3 -m pip install -r requirements_octave_tools.txt
python3 tools/export_workbook.py
octave --quiet --eval "main_trackwidth_analyzer"
```

Setiap perubahan workbook memerlukan ekspor ulang. Pembaca Octave memeriksa SHA256
dan menolak snapshot yang tidak cocok. MATLAB tidak membutuhkan Python/JSON.

Octave secara default menjalankan model tanpa plotting. Buat grafik dari hasil CSV:

```bash
python3 tools/plot_outputs.py output/study_<timestamp>
```

## Verifikasi model

```matlab
addpath('tests');
count = run_model_checks(pwd);
```

Pemeriksaan mencakup konservasi gaya vertikal dan momen overturning, simetri kiri/kanan,
kasus mu konstan dengan axle pembatas yang diketahui, steering/corridor infeasible,
scaling lintasan, waktu lingkaran analitik, feasibility kedua axle pada lintasan
tersedia, dan konvergensi periodic. Lihat `VALIDATION.md` untuk eksekusi yang dilakukan.

Tahap berikut: ukur definisi motion ratio, geometri rack/upright, massa dan data ban;
bangun model lateral transien; lalu masukkan hasil hardpoint arm ke studi yang sama.
