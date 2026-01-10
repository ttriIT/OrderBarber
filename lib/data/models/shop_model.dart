/// Shop model representing a barbershop
class ShopModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final List<String> images;
  final double latitude;
  final double longitude;

  const ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    this.images = const [],
    this.latitude = 0,
    this.longitude = 0,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      openTime: json['openTime'] ?? '08:00',
      closeTime: json['closeTime'] ?? '21:00',
      isOpen: json['isOpen'] ?? true,
      images: List<String>.from(json['images'] ?? []),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  ShopModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? openTime,
    String? closeTime,
    bool? isOpen,
    List<String>? images,
    double? latitude,
    double? longitude,
  }) {
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
      images: images ?? this.images,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
