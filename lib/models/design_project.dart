import 'package:flutter/material.dart';
import 'design_element.dart';
import 'design_template.dart';

class DesignProject {
  final String id;
  final String title;
  final String? thumbnailPath;
  final List<DesignElement> elements;
  final Size canvasSize;
  final Color backgroundColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final DesignTemplate? sourceTemplate;

  const DesignProject({
    required this.id,
    required this.title,
    this.thumbnailPath,
    required this.elements,
    required this.canvasSize,
    this.backgroundColor = Colors.white,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.sourceTemplate,
  });

  DesignProject copyWith({
    String? id,
    String? title,
    String? thumbnailPath,
    List<DesignElement>? elements,
    Size? canvasSize,
    Color? backgroundColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    DesignTemplate? sourceTemplate,
  }) {
    return DesignProject(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      elements: elements ?? this.elements,
      canvasSize: canvasSize ?? this.canvasSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      sourceTemplate: sourceTemplate ?? this.sourceTemplate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailPath': thumbnailPath,
      'elements': elements.map((e) => e.toJson()).toList(),
      'canvasSize': {'width': canvasSize.width, 'height': canvasSize.height},
      'backgroundColor': backgroundColor.toARGB32(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'sourceTemplate': sourceTemplate != null ? {
        'title': sourceTemplate!.title,
        'category': sourceTemplate!.category,
        'imagePath': sourceTemplate!.imagePath,
        'description': sourceTemplate!.description,
      } : null,
    };
  }

  factory DesignProject.fromJson(Map<String, dynamic> json) {
    return DesignProject(
      id: json['id'],
      title: json['title'],
      thumbnailPath: json['thumbnailPath'],
      elements: (json['elements'] as List).map((e) => DesignElement.fromJson(e)).toList(),
      canvasSize: Size(json['canvasSize']['width'], json['canvasSize']['height']),
      backgroundColor: Color(json['backgroundColor']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      description: json['description'],
      sourceTemplate: json['sourceTemplate'] != null ? DesignTemplate(
        id: json['sourceTemplate']['id'] ?? '',
        title: json['sourceTemplate']['title'],
        category: json['sourceTemplate']['category'],
        imagePath: json['sourceTemplate']['imagePath'],
        description: json['sourceTemplate']['description'],
      ) : null,
    );
  }

  // Factory untuk membuat project baru dari template
  factory DesignProject.fromTemplate(DesignTemplate template) {
    final now = DateTime.now();
    return DesignProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: template.title,
      thumbnailPath: template.imagePath,
      elements: [],
      canvasSize: template.canvasSize ?? const Size(800, 1067),
      backgroundColor: template.backgroundColor ?? Colors.white,
      createdAt: now,
      updatedAt: now,
      description: template.description,
      sourceTemplate: template,
    );
  }
}