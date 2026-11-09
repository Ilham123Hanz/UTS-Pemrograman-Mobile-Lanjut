import 'package:flutter/material.dart';
import 'design_element.dart';

class DesignTemplate {
  final String id;
  final String title;
  final String category;
  final String imagePath;
  final String description;
  final List<String> tags;
  final Size? canvasSize;
  final Color? backgroundColor;
  final List<DesignElement>? defaultElements;

  const DesignTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.imagePath,
    required this.description,
    this.tags = const [],
    this.canvasSize,
    this.backgroundColor,
    this.defaultElements,
  });

  // Factory untuk backward compatibility
  factory DesignTemplate.legacy({
    required String title,
    required String category,
    required String imagePath,
    required String description,
  }) {
    return DesignTemplate(
      id: title.toLowerCase().replaceAll(' ', '_'),
      title: title,
      category: category,
      imagePath: imagePath,
      description: description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'imagePath': imagePath,
      'description': description,
      'tags': tags,
      'canvasSize': canvasSize != null ? {'width': canvasSize!.width, 'height': canvasSize!.height} : null,
      'backgroundColor': backgroundColor?.toARGB32(),
      'defaultElements': defaultElements?.map((e) => e.toJson()).toList(),
    };
  }

  factory DesignTemplate.fromJson(Map<String, dynamic> json) {
    return DesignTemplate(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      imagePath: json['imagePath'],
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      canvasSize: json['canvasSize'] != null ? Size(json['canvasSize']['width'], json['canvasSize']['height']) : null,
      backgroundColor: json['backgroundColor'] != null ? Color(json['backgroundColor']) : null,
      defaultElements: json['defaultElements'] != null ? (json['defaultElements'] as List).map((e) => DesignElement.fromJson(e)).toList() : null,
    );
  }
}