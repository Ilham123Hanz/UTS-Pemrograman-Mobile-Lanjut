import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/templates_screen.dart';
import 'screens/projects_screen.dart';

void main() {
  runApp(const CanvaPracticeApp());
}

class CanvaPracticeApp extends StatelessWidget {
  const CanvaPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7D2AE8);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Canva UI Practice',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: purple),
        scaffoldBackgroundColor: const Color(0xFFF8F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F8FC),
          foregroundColor: Color(0xFF25243A),
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final pages = const [
    HomeScreen(),
    TemplatesScreen(),
    ProjectsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Template',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Proyek',
          ),
        ],
      ),
    );
  }
}
