/// Promotion model for discount offers
class PromotionModel {
  final String id;
  final String title;
  final String description;
  final String code;
  final double discountPercentage;
  final String imageUrl;
  final DateTime expiryDate;
  final bool isActive;

  const PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.discountPercentage,
    required this.imageUrl,
    required this.expiryDate,
    this.isActive = true,
  });

  /// Create from JSON
  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      code: json['code'] ?? '',
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      expiryDate: DateTime.tryParse(json['expiryDate'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      isActive: json['isActive'] ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'code': code,
      'discountPercentage': discountPercentage,
      'imageUrl': imageUrl,
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Copy with new values
  PromotionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? code,
    double? discountPercentage,
    String? imageUrl,
    DateTime? expiryDate,
    bool? isActive,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      code: code ?? this.code,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
