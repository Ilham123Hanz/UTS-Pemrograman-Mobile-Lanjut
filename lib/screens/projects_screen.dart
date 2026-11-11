import 'package:flutter/material.dart';
import '../data/templates.dart';
import '../models/design_template.dart';
import '../models/design_project.dart';
import '../screens/editor_screen.dart';
import '../screens/templates_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _viewMode = 'grid'; // 'grid' or 'list'
  String _sortBy = 'terbaru'; // 'terbaru', 'terlama', 'nama', 'diupdate'
  String _filterBy = 'semua'; // 'semua', 'poster', 'media_sosial', 'promosi', 'dokumen', 'acara'
  
  // Simulated projects data - in real app this would come from local storage/database
  final List<DesignProject> _projects = [];
  
  final List<String> _sortOptions = const [
    'terbaru',
    'terlama', 
    'nama',
    'diupdate',
  ];
  
  final List<String> _filterOptions = const [
    'semua',
    'poster',
    'media_sosial',
    'promosi',
    'dokumen',
    'acara',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final cardColor = isDark ? const Color(0xFF252530) : const Color(0xFFF8F8FC);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE8E8EE);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFFB0B0B8) : const Color(0xFF6B6B80);
    const primaryColor = Color(0xFF7D2AE8);

    final filteredProjects = _getFilteredProjects();

    return SafeArea(
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Proyek Kamu',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_projects.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_projects.length} proyek',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _projects.isEmpty
                        ? 'Mulai desain pertama kamu dari template yang tersedia.'
                        : 'Semua desain yang telah kamu buat dan edit.',
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Toolbar
            if (_projects.isNotEmpty)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    // View mode toggle
                    _buildViewModeToggle(
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                    ),
                    const SizedBox(width: 16),
                    Container(width: 1, height: 24, color: borderColor),
                    const SizedBox(width: 16),
                    
                    // Sort dropdown
                    _buildDropdown<String>(
                      value: _sortBy,
                      items: _sortOptions.map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(_getSortLabel(e), style: TextStyle(fontSize: 13, color: textPrimary)),
                      )).toList(),
                      onChanged: (value) => setState(() => _sortBy = value!),
                      label: 'Urutkan',
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(width: 12),
                    
                    // Filter dropdown
                    _buildDropdown<String>(
                      value: _filterBy,
                      items: _filterOptions.map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(_getFilterLabel(e), style: TextStyle(fontSize: 13, color: textPrimary)),
                      )).toList(),
                      onChanged: (value) => setState(() => _filterBy = value!),
                      label: 'Filter',
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    
                    const Spacer(),
                    
                    // New project button
                    FilledButton.icon(
                      onPressed: () => _createNewProject(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Desain Baru'),
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child: _projects.isEmpty
                  ? _buildEmptyState(context, primaryColor, textPrimary, textSecondary, surfaceColor)
                  : filteredProjects.isEmpty
                      ? _buildNoResultsState(context, textPrimary, textSecondary)
                      : _viewMode == 'grid'
                          ? _buildGridView(filteredProjects, primaryColor, textPrimary, textSecondary, borderColor, cardColor, surfaceColor)
                          : _buildListView(filteredProjects, primaryColor, textPrimary, textSecondary, borderColor, cardColor, surfaceColor),
            ),
          ],
        ),
      ),
    );
  }

  List<DesignProject> _getFilteredProjects() {
    var filtered = List<DesignProject>.from(_projects);
    
    // Apply filter
    if (_filterBy != 'semua') {
      filtered = filtered.where((p) => 
        p.sourceTemplate?.category.toLowerCase().replaceAll(' ', '_') == _filterBy
      ).toList();
    }
    
    // Apply sort
    switch (_sortBy) {
      case 'terbaru':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'terlama':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'nama':
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'diupdate':
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
    
    return filtered;
  }

  String _getSortLabel(String value) {
    switch (value) {
      case 'terbaru': return 'Terbaru';
      case 'terlama': return 'Terlama';
      case 'nama': return 'Nama (A-Z)';
      case 'diupdate': return 'Diupdate';
      default: return value;
    }
  }

  String _getFilterLabel(String value) {
    switch (value) {
      case 'semua': return 'Semua';
      case 'poster': return 'Poster';
      case 'media_sosial': return 'Media Sosial';
      case 'promosi': return 'Promosi';
      case 'dokumen': return 'Dokumen';
      case 'acara': return 'Acara';
      default: return value;
    }
  }

  Widget _buildViewModeToggle({
    required Color primaryColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
  }) {
    return Row(
      children: [
        _buildViewModeButton(
          icon: Icons.grid_view_rounded,
          isActive: _viewMode == 'grid',
          onTap: () => setState(() => _viewMode = 'grid'),
          tooltip: 'Tampilan Grid (G)',
          primaryColor: primaryColor,
          textSecondary: textSecondary,
          borderColor: borderColor,
        ),
        _buildViewModeButton(
          icon: Icons.view_list_rounded,
          isActive: _viewMode == 'list',
          onTap: () => setState(() => _viewMode = 'list'),
          tooltip: 'Tampilan List (L)',
          primaryColor: primaryColor,
          textSecondary: textSecondary,
          borderColor: borderColor,
        ),
      ],
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
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? primaryColor : borderColor,
                width: isActive ? 2 : 1,
              ),
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

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String label,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        borderRadius: BorderRadius.circular(8),
        dropdownColor: Theme.of(context).cardColor,
        style: TextStyle(color: textPrimary, fontSize: 13),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary, size: 20),
        underline: const SizedBox(),
        selectedItemBuilder: (context) => items.map((item) => 
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getDropdownLabel(item.value.toString()), style: TextStyle(fontSize: 13, color: textPrimary, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: textSecondary),
            ],
          )
        ).toList(),
      ),
    );
  }

  String _getDropdownLabel(String value) {
    if (_sortOptions.contains(value)) return _getSortLabel(value);
    if (_filterOptions.contains(value)) return _getFilterLabel(value);
    return value;
  }

  Widget _buildGridView(
    List<DesignProject> projects,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    Color cardColor,
    Color surfaceColor,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: projects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(
          context,
          project,
          primaryColor,
          textPrimary,
          textSecondary,
          borderColor,
          cardColor,
          surfaceColor,
        );
      },
    );
  }

  Widget _buildListView(
    List<DesignProject> projects,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    Color cardColor,
    Color surfaceColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectListItem(
          context,
          project,
          primaryColor,
          textPrimary,
          textSecondary,
          borderColor,
          cardColor,
        );
      },
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    DesignProject project,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    Color cardColor,
    Color surfaceColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openProject(context, project),
        onLongPress: () => _showProjectOptions(context, project),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: project.thumbnailPath != null
                          ? Image.asset(
                              project.thumbnailPath!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildThumbnailPlaceholder(project, primaryColor),
                            )
                          : _buildThumbnailPlaceholder(project, primaryColor),
                    ),
                    // More options
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                          onPressed: () => _showProjectOptions(context, project),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ),
                    ),
                    // Element count badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.layers_rounded, size: 10, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '${project.elements.length} layer',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          if (project.sourceTemplate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                project.sourceTemplate!.category,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(project.updatedAt),
                            style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dibuat: ${_formatDate(project.createdAt)}',
                            style: TextStyle(fontSize: 10, color: textSecondary.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectListItem(
    BuildContext context,
    DesignProject project,
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openProject(context, project),
          onLongPress: () => _showProjectOptions(context, project),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 80,
                    height: 60,
                    child: project.thumbnailPath != null
                        ? Image.asset(
                            project.thumbnailPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildSmallThumbnailPlaceholder(project, primaryColor),
                          )
                        : _buildSmallThumbnailPlaceholder(project, primaryColor),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (project.sourceTemplate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            project.sourceTemplate!.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.layers_outlined, size: 12, color: textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${project.elements.length} layer',
                            style: TextStyle(fontSize: 11, color: textSecondary),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time_rounded, size: 12, color: textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Diupdate: ${_formatDate(project.updatedAt)}',
                            style: TextStyle(fontSize: 11, color: textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // More options
                IconButton(
                  icon: Icon(Icons.more_vert_rounded, color: textSecondary),
                  onPressed: () => _showProjectOptions(context, project),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(DesignProject project, Color primaryColor) {
    final bgColor = project.backgroundColor != Colors.white 
        ? project.backgroundColor 
        : (project.sourceTemplate?.backgroundColor ?? primaryColor.withValues(alpha: 0.1));
    
    return Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_rounded,
              size: 40,
              color: primaryColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'Kosong',
              style: TextStyle(
                fontSize: 12,
                color: primaryColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallThumbnailPlaceholder(DesignProject project, Color primaryColor) {
    final bgColor = project.backgroundColor != Colors.white 
        ? project.backgroundColor 
        : (project.sourceTemplate?.backgroundColor ?? primaryColor.withValues(alpha: 0.1));
    
    return Container(
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.description_rounded,
          size: 24,
          color: primaryColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
    Color surfaceColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.folder_open_rounded,
                size: 64,
                color: primaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Belum ada proyek',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Mulai buat desain pertama kamu dengan memilih template\ndan kustomisasi sesuai kebutuhan.',
              style: TextStyle(
                fontSize: 15,
                color: textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditorScreen()),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Mulai dari Kosong'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                  ),
                  icon: const Icon(Icons.grid_view_rounded, size: 20),
                  label: const Text('Pilih Template'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(
    BuildContext context,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada proyek ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah filter atau urutan penyortiran',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openProject(BuildContext context, DesignProject project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          template: project.sourceTemplate,
        ),
      ),
    ).then((_) {
      // Refresh if needed when returning from editor
      setState(() {});
    });
  }

  void _createNewProject(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _NewProjectSheet(
        onCreate: (template) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditorScreen(template: template)),
          );
        },
      ),
    );
  }

  void _showProjectOptions(BuildContext context, DesignProject project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Lanjutkan Edit'),
              onTap: () {
                Navigator.pop(context);
                _openProject(context, project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy_rounded),
              title: const Text('Duplikat'),
              onTap: () {
                Navigator.pop(context);
                _duplicateProject(project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded), // rename_rounded doesn't exist
              title: const Text('Ubah Nama'),
              onTap: () {
                Navigator.pop(context);
                _renameProject(project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Bagikan'),
              onTap: () {
                Navigator.pop(context);
                _showShareDialog(context, project);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteProject(project);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _duplicateProject(DesignProject project) {
    // In real app, this would create a copy in storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proyek "${project.title}" diduplikat (simulasi)')),
    );
  }

  void _renameProject(DesignProject project) {
    final controller = TextEditingController(text: project.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama Proyek'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama proyek'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Proyek diubah nama menjadi "${controller.text}" (simulasi)')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(DesignProject project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Proyek'),
        content: Text('Apakah kamu yakin ingin menghapus "${project.title}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Proyek "${project.title}" dihapus (simulasi)')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context, DesignProject project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bagikan Proyek'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('Salin Tautan'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Unduh PNG'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: const Text('Unduh PDF'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _NewProjectSheet extends StatelessWidget {
  final Function(DesignTemplate) onCreate;

  const _NewProjectSheet({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    // Import templates
    // For now, we'll show a simple selection
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Buat Desain Baru', style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Pilih template untuk memulai', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                itemCount: 4, // Show first 4 templates
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  // This would use actual templates from data
                  return _TemplateOption(
                    title: ['Poster Kreatif', 'Kata Inspirasi', 'Poster Acara', 'Promosi Makanan'][index],
                    category: ['Poster', 'Media Sosial', 'Acara', 'Promosi'][index],
                    color: [const Color(0xFF7D2AE8), const Color(0xFF1A1A2E), const Color(0xFFFF6B35), const Color(0xFFEA580C)][index],
                    onTap: () => onCreate(DesignTemplate.legacy(
                      title: ['Poster Kreatif', 'Kata Inspirasi', 'Poster Acara', 'Promosi Makanan'][index],
                      category: ['Poster', 'Media Sosial', 'Acara', 'Promosi'][index],
                      imagePath: ['assets/images/poster_social.jpg', 'assets/images/poster_quote.jpg', 'assets/images/poster_event.jpg', 'assets/images/poster_food.jpg'][index],
                      description: 'Template ${['Poster Kreatif', 'Kata Inspirasi', 'Poster Acara', 'Promosi Makanan'][index]}',
                    )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateOption extends StatelessWidget {
  final String title;
  final String category;
  final Color color;
  final VoidCallback onTap;

  const _TemplateOption({
    required this.title,
    required this.category,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mulai desain →',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}