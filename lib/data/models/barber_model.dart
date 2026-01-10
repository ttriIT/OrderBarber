/// Barber model representing a barber/stylist
class BarberModel {
  final String id;
  final String name;
  final String phone;
  final String avatarUrl;
  final String shopId;
  final String specialization;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final int yearsOfExperience;
  final List<String> skills;

  const BarberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.shopId,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    this.isAvailable = true,
    this.yearsOfExperience = 0,
    this.skills = const [],
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      shopId: json['shopId'] ?? '',
      specialization: json['specialization'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'shopId': shopId,
      'specialization': specialization,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'yearsOfExperience': yearsOfExperience,
      'skills': skills,
    };
  }

  BarberModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatarUrl,
    String? shopId,
    String? specialization,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    int? yearsOfExperience,
    List<String>? skills,
  }) {
    return BarberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      shopId: shopId ?? this.shopId,
      specialization: specialization ?? this.specialization,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      skills: skills ?? this.skills,
    );
  }
}
