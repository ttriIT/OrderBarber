/// Service model representing a barbershop service
class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String imageUrl;
  final String shopId;
  final bool isActive;
  final String category;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.imageUrl,
    required this.shopId,
    this.isActive = true,
    this.category = 'general',
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 30,
      imageUrl: json['imageUrl'] ?? '',
      shopId: json['shopId'] ?? '',
      isActive: json['isActive'] ?? true,
      category: json['category'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
      'shopId': shopId,
      'isActive': isActive,
      'category': category,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? imageUrl,
    String? shopId,
    bool? isActive,
    String? category,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      shopId: shopId ?? this.shopId,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
    );
  }

  /// Get formatted price
  String get formattedPrice => '${price.toStringAsFixed(0)}đ';

  /// Get formatted duration
  String get formattedDuration => '$durationMinutes phút';
}
