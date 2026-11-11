import 'package:flutter/material.dart';
import '../data/templates.dart';
import '../models/design_template.dart';
import '../screens/editor_screen.dart';
import '../screens/templates_screen.dart';
import '../widgets/template_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/category_chips.dart';
import '../widgets/template_grid.dart';
import '../widgets/empty_state.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final cardColor = isDark ? const Color(0xFF252530) : const Color(0xFFF8F8FC);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE8E8EE);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFFB0B0B8) : const Color(0xFF6B6B80);
    final primaryColor = const Color(0xFF7D2AE8);

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
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFE6D8FF),
                    child: const Text(
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
                  CategoryChips(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) => setState(() => _selectedCategory = category),
                    primaryColor: primaryColor,
                    textPrimary: textPrimary,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                ],
              ),
            ),
          ),

          // Hero Banner / Quick Actions
          SliverToBoxAdapter(
            child: HeroBanner(
              onCreateDesign: () => _openEditor(context, designTemplates.first),
              onBrowseTemplates: () => _navigateToTemplates(context),
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
          TemplateGrid(
            templates: _filteredTemplates,
            onTemplateTap: (template) => _openEditor(context, template),
          ),

          // Empty state
          if (_filteredTemplates.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                title: 'Tidak ada template ditemukan',
                message: _searchQuery.isNotEmpty
                    ? 'Coba kata kunci pencarian yang lain'
                    : 'Tidak ada template di kategori "$_selectedCategory"',
                onReset: _searchQuery.isNotEmpty || _selectedCategory != 'Semua'
                    ? () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedCategory = 'Semua';
                        });
                      }
                    : null,
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