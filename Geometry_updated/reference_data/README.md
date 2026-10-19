# Profil sumber kendaraan dan perlindungan data

Pengguna memilih **`VD CALCULATION OLD 2 .xlsx` → `Analisis OptimumK` →
tabel `Parameter SAS 8`**, bukan blok perhitungan engine di atas tabel itu.
Workbook `VD CALCULATION SAS 8 (old).xlsx` menjadi referensi pembanding;
profil SAS 7 tidak dicampur ke baseline terpilih.

## Baseline yang cocok dengan kalkulator

| Parameter | Nilai | Cell sumber pada Analisis OptimumK |
|---|---:|---|
| Massa, label sumber `Mass (Driver)` | 224.3 kg | C22 |
| Distribusi bobot depan | 0.5 | C23 |
| Track depan/belakang | 1200 / 1140 mm | C29 / D29 |
| Wheelbase | 1560 mm | C28 |
| Tinggi CG pada tabel utama | 300 mm | C39 |
| Roll center depan/belakang pada tabel utama | 10 / 35 mm | C38 / D38 |
| KPI depan | 10.4 derajat | C34 |

Nilai tersebut sudah cocok, sehingga tidak perlu diganti. Kecocokan angka belum
membuktikan seluruh data merupakan hasil pengukuran aktual.

## Satu perubahan numerik yang dikonfirmasi

Pengguna menyatakan **"152,4 mm adalah lebar yang dipakai"**. Oleh karena itu,
`tire_section_width_mm` di workbook kalkulator turunan diubah dari 205 ke 152.4 mm,
merujuk `Analisis OptimumK!C32 = 6*25.4`. Ini tidak mengubah sumber asli.

## Temuan tetap dibiarkan sebagai catatan

- Camber depan sumber +2 derajat, kalkulator -2 derajat: konvensi tanda belum dipastikan.
- Caster pada tabel terpilih kosong: 5 derajat pada kalkulator masih nilai yang
  belum dikonfirmasi oleh tabel tersebut.
- Scrub radius 53.34 mm dihitung sebagai 35% dari lebar ban, bukan pengukuran sumbu steering.
- Rumus sprung mass sumber mengacu ke C92/C93 yang kosong. Nilai cache yang
  memperlakukan unsprung mass sebagai nol tidak dianggap bukti unsprung mass nol.
- Nilai unsprung mass 24.4/30.1 kg pada kalkulator dapat ditelusuri ke `Sheet2`,
  bagian asumsi. Kesesuaiannya dengan mobil terpilih belum dikonfirmasi.
- MR pada kalkulator mendekati hasil perhitungan pemilihan spring di workbook lain;
  itu belum membuktikan actual full wheel-to-spring motion ratio.
- Koefisien mu 1.5 pada blok engine tidak otomatis menggantikan kurva mu(Fz) ban.
- Batas akselerasi, pengereman, kecepatan, dan sudut steering pada konfigurasi tetap
  berstatus asumsi sampai sumber pengujian kendaraan tersebut tersedia.

Temuan dicatat tanpa memperbaiki angka, formula atau satuan workbook asli.
Input lain pada kalkulator juga tidak diganti untuk mengisi kekosongan secara otomatis.

## Isi folder

- `SOURCE_BASELINE_REVIEW.xlsx`: pemetaan 55 parameter, 25 pengaturan, dan 16 temuan.
  Ini laporan audit, bukan pengganti workbook input simulasi.
- `baseline_review.json` dan `parameter_mapping.csv`: data pemetaan yang dapat diperiksa.
  Formula sumber di laporan ditampilkan sebagai teks; nilai formula berasal dari cache.
- `authorized_change.json`: catatan konfirmasi dan perubahan lebar ban.
- `source_checksums.json`: identitas SHA256 kedua workbook unggahan.
- `DATA_POLICY.md`: aturan sumber tidak boleh diubah tanpa izin pengguna.

Kedua workbook asli tetap disimpan utuh dalam arsip referensi lokal, dengan SHA256
yang diperiksa sebelum/sesudah pekerjaan. Folder repository ini memuat pemetaan
dan identitas sumber; file asli tersebut tidak disalin ke sini.
