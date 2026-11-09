import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/templates.dart';
import '../models/design_template.dart';
import '../models/design_element.dart';
import '../models/design_project.dart';
import 'package:uuid/uuid.dart';

class EditorScreen extends StatefulWidget {
  final DesignTemplate? template;

  const EditorScreen({super.key, this.template});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late DesignProject _project;
  final Uuid _uuid = const Uuid();
  
  // Editor state
  DesignElement? _selectedElement;
  List<DesignProject> _history = [];
  int _historyIndex = -1;
  bool _showLayersPanel = false;
  
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  
  // Canvas settings
  static const double _canvasAspectRatio = 3 / 4;
  static const Size _baseCanvasSize = Size(800, 1067);
  
  // Tool state
  EditorTool _activeTool = EditorTool.select;
  final TextStyle _defaultTextStyle = const TextStyle(
    color: Color(0xFF1A1A2E),
    fontSize: 32,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    height: 1.3,
  );

  @override
  void initState() {
    super.initState();
    final template = widget.template ?? designTemplates.first;
    _project = DesignProject.fromTemplate(template);
    _titleController.text = _project.title;
    
    // Add default elements from template
    if (template.defaultElements != null && template.defaultElements!.isNotEmpty) {
      _project = _project.copyWith(
        elements: List.from(template.defaultElements!),
      );
    }
    
    _saveToHistory();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveToHistory() {
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }
    _history.add(_project);
    _historyIndex = _history.length - 1;
    
    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _project = _history[_historyIndex];
        _selectedElement = null;
      });
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _project = _history[_historyIndex];
        _selectedElement = null;
      });
    }
  }

  void _updateProject(DesignProject newProject) {
    setState(() {
      _project = newProject;
    });
    _saveToHistory();
  }

  void _selectElement(DesignElement? element) {
    setState(() {
      _selectedElement = element;
    });
  }

  void _addTextElement() {
    final newElement = DesignElement(
      id: _uuid.v4(),
      type: ElementType.text,
      position: Offset(_baseCanvasSize.width / 2 - 150, _baseCanvasSize.height / 2 - 50),
      size: const Size(300, 100),
      zIndex: _project.elements.length,
      text: 'Teks baru',
      textStyle: _defaultTextStyle,
      textAlign: TextAlign.center,
    );
    
    _updateProject(_project.copyWith(
      elements: [..._project.elements, newElement],
    ));
    _selectElement(newElement);
  }

  void _addShapeElement(ShapeType shapeType) {
    Color fillColor;
    switch (shapeType) {
      case ShapeType.rectangle:
        fillColor = const Color(0xFF7D2AE8);
        break;
      case ShapeType.circle:
        fillColor = const Color(0xFF00C4CC);
        break;
      case ShapeType.roundedRectangle:
        fillColor = const Color(0xFF4B61D1);
        break;
      case ShapeType.triangle:
        fillColor = const Color(0xFFEA580C);
        break;
      case ShapeType.star:
        fillColor = const Color(0xFFF59E0B);
        break;
    }

    final newElement = DesignElement(
      id: _uuid.v4(),
      type: ElementType.shape,
      position: Offset(_baseCanvasSize.width / 2 - 75, _baseCanvasSize.height / 2 - 75),
      size: const Size(150, 150),
      zIndex: _project.elements.length,
      fillColor: fillColor,
      shapeType: shapeType,
      borderRadius: shapeType == ShapeType.roundedRectangle ? BorderRadius.circular(24) : null,
    );
    
    _updateProject(_project.copyWith(
      elements: [..._project.elements, newElement],
    ));
    _selectElement(newElement);
  }

  void _updateSelectedElement(DesignElement updatedElement) {
    if (_selectedElement == null) return;
    
    final updatedElements = _project.elements.map((e) {
      return e.id == _selectedElement!.id ? updatedElement : e;
    }).toList();
    
    _updateProject(_project.copyWith(elements: updatedElements));
    _selectedElement = updatedElement;
  }

  void _deleteSelectedElement() {
    if (_selectedElement == null) return;
    
    final updatedElements = _project.elements.where((e) => e.id != _selectedElement!.id).toList();
    
    _updateProject(_project.copyWith(elements: updatedElements));
    setState(() {
      _selectedElement = null;
    });
  }

  void _duplicateSelectedElement() {
    if (_selectedElement == null) return;
    
    final duplicated = _selectedElement!.copyWith(
      id: _uuid.v4(),
      position: Offset(
        _selectedElement!.position.dx + 20,
        _selectedElement!.position.dy + 20,
      ),
      zIndex: _project.elements.length,
    );
    
    _updateProject(_project.copyWith(
      elements: [..._project.elements, duplicated],
    ));
    _selectElement(duplicated);
  }

  void _bringToFront() {
    if (_selectedElement == null) return;
    
    final maxZ = _project.elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b);
    final updated = _selectedElement!.copyWith(zIndex: maxZ + 1);
    _updateSelectedElement(updated);
  }

  void _sendToBack() {
    if (_selectedElement == null) return;
    
    final minZ = _project.elements.map((e) => e.zIndex).reduce((a, b) => a < b ? a : b);
    final updated = _selectedElement!.copyWith(zIndex: minZ - 1);
    _updateSelectedElement(updated);
  }

  void _showAddElementsBottomSheet(BuildContext context) {
    final primaryColor = const Color(0xFF7D2AE8);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.7,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tambah Elemen', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Bentuk', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildShapeOption(Icons.rectangle_outlined, 'Persegi', ShapeType.rectangle, primaryColor),
                  _buildShapeOption(Icons.circle_outlined, 'Lingkaran', ShapeType.circle, primaryColor),
                  _buildShapeOption(Icons.rounded_corner_outlined, 'Persegi Bulat', ShapeType.roundedRectangle, primaryColor),
                  _buildShapeOption(Icons.change_history_outlined, 'Segitiga', ShapeType.triangle, primaryColor),
                  _buildShapeOption(Icons.star_outline_rounded, 'Bintang', ShapeType.star, primaryColor),
                ],
              ),
              const SizedBox(height: 24),
              Text('Lainnya', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildElementOption(Icons.text_fields_rounded, 'Teks', () {
                    Navigator.pop(context);
                    _addTextElement();
                  }, primaryColor),
                  _buildElementOption(Icons.image_outlined, 'Gambar', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pilih gambar (simulasi)')),
                    );
                  }, primaryColor),
                  _buildElementOption(Icons.timeline_outlined, 'Garis', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tambah garis (simulasi)')),
                    );
                  }, primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShapeOption(IconData icon, String label, ShapeType shapeType, Color primaryColor) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _addShapeElement(shapeType);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: primaryColor),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildElementOption(IconData icon, String label, VoidCallback onTap, Color primaryColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: primaryColor),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final canvasBgColor = isDark ? const Color(0xFF1A1A24) : const Color(0xFFF0F0F5);
    final toolbarColor = isDark ? const Color(0xFF252530) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFFB0B0B8) : const Color(0xFF6B6B80);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE8E8EE);
    final primaryColor = const Color(0xFF7D2AE8);

    // Sort elements by zIndex for rendering
    final sortedElements = List<DesignElement>.from(_project.elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: _buildAppBar(context, toolbarColor, borderColor, textPrimary, textSecondary, primaryColor, isDark),
      body: Row(
        children: [
          // Left Toolbar
          _buildLeftToolbar(context, toolbarColor, borderColor, textPrimary, textSecondary, primaryColor),
          
          // Canvas Area
          Expanded(
            child: Column(
              children: [
                // Top Canvas Toolbar
                _buildTopCanvasToolbar(context, toolbarColor, borderColor, textPrimary, textSecondary, primaryColor),
                
                // Canvas
                Expanded(
                  child: Center(
                    child: Container(
                      color: canvasBgColor,
                      padding: const EdgeInsets.all(32),
                      child: _buildCanvas(context, sortedElements, primaryColor),
                    ),
                  ),
                ),
                
                // Bottom Status Bar
                _buildStatusBar(context, toolbarColor, borderColor, textPrimary, textSecondary, primaryColor, isDark),
              ],
            ),
          ),
          
          // Right Panel (Layers / Properties)
          _buildRightPanel(context, sortedElements, toolbarColor, borderColor, textPrimary, textSecondary, primaryColor, isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    Color toolbarColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: toolbarColor,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: borderColor,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Tooltip(
          message: 'Kembali ke Beranda',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 24),
              ),
            ),
          ),
        ),
      ),
      title: TextField(
        controller: _titleController,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Desain tanpa judul',
          hintStyle: TextStyle(color: textSecondary, fontSize: 16, fontWeight: FontWeight.w400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          isDense: true,
        ),
        onChanged: (value) {
          setState(() {
            _project = _project.copyWith(title: value);
          });
        },
      ),
      centerTitle: false,
      actions: [
        // Undo/Redo Group
        _buildAppBarActionGroup(
          context,
          toolbarColor,
          borderColor,
          textPrimary,
          textSecondary,
          primaryColor,
          isDark,
          children: [
            _buildIconButton(
              context,
              icon: Icons.undo_rounded,
              enabled: _historyIndex > 0,
              onPressed: _undo,
              tooltip: 'Batal (Ctrl+Z)',
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _buildIconButton(
              context,
              icon: Icons.redo_rounded,
              enabled: _historyIndex < _history.length - 1,
              onPressed: _redo,
              tooltip: 'Ulangi (Ctrl+Y)',
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ],
        ),
        
        const SizedBox(width: 8),
        
        // Position indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Posisi: ${_selectedElement != null ? "${_selectedElement!.position.dx.round()}, ${_selectedElement!.position.dy.round()}" : "-"}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Save button
        _buildIconButton(
          context,
          icon: Icons.save_outlined,
          onPressed: () => _showSaveDialog(context),
          tooltip: 'Simpan (Ctrl+S)',
          isTextButton: true,
          label: 'Simpan',
          primaryColor: primaryColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        
        const SizedBox(width: 8),
        
        // Share button
        _buildIconButton(
          context,
          icon: Icons.share_rounded,
          onPressed: () => _showShareDialog(context),
          tooltip: 'Bagikan',
          isFilled: true,
          label: 'Bagikan',
          primaryColor: primaryColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAppBarActionGroup(
    BuildContext context,
    Color toolbarColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    bool isDark, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D3A) : const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: children,
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    bool enabled = true,
    VoidCallback? onPressed,
    required String tooltip,
    bool isFilled = false,
    bool isTextButton = false,
    String? label,
    required Color primaryColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final color = enabled ? (isFilled ? Colors.white : (isTextButton ? primaryColor : textPrimary)) : textSecondary;
    final bgColor = isFilled ? (enabled ? primaryColor : primaryColor.withValues(alpha: 0.4)) : Colors.transparent;
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: isTextButton || label != null
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: label != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  )
                : Icon(icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftToolbar(
    BuildContext context,
    Color toolbarColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
  ) {
    final tools = [
      EditorToolItem(EditorTool.select, Icons.mouse_rounded, 'Pilih', 'V'),
      EditorToolItem(EditorTool.text, Icons.text_fields_rounded, 'Teks', 'T'),
      EditorToolItem(EditorTool.elements, Icons.widgets_rounded, 'Elemen', 'E'),
      EditorToolItem(EditorTool.upload, Icons.upload_file_rounded, 'Unggah', 'U'),
      EditorToolItem(EditorTool.color, Icons.palette_outlined, 'Warna', 'C'),
      EditorToolItem(EditorTool.effects, Icons.auto_awesome_outlined, 'Efek', 'F'),
    ];

    return Container(
      width: 64,
      color: toolbarColor,
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...tools.map((tool) => _buildToolbarButton(
            context,
            icon: tool.icon,
            label: tool.label,
            isActive: _activeTool == tool.tool,
            onTap: () => setState(() => _activeTool = tool.tool),
            tooltip: '${tool.label} (${tool.shortcut})',
            primaryColor: primaryColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          )),
          const Spacer(),
          // Layers toggle
          _buildToolbarButton(
            context,
            icon: _showLayersPanel ? Icons.layers_rounded : Icons.layers_outlined,
            label: 'Layer',
            isActive: _showLayersPanel,
            onTap: () => setState(() => _showLayersPanel = !_showLayersPanel),
            tooltip: 'Panel Layer (L)',
            primaryColor: primaryColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
    required Color primaryColor,
    required Color textPrimary,
    required Color textSecondary,
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
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: primaryColor, width: 2) : null,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isActive ? primaryColor : textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCanvasToolbar(
    BuildContext context,
    Color toolbarColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: toolbarColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Zoom controls
          _buildIconButton(
            context,
            icon: Icons.remove_rounded,
            onPressed: () {},
            tooltip: 'Perkecil (-)',
            primaryColor: primaryColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          Container(
            width: 1,
            height: 24,
            color: borderColor,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Text(
            '100%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: borderColor,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          _buildIconButton(
            context,
            icon: Icons.add_rounded,
            onPressed: () {},
            tooltip: 'Perbesar (+)',
            primaryColor: primaryColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(width: 16),
          
          // Alignment tools (when element selected)
          if (_selectedElement != null) ...[
            Text(
              'Posisi & Ukuran',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            _buildAlignButton(Icons.format_align_left, 'Kiri'),
            _buildAlignButton(Icons.format_align_center, 'Tengah'),
            _buildAlignButton(Icons.format_align_right, 'Kanan'),
            const SizedBox(width: 16),
            _buildAlignButton(Icons.vertical_align_top, 'Atas'),
            _buildAlignButton(Icons.vertical_align_center, 'Tengah'),
            _buildAlignButton(Icons.vertical_align_bottom, 'Bawah'),
            const Spacer(),
            // Layer controls
            _buildLayerButton(Icons.keyboard_arrow_up_rounded, 'Naik', _bringToFront),
            _buildLayerButton(Icons.keyboard_arrow_down_rounded, 'Turun', null),
            _buildLayerButton(Icons.keyboard_double_arrow_up_rounded, 'Depan', _bringToFront),
            _buildLayerButton(Icons.keyboard_double_arrow_down_rounded, 'Belakang', _sendToBack),
          ] else ...[
            const Spacer(),
            Text(
              'Pilih elemen untuk mengedit',
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(),
          ],
          
          // Canvas info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_project.canvasSize.width.round()} × ${_project.canvasSize.height.round()} px',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerButton(IconData icon, String tooltip, VoidCallback? onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: onTap != null ? const Color(0xFF7D2AE8) : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas(
    BuildContext context,
    List<DesignElement> elements,
    Color primaryColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate canvas display size maintaining aspect ratio
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        double canvasWidth, canvasHeight;
        
        if (maxWidth / maxHeight > _canvasAspectRatio) {
          canvasHeight = maxHeight;
          canvasWidth = canvasHeight * _canvasAspectRatio;
        } else {
          canvasWidth = maxWidth;
          canvasHeight = canvasWidth / _canvasAspectRatio;
        }
        
        final scaleX = canvasWidth / _baseCanvasSize.width;
        final scaleY = canvasHeight / _baseCanvasSize.height;
        final scale = scaleX < scaleY ? scaleX : scaleY;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: _baseCanvasSize.width,
            height: _baseCanvasSize.height,
            decoration: BoxDecoration(
              color: _project.backgroundColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Elements
                ...elements.map((element) => _buildElementWidget(element, primaryColor)).toList(),
                
                // Selection handles for selected element
                if (_selectedElement != null)
                  _buildSelectionHandles(_selectedElement!, primaryColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildElementWidget(DesignElement element, Color primaryColor) {
    final isLocked = element.isLocked;
    
    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      width: element.size.width,
      height: element.size.height,
      child: Transform.rotate(
        angle: element.rotation,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Element content
            GestureDetector(
              onTap: isLocked ? null : () => _selectElement(element),
              onPanStart: isLocked ? null : (details) {},
              onPanUpdate: isLocked ? null : (details) {
                _updateSelectedElement(element.copyWith(
                  position: Offset(
                    element.position.dx + details.delta.dx,
                    element.position.dy + details.delta.dy,
                  ),
                ));
              },
              child: _buildElementContent(element, primaryColor),
            ),
            
            // Lock indicator
            if (isLocked)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.lock_rounded, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementContent(DesignElement element, Color primaryColor) {
    switch (element.type) {
      case ElementType.text:
        return Container(
          width: element.size.width,
          height: element.size.height,
          alignment: Alignment.center,
          child: TextField(
            controller: TextEditingController(text: element.text ?? ''),
            textAlign: element.textAlign ?? TextAlign.center,
            style: element.textStyle ?? _defaultTextStyle,
            decoration: InputDecoration(
              hintText: element.text?.isEmpty == true ? 'Ketik teks...' : null,
              hintStyle: (element.textStyle ?? _defaultTextStyle).copyWith(
                color: (element.textStyle?.color ?? const Color(0xFF1A1A2E)).withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (value) {
              _updateSelectedElement(element.copyWith(text: value));
            },
            onTapOutside: (_) => _selectElement(null),
            autofocus: false,
            showCursor: _selectedElement?.id == element.id,
          ),
        );
      
      case ElementType.image:
        return Container(
          width: element.size.width,
          height: element.size.height,
          decoration: BoxDecoration(
            borderRadius: element.borderRadius,
            border: element.borderColor != null && element.borderWidth != null && element.borderWidth! > 0
                ? Border.all(color: element.borderColor!, width: element.borderWidth!)
                : null,
          ),
          child: ClipRRect(
            borderRadius: element.borderRadius ?? BorderRadius.zero,
            child: element.imagePath != null
                ? Image.asset(
                    element.imagePath!,
                    fit: element.fit ?? BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => _buildPlaceholder('Gambar', element.fillColor),
                  )
                : element.imageUrl != null
                    ? Image.network(
                        element.imageUrl!,
                        fit: element.fit ?? BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => _buildPlaceholder('Gambar', element.fillColor),
                      )
                    : _buildPlaceholder('Gambar', element.fillColor),
          ),
        );
      
      case ElementType.shape:
        return _buildShape(element);
      
      case ElementType.line:
        return CustomPaint(
          size: element.size,
          painter: LinePainter(
            start: element.lineStart ?? Offset.zero,
            end: element.lineEnd ?? Offset(element.size.width, 0),
            color: element.borderColor ?? primaryColor,
            strokeWidth: element.strokeWidth ?? 2,
            strokeCap: element.strokeCap ?? StrokeCap.round,
          ),
        );
    }
  }

  Widget _buildShape(DesignElement element) {
    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        color: element.fillColor,
        borderRadius: element.borderRadius,
        border: element.borderColor != null && element.borderWidth != null && element.borderWidth! > 0
            ? Border.all(color: element.borderColor!, width: element.borderWidth!)
            : null,
      ),
      child: element.shapeType == ShapeType.triangle
          ? CustomPaint(
              painter: TrianglePainter(color: element.fillColor ?? Colors.transparent),
            )
          : element.shapeType == ShapeType.star
              ? CustomPaint(
                  painter: StarPainter(color: element.fillColor ?? Colors.transparent),
                )
              : null,
    );
  }

  Widget _buildPlaceholder(String label, Color? bgColor) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgColor ?? const Color(0xFFECE4FF),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 32, color: const Color(0xFF7D2AE8).withValues(alpha: 0.7)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF7D2AE8).withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionHandles(DesignElement element, Color primaryColor) {
    return Positioned(
      left: element.position.dx - 8,
      top: element.position.dy - 8,
      width: element.size.width + 16,
      height: element.size.height + 16,
      child: IgnorePointer(
        ignoring: element.isLocked,
        child: CustomPaint(
          painter: SelectionHandlesPainter(
            primaryColor: primaryColor,
            rotation: element.rotation,
            onRotate: (angle) {
              _updateSelectedElement(element.copyWith(rotation: angle));
            },
            onResize: (newSize, newPosition) {
              _updateSelectedElement(element.copyWith(
                size: newSize,
                position: newPosition,
              ));
            },
          ),
          size: Size(element.size.width + 16, element.size.height + 16),
        ),
      ),
    );
  }

  Widget _buildStatusBar(
    BuildContext context,
    Color toolbarColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    bool isDark,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: toolbarColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Zoom controls
          _buildStatusButton(
            context,
            icon: Icons.remove_rounded,
            tooltip: 'Perkecil (Ctrl+-)',
            onPressed: () {},
            textSecondary: textSecondary,
            borderColor: borderColor,
          ),
          Container(width: 1, height: 24, color: borderColor, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Text(
            '100%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          Container(width: 1, height: 24, color: borderColor, margin: const EdgeInsets.symmetric(horizontal: 12)),
          _buildStatusButton(
            context,
            icon: Icons.add_rounded,
            tooltip: 'Perbesar (Ctrl++)',
            onPressed: () {},
            textSecondary: textSecondary,
            borderColor: borderColor,
          ),
          
          const SizedBox(width: 24),
          
          // Canvas info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_project.canvasSize.width.round()} × ${_project.canvasSize.height.round()} px  •  ${_project.elements.length} elemen',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Quick actions when nothing selected
          if (_selectedElement == null) ...[
            _buildStatusButton(
              context,
              icon: Icons.text_fields_rounded,
              tooltip: 'Tambah Teks (T)',
              onPressed: _addTextElement,
              textSecondary: textSecondary,
              borderColor: borderColor,
              isFilled: true,
              primaryColor: primaryColor,
            ),
            const SizedBox(width: 8),
            _buildStatusButton(
              context,
              icon: Icons.widgets_rounded,
              tooltip: 'Tambah Elemen (E)',
              onPressed: () => _showAddElementsBottomSheet(context),
              textSecondary: textSecondary,
              borderColor: borderColor,
            ),
          ] else ...[
            // Quick actions when element selected
            _buildStatusButton(
              context,
              icon: Icons.content_copy_rounded,
              tooltip: 'Duplikat (Ctrl+D)',
              onPressed: _duplicateSelectedElement,
              textSecondary: textSecondary,
              borderColor: borderColor,
            ),
            const SizedBox(width: 8),
            _buildStatusButton(
              context,
              icon: Icons.delete_outline_rounded,
              tooltip: 'Hapus (Delete)',
              onPressed: _deleteSelectedElement,
              textSecondary: Colors.red.shade400,
              borderColor: borderColor,
              iconColor: Colors.red.shade400,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color textSecondary,
    required Color borderColor,
    bool isFilled = false,
    Color? primaryColor,
    Color? iconColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFilled ? (primaryColor ?? const Color(0xFF7D2AE8)) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isFilled ? null : Border.all(color: borderColor),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isFilled ? Colors.white : (iconColor ?? textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel(
    BuildContext context,
    List<DesignElement> sortedElements,
    Color toolbarColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    bool isDark,
  ) {
    if (!_showLayersPanel) {
      return const SizedBox(width: 0);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 280,
      decoration: BoxDecoration(
        color: toolbarColor,
        border: Border(left: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          // Panel header
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Text(
                  'Layer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textSecondary, size: 20),
                  onPressed: () => setState(() => _showLayersPanel = false),
                  tooltip: 'Tutup Panel',
                ),
              ],
            ),
          ),
          
          // Layers list
          Expanded(
            child: _project.elements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.layers_outlined, size: 48, color: textSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada layer',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tambahkan teks, gambar, atau bentuk\nuntuk memulai desain',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: sortedElements.length,
                    itemBuilder: (context, index) {
                      final element = sortedElements[index];
                      final isSelected = _selectedElement?.id == element.id;
                      return _buildLayerItem(
                        context,
                        element,
                        isSelected,
                        index,
                        sortedElements.length,
                        textPrimary,
                        textSecondary,
                        primaryColor,
                        borderColor,
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerItem(
    BuildContext context,
    DesignElement element,
    bool isSelected,
    int index,
    int total,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    Color borderColor,
    bool isDark,
  ) {
    final iconData = element.type == ElementType.text
        ? Icons.text_fields_rounded
        : element.type == ElementType.image
            ? Icons.image_rounded
            : element.type == ElementType.shape
                ? Icons.circle_outlined
                : Icons.timeline_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: primaryColor, width: 1.5) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectElement(element),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Drag handle
                Icon(Icons.drag_indicator_rounded, size: 20, color: textSecondary.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                
                // Element icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: element.fillColor?.withValues(alpha: 0.2) ?? primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    iconData,
                    size: 18,
                    color: element.fillColor ?? primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                
                // Element info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        element.type == ElementType.text
                            ? (element.text?.isNotEmpty == true
                                ? (element.text!.length > 20 ? '${element.text!.substring(0, 20)}...' : element.text!)
                                : 'Teks baru')
                            : element.type == ElementType.shape
                                ? _getShapeName(element.shapeType)
                                : 'Gambar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? primaryColor : textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Z-Index: ${element.zIndex} • ${element.size.width.round()}×${element.size.height.round()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Visibility toggle
                IconButton(
                  icon: Icon(
                    element.isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    size: 18,
                    color: element.isVisible ? textSecondary : textSecondary.withValues(alpha: 0.4),
                  ),
                  onPressed: () => _updateSelectedElement(element.copyWith(isVisible: !element.isVisible)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                
                // Lock toggle
                IconButton(
                  icon: Icon(
                    element.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    size: 18,
                    color: element.isLocked ? primaryColor : textSecondary.withValues(alpha: 0.4),
                  ),
                  onPressed: () => _updateSelectedElement(element.copyWith(isLocked: !element.isLocked)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                
                // More options
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 18, color: textSecondary),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    switch (value) {
                      case 'duplicate':
                        _duplicateSelectedElement();
                        break;
                      case 'delete':
                        _deleteSelectedElement();
                        break;
                      case 'bring_front':
                        _bringToFront();
                        break;
                      case 'send_back':
                        _sendToBack();
                        break;
                      case 'rename':
                        _showRenameDialog(element);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.content_copy), SizedBox(width: 8), Text('Duplikat')])),
                    const PopupMenuItem(value: 'rename', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Ubah Nama')])),
                    const PopupMenuItem(value: 'bring_front', child: Row(children: [Icon(Icons.keyboard_double_arrow_up), SizedBox(width: 8), Text('Ke Depan')])),
                    const PopupMenuItem(value: 'send_back', child: Row(children: [Icon(Icons.keyboard_double_arrow_down), SizedBox(width: 8), Text('Ke Belakang')])),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getShapeName(ShapeType? type) {
    switch (type) {
      case ShapeType.rectangle:
        return 'Persegi Panjang';
      case ShapeType.circle:
        return 'Lingkaran';
      case ShapeType.roundedRectangle:
        return 'Persegi Bulat';
      case ShapeType.triangle:
        return 'Segitiga';
      case ShapeType.star:
        return 'Bintang';
      default:
        return 'Bentuk';
    }
  }

  void _showRenameDialog(DesignElement element) {
    final controller = TextEditingController(text: element.type == ElementType.text ? (element.text ?? '') : _getShapeName(element.shapeType));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama Layer'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama layer'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simpan Desain'),
        content: const Text('Desain telah disimpan ke proyek Anda (simulasi).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bagikan Desain'),
        content: const Text('Fitur bagikan akan tersedia segera (simulasi).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showFontSizePicker(DesignElement element) {
    double currentSize = element.textStyle?.fontSize ?? 32;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ukuran Font', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Slider(
                value: currentSize,
                min: 10,
                max: 120,
                divisions: 110,
                label: currentSize.round().toString(),
                onChanged: (value) {
                  setModalState(() => currentSize = value);
                },
              ),
              Text('${currentSize.round()} px', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  _updateSelectedElement(element.copyWith(
                    textStyle: (element.textStyle ?? _defaultTextStyle).copyWith(
                      fontSize: currentSize,
                    ),
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPickerDialog(DesignElement element, bool isFill) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ColorPickerSheet(
        initialColor: isFill ? (element.fillColor ?? Colors.transparent) : (element.borderColor ?? Colors.transparent),
        onColorSelected: (color) {
          if (isFill) {
            _updateSelectedElement(element.copyWith(fillColor: color));
          } else {
            _updateSelectedElement(element.copyWith(borderColor: color, borderWidth: element.borderWidth ?? 2));
          }
        },
      ),
    );
  }

  void _showBorderRadiusPicker(DesignElement element) {
    double currentRadius = element.borderRadius?.topLeft.x ?? 0;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Border Radius', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Slider(
                value: currentRadius,
                min: 0,
                max: 100,
                divisions: 100,
                label: currentRadius.round().toString(),
                onChanged: (value) {
                  setModalState(() => currentRadius = value);
                },
              ),
              Text('${currentRadius.round()} px', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  _updateSelectedElement(element.copyWith(
                    borderRadius: BorderRadius.circular(currentRadius),
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOpacitySlider(DesignElement element) {
    double currentOpacity = element.fillColor?.a ?? 1.0;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Opasitas', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Slider(
                value: currentOpacity,
                min: 0,
                max: 1,
                divisions: 100,
                label: '${(currentOpacity * 100).round()}%',
                onChanged: (value) {
                  setModalState(() => currentOpacity = value);
                },
              ),
              Text('${(currentOpacity * 100).round()}%', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (element.fillColor != null) {
                    _updateSelectedElement(element.copyWith(
                      fillColor: Color.fromARGB(
                        (currentOpacity * 255).round(),
                        element.fillColor!.r.round(),
                        element.fillColor!.g.round(),
                        element.fillColor!.b.round(),
                      ),
                    ));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditorToolItem {
  final EditorTool tool;
  final IconData icon;
  final String label;
  final String shortcut;

  const EditorToolItem(this.tool, this.icon, this.label, this.shortcut);
}

enum EditorTool { select, text, elements, upload, color, effects }

class SelectionHandlesPainter extends CustomPainter {
  final Color primaryColor;
  final double rotation;
  final Function(double) onRotate;
  final Function(Size, Offset) onResize;
  
  SelectionHandlesPainter({
    required this.primaryColor,
    required this.rotation,
    required this.onRotate,
    required this.onResize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final fillPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    final handleSize = 12.0;
    final handleRadius = handleSize / 2;
    
    // Draw bounding box
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
    
    // Draw corner handles
    final corners = [
      Offset(0, 0), // top-left
      Offset(size.width, 0), // top-right
      Offset(size.width, size.height), // bottom-right
      Offset(0, size.height), // bottom-left
    ];
    
    for (final corner in corners) {
      canvas.drawRect(
        Rect.fromCenter(center: corner, width: handleSize, height: handleSize),
        fillPaint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: corner, width: handleSize, height: handleSize),
        paint,
      );
    }
    
    // Draw rotation handle
    final rotateHandleOffset = Offset(size.width / 2, -30);
    canvas.drawLine(
      Offset(size.width / 2, 0),
      rotateHandleOffset,
      paint..strokeWidth = 1..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(rotateHandleOffset, handleRadius, fillPaint);
    canvas.drawCircle(rotateHandleOffset, handleRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;

  LinePainter({
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
    required this.strokeCap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4;
    final spikes = 5;
    
    for (int i = 0; i < spikes * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi / spikes) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ColorPickerSheet extends StatelessWidget {
  final Color initialColor;
  final Function(Color) onColorSelected;

  const _ColorPickerSheet({
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.transparent,
      Colors.white,
      Colors.black,
      const Color(0xFF7D2AE8),
      const Color(0xFF00C4CC),
      const Color(0xFF4B61D1),
      const Color(0xFFEA580C),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF6366F1),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
      const Color(0xFFF97316),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pilih Warna', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((color) {
              final isTransparent = color == Colors.transparent;
              return GestureDetector(
                onTap: () {
                  onColorSelected(color);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTransparent ? Colors.grey.shade400 : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      if (!isTransparent)
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: isTransparent
                      ? const Icon(Icons.clear, size: 20, color: Colors.grey)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}