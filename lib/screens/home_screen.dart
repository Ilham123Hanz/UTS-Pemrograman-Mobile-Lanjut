import 'package:flutter/material.dart';
import '../data/templates.dart';
import '../models/design_template.dart';
import '../screens/editor_screen.dart';
import '../screens/templates_screen.dart';
import '../widgets/template_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  bool _isSearchFocused = false;

  final List<String> _categories = const [
    'Semua',
    'Poster',
    'Media Sosial',
    'Promosi',
    'Dokumen',
    'Acara',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditor(BuildContext context, DesignTemplate template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(template: template),
      ),
    );
  }

  void _navigateToTemplates(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TemplatesScreen()),
    );
  }

  List<DesignTemplate> get _filteredTemplates {
    return designTemplates.where((template) {
      final categoryMatch = _selectedCategory == 'Semua' || template.category == _selectedCategory;
      final searchMatch = _searchQuery.isEmpty ||
          template.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          template.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          template.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      return categoryMatch && searchMatch;
    }).toList();
  }

  Widget _buildCategoryChip(BuildContext context, String category, bool selected, Color primaryColor, Color textPrimary, Color cardColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ChoiceChip(
        label: Text(
          category,
          style: TextStyle(
            color: selected ? Colors.white : textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        selectedColor: primaryColor,
        backgroundColor: cardColor,
        side: BorderSide(
          color: selected ? Colors.transparent : borderColor,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        elevation: selected ? 2 : 0,
        pressElevation: 4,
        shadowColor: primaryColor.withValues(alpha: 0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final cardColor = isDark ? const Color(0xFF252530) : const Color(0xFFF8F8FC);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE8E8EE);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFFB0B0B8) : const Color(0xFF6B6B80);
    const primaryColor = Color(0xFF7D2AE8);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header with Canva branding
          SliverToBoxAdapter(
            child: Container(
              color: surfaceColor,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  // Canva Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo_canva.jpg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Canva',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const Spacer(),
                  // Notification bell
                  _buildHeaderIcon(
                    context,
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                    tooltip: 'Notifikasi',
                    isDark: isDark,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(width: 8),
                  // Profile avatar
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFE6D8FF),
                    child: Text(
                      'U',
                      style: TextStyle(
                        color: Color(0xFF6420C8),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar - Canva Style
          SliverToBoxAdapter(
            child: Container(
              color: surfaceColor,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apa yang ingin Anda desain?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onTap: () {
                      setState(() {
                        _isSearchFocused = true;
                      });
                    },
                    onEditingComplete: () {
                      setState(() {
                        _isSearchFocused = false;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari template, poster, presentasi, media sosial...',
                      hintStyle: TextStyle(color: textSecondary, fontSize: 16),
                      prefixIcon: Icon(Icons.search_rounded, color: _isSearchFocused ? primaryColor : textSecondary, size: 26),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Chips - Canva Style
          SliverToBoxAdapter(
            child: Container(
              color: surfaceColor,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final selected = _selectedCategory == category;
                        return _buildCategoryChip(context, category, selected, primaryColor, textPrimary, cardColor, borderColor);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hero Banner / Quick Actions
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7D2AE8), Color(0xFF4B61D1)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7D2AE8).withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mulai desain Anda hari ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pilih template profesional dan buat desain menakjubkan dalam hitungan menit.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6420C8),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _openEditor(context, designTemplates.first),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Buat desain baru'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => _navigateToTemplates(context),
                        icon: const Icon(Icons.grid_view_rounded, size: 20),
                        label: const Text('Jelajahi template'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Section Header - Templates
          SliverToBoxAdapter(
            child: Container(
              color: surfaceColor,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Row(
                children: [
                  Text(
                    'Template untuk Anda',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _navigateToTemplates(context),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Template Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final template = _filteredTemplates[index];
                  return TemplateCard(
                    template: template,
                    onTap: () => _openEditor(context, template),
                  );
                },
                childCount: _filteredTemplates.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 18,
                mainAxisSpacing: 20,
                childAspectRatio: 0.7,
              ),
            ),
          ),

          // Empty state
          if (_filteredTemplates.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: primaryColor.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tidak ada template ditemukan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Coba kata kunci pencarian yang lain'
                            : 'Tidak ada template di kategori "$_selectedCategory"',
                        style: TextStyle(
                          fontSize: 15,
                          color: textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_searchQuery.isNotEmpty || _selectedCategory != 'Semua')
                        FilledButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'Semua';
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reset Filter'),
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    required bool isDark,
    required Color textSecondary,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D3A) : const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: textSecondary, size: 24),
          ),
        ),
      ),
    );
  }
}