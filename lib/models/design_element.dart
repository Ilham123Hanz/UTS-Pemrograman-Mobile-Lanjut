import 'package:flutter/material.dart';

enum ElementType { text, image, shape, line }

TextDecoration? _parseTextDecoration(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    switch (value) {
      case 'TextDecoration.none': return TextDecoration.none;
      case 'TextDecoration.underline': return TextDecoration.underline;
      case 'TextDecoration.overline': return TextDecoration.overline;
      case 'TextDecoration.lineThrough': return TextDecoration.lineThrough;
      default: return null;
    }
  }
  return null;
}

class DesignElement {
  final String id;
  final ElementType type;
  final Offset position;
  final Size size;
  final double rotation;
  final int zIndex;
  final bool isLocked;
  final bool isVisible;
  
  // Text properties
  final String? text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  
  // Image properties
  final String? imagePath;
  final String? imageUrl;
  final BoxFit? fit;
  
  // Shape properties
  final Color? fillColor;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final ShapeType? shapeType;
  
  // Line properties
  final Offset? lineStart;
  final Offset? lineEnd;
  final double? strokeWidth;
  final StrokeCap? strokeCap;

  const DesignElement({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    this.rotation = 0.0,
    this.zIndex = 0,
    this.isLocked = false,
    this.isVisible = true,
    this.text,
    this.textStyle,
    this.textAlign,
    this.imagePath,
    this.imageUrl,
    this.fit,
    this.fillColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.shapeType,
    this.lineStart,
    this.lineEnd,
    this.strokeWidth,
    this.strokeCap,
  });

  DesignElement copyWith({
    String? id,
    ElementType? type,
    Offset? position,
    Size? size,
    double? rotation,
    int? zIndex,
    bool? isLocked,
    bool? isVisible,
    String? text,
    TextStyle? textStyle,
    TextAlign? textAlign,
    String? imagePath,
    String? imageUrl,
    BoxFit? fit,
    Color? fillColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    ShapeType? shapeType,
    Offset? lineStart,
    Offset? lineEnd,
    double? strokeWidth,
    StrokeCap? strokeCap,
  }) {
    return DesignElement(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
      textAlign: textAlign ?? this.textAlign,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      fit: fit ?? this.fit,
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shapeType: shapeType ?? this.shapeType,
      lineStart: lineStart ?? this.lineStart,
      lineEnd: lineEnd ?? this.lineEnd,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'position': {'dx': position.dx, 'dy': position.dy},
      'size': {'width': size.width, 'height': size.height},
      'rotation': rotation,
      'zIndex': zIndex,
      'isLocked': isLocked,
      'isVisible': isVisible,
      'text': text,
      'textStyle': textStyle != null ? {
        'color': textStyle!.color?.toARGB32(),
        'fontSize': textStyle!.fontSize,
        'fontWeight': textStyle!.fontWeight?.index,
        'fontFamily': textStyle!.fontFamily,
        'fontStyle': textStyle!.fontStyle?.index,
        'decoration': textStyle!.decoration?.toString(),
        'decorationColor': textStyle!.decorationColor?.toARGB32(),
        'letterSpacing': textStyle!.letterSpacing,
        'height': textStyle!.height,
      } : null,
      'textAlign': textAlign?.name,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'fit': fit?.name,
      'fillColor': fillColor?.toARGB32(),
      'borderColor': borderColor?.toARGB32(),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius != null ? {
        'topLeft': borderRadius!.topLeft.x,
        'topRight': borderRadius!.topRight.x,
        'bottomLeft': borderRadius!.bottomLeft.x,
        'bottomRight': borderRadius!.bottomRight.x,
      } : null,
      'shapeType': shapeType?.name,
      'lineStart': lineStart != null ? {'dx': lineStart!.dx, 'dy': lineStart!.dy} : null,
      'lineEnd': lineEnd != null ? {'dx': lineEnd!.dx, 'dy': lineEnd!.dy} : null,
      'strokeWidth': strokeWidth,
      'strokeCap': strokeCap?.name,
    };
  }

  factory DesignElement.fromJson(Map<String, dynamic> json) {
    return DesignElement(
      id: json['id'],
      type: ElementType.values.firstWhere((e) => e.name == json['type']),
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: Size(json['size']['width'], json['size']['height']),
      rotation: json['rotation']?.toDouble() ?? 0.0,
      zIndex: json['zIndex'] ?? 0,
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      text: json['text'],
      textStyle: json['textStyle'] != null ? TextStyle(
        color: json['textStyle']['color'] != null ? Color(json['textStyle']['color']) : null,
        fontSize: json['textStyle']['fontSize']?.toDouble(),
        fontWeight: json['textStyle']['fontWeight'] != null ? FontWeight.values[json['textStyle']['fontWeight']] : null,
        fontFamily: json['textStyle']['fontFamily'],
        fontStyle: json['textStyle']['fontStyle'] != null ? FontStyle.values[json['textStyle']['fontStyle']] : null,
        decoration: json['textStyle']['decoration'] != null ? _parseTextDecoration(json['textStyle']['decoration']) : null,
        decorationColor: json['textStyle']['decorationColor'] != null ? Color(json['textStyle']['decorationColor']) : null,
        letterSpacing: json['textStyle']['letterSpacing']?.toDouble(),
        height: json['textStyle']['height']?.toDouble(),
      ) : null,
      textAlign: json['textAlign'] != null ? TextAlign.values.firstWhere((e) => e.name == json['textAlign']) : null,
      imagePath: json['imagePath'],
      imageUrl: json['imageUrl'],
      fit: json['fit'] != null ? BoxFit.values.firstWhere((e) => e.name == json['fit']) : null,
      fillColor: json['fillColor'] != null ? Color(json['fillColor']) : null,
      borderColor: json['borderColor'] != null ? Color(json['borderColor']) : null,
      borderWidth: json['borderWidth']?.toDouble(),
      borderRadius: json['borderRadius'] != null ? BorderRadius.only(
        topLeft: Radius.circular(json['borderRadius']['topLeft']),
        topRight: Radius.circular(json['borderRadius']['topRight']),
        bottomLeft: Radius.circular(json['borderRadius']['bottomLeft']),
        bottomRight: Radius.circular(json['borderRadius']['bottomRight']),
      ) : null,
      shapeType: json['shapeType'] != null ? ShapeType.values.firstWhere((e) => e.name == json['shapeType']) : null,
      lineStart: json['lineStart'] != null ? Offset(json['lineStart']['dx'], json['lineStart']['dy']) : null,
      lineEnd: json['lineEnd'] != null ? Offset(json['lineEnd']['dx'], json['lineEnd']['dy']) : null,
      strokeWidth: json['strokeWidth']?.toDouble(),
      strokeCap: json['strokeCap'] != null ? StrokeCap.values.firstWhere((e) => e.name == json['strokeCap']) : null,
    );
  }
}

enum ShapeType { rectangle, circle, roundedRectangle, triangle, star }