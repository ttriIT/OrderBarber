/// Review model for rating and feedback
class ReviewModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerAvatar;
  final String targetId; // barberId or serviceId
  final String targetType; // 'barber' or 'service'
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> images;

  const ReviewModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAvatar,
    required this.targetId,
    required this.targetType,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images = const [],
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerAvatar: json['customerAvatar'] ?? '',
      targetId: json['targetId'] ?? '',
      targetType: json['targetType'] ?? 'barber',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerAvatar': customerAvatar,
      'targetId': targetId,
      'targetType': targetType,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerAvatar,
    String? targetId,
    String? targetType,
    double? rating,
    String? comment,
    DateTime? createdAt,
    List<String>? images,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
    );
  }
}
