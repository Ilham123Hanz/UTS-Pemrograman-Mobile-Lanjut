import 'package:flutter/material.dart';
import '../data/templates.dart';
import '../models/design_template.dart';
import '../screens/editor_screen.dart';
import '../widgets/template_card.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _viewMode = 'grid'; // 'grid' or 'list'

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
    const primaryColor = Color(0xFF7D2AE8);

    return SafeArea(
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: Row(
          children: [
            // Sidebar - Categories
            _buildSidebar(
              context,
              isDark,
              surfaceColor,
              cardColor,
              borderColor,
              textPrimary,
              textSecondary,
              primaryColor,
            ),
            
            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  _buildTopBar(
                    context,
                    isDark,
                    surfaceColor,
                    cardColor,
                    borderColor,
                    textPrimary,
                    textSecondary,
                    primaryColor,
                  ),
                  
                  // Content
                  Expanded(
                    child: _filteredTemplates.isEmpty
                        ? _buildEmptyState(context, isDark, textPrimary, textSecondary, primaryColor)
                        : _viewMode == 'grid'
                            ? _buildGridView(
                                _filteredTemplates,
                                isDark,
                                primaryColor,
                                textPrimary,
                                textSecondary,
                                borderColor,
                                cardColor,
                                surfaceColor,
                              )
                            : _buildListView(
                                _filteredTemplates,
                                isDark,
                                primaryColor,
                                textPrimary,
                                textSecondary,
                                borderColor,
                                cardColor,
                                surfaceColor,
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
  ) {
    return Container(
      width: 260,
      color: surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan template berdasarkan kategori',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Category List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = _selectedCategory == category;
                final icon = _getCategoryIcon(category);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategory = category),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: selected ? primaryColor.withValues(alpha: 0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: selected ? Border.all(color: primaryColor, width: 1.5) : null,
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: selected ? primaryColor : (isDark ? Colors.transparent : primaryColor.withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  icon,
                                  size: 20,
                                  color: selected ? Colors.white : primaryColor,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                    color: selected ? primaryColor : textPrimary,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: Color(0xFF7D2AE8),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ); // Closes AnimatedContainer
              }, // Closes itemBuilder
            ), // Closes ListView.separated
          ), // Closes Expanded
          
          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Perlu bantuan?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lihat tutorial desain atau hubungi dukungan kami.',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
  ) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari template...',
                hintStyle: TextStyle(color: textSecondary, fontSize: 15),
                prefixIcon: Icon(Icons.search_rounded, color: textSecondary, size: 24),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 24),
          
          // View Mode Toggle
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                _buildViewModeButton(
                  icon: Icons.grid_view_rounded,
                  isActive: _viewMode == 'grid',
                  onTap: () => setState(() => _viewMode = 'grid'),
                  tooltip: 'Tampilan Grid',
                  primaryColor: primaryColor,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                ),
                Container(width: 1, height: 24, color: borderColor),
                _buildViewModeButton(
                  icon: Icons.view_list_rounded,
                  isActive: _viewMode == 'list',
                  onTap: () => setState(() => _viewMode = 'list'),
                  tooltip: 'Tampilan List',
                  primaryColor: primaryColor,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_filteredTemplates.length} template',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
    required Color primaryColor,
    required Color textSecondary,
    required Color borderColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? primaryColor : textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(
    List<DesignTemplate> projects,
    bool isDark,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    Color cardColor,
    Color surfaceColor,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: projects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final template = projects[index];
        return TemplateCard(
          template: template,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditorScreen(template: template),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(
    List<DesignTemplate> projects,
    bool isDark,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    Color cardColor,
    Color surfaceColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final template = projects[index];
        return _buildListItem(
          context,
          template,
          isDark,
          primaryColor,
          textPrimary,
          textSecondary,
          borderColor,
          cardColor,
        );
      },
    );
  }

  Widget _buildListItem(
    BuildContext context,
    DesignTemplate template,
    bool isDark,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditorScreen(template: template)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 120,
                    height: 80,
                    child: Image.asset(
                      template.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: primaryColor.withValues(alpha: 0.1),
                        child: Center(
                          child: Icon(Icons.image_outlined, size: 32, color: primaryColor.withValues(alpha: 0.6)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              template.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        template.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        template.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: template.tags.take(4).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                // Action Button
                FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditorScreen(template: template)),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Gunakan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(70),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Tidak ada template ditemukan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Coba kata kunci pencarian yang lain'
                  : 'Tidak ada template di kategori "$_selectedCategory"',
              style: TextStyle(
                fontSize: 15,
                color: textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Semua':
        return Icons.apps_rounded;
      case 'Poster':
        return Icons.post_add_rounded;
      case 'Media Sosial':
        return Icons.share_rounded;
      case 'Promosi':
        return Icons.campaign_rounded;
      case 'Dokumen':
        return Icons.description_rounded;
      case 'Acara':
        return Icons.event_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }
}