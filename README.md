# Canva-inspired Flutter UI (UTP Mola)

Paket ini adalah prototipe UI edukasi yang terinspirasi aplikasi desain seperti Canva. Bukan aplikasi resmi Canva.

## 4 tampilan
1. Beranda
2. Template
3. Editor desain (dibuka saat template dipilih)
4. Proyek kamu

## Cara menjalankan
1. Ekstrak folder ZIP.
2. Buat proyek Flutter baru, atau salin `pubspec.yaml`, folder `lib/`, dan `assets/` ke proyek Flutter milikmu.
3. Dari folder proyek jalankan:
   flutter pub get
   flutter run

Pastikan struktur:
- lib/main.dart
- lib/models/design_template.dart
- lib/data/templates.dart
- lib/widgets/template_card.dart
- lib/screens/home_screen.dart
- lib/screens/templates_screen.dart
- lib/screens/editor_screen.dart
- lib/screens/projects_screen.dart
- assets/images/*.jpg

Semua gambar poster dalam assets dibuat khusus sebagai contoh visual lokal, jadi tidak perlu mengunduh gambar tambahan. Fitur simpan/bagikan pada editor masih berupa simulasi.
