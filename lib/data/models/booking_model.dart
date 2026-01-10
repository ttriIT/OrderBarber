import '../../core/constants/app_constants.dart';
import 'service_model.dart';
import 'barber_model.dart';
import 'shop_model.dart';

/// Booking model representing a booking appointment
class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String shopId;
  final ShopModel? shop;
  final String barberId;
  final BarberModel? barber;
  final List<ServiceModel> services;
  final DateTime bookingDate;
  final String timeSlot;
  final BookingStatus status;
  final double totalPrice;
  final String? note;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.shopId,
    this.shop,
    required this.barberId,
    this.barber,
    required this.services,
    required this.bookingDate,
    required this.timeSlot,
    required this.status,
    required this.totalPrice,
    this.note,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      shopId: json['shopId'] ?? '',
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
      barberId: json['barberId'] ?? '',
      barber: json['barber'] != null ? BarberModel.fromJson(json['barber']) : null,
      services: (json['services'] as List<dynamic>?)
              ?.map((s) => ServiceModel.fromJson(s))
              .toList() ?? [],
      bookingDate: DateTime.tryParse(json['bookingDate'] ?? '') ?? DateTime.now(),
      timeSlot: json['timeSlot'] ?? '',
      status: BookingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      note: json['note'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'shopId': shopId,
      'shop': shop?.toJson(),
      'barberId': barberId,
      'barber': barber?.toJson(),
      'services': services.map((s) => s.toJson()).toList(),
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status.name,
      'totalPrice': totalPrice,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? shopId,
    ShopModel? shop,
    String? barberId,
    BarberModel? barber,
    List<ServiceModel>? services,
    DateTime? bookingDate,
    String? timeSlot,
    BookingStatus? status,
    double? totalPrice,
    String? note,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      shopId: shopId ?? this.shopId,
      shop: shop ?? this.shop,
      barberId: barberId ?? this.barberId,
      barber: barber ?? this.barber,
      services: services ?? this.services,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.confirmed:
        return 'Đã xác nhận';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
    }
  }

  /// Get total duration in minutes
  int get totalDuration {
    return services.fold(0, (sum, s) => sum + s.durationMinutes);
  }
}
