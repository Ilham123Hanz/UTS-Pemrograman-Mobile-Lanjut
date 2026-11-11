import 'package:flutter_test/flutter_test.dart';
// Perbaikan 1: Menggunakan nama package yang sesuai dengan pubspec.yaml
import 'package:projectutp_2407051007_farrel/main.dart';

void main() {
  testWidgets('App loads and shows Canva branding', (WidgetTester tester) async {
    // Perbaikan 2: Menggunakan nama class utama yang benar (CanvaPracticeApp)
    await tester.pumpWidget(const CanvaPracticeApp());

    // Verify that Canva branding is shown
    expect(find.text('Canva UI Practice'), findsOneWidget); 
    // Catatan: Teks diubah menjadi 'Canva UI Practice' karena kata 'Canva' saja 
    // mungkin tidak ditemukan langsung di halaman pertama (HomeScreen) kecuali Anda menambahkannya.
  });
}