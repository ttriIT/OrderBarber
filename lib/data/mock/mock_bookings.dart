import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../../core/constants/app_constants.dart';
import 'mock_shops.dart';
import 'mock_barbers.dart';
import 'mock_services.dart';

/// Mock bookings for testing
class MockBookings {
  MockBookings._();

  static List<BookingModel> getBookings() {
    final now = DateTime.now();
    return [
      BookingModel(
        id: 'booking_1',
        customerId: 'customer_1',
        customerName: 'Nguyễn Văn An',
        shopId: 'shop_1',
        shop: MockShops.getById('shop_1'),
        barberId: 'barber_1',
        barber: MockBarbers.getById('barber_1'),
        services: [MockServices.getById('service_1')!, MockServices.getById('service_3')!],
        bookingDate: now.add(const Duration(days: 1)),
        timeSlot: '10:00',
        status: BookingStatus.confirmed,
        totalPrice: 150000,
        note: 'Cắt kiểu Undercut',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      BookingModel(
        id: 'booking_2',
        customerId: 'customer_1',
        customerName: 'Nguyễn Văn An',
        shopId: 'shop_2',
        shop: MockShops.getById('shop_2'),
        barberId: 'barber_4',
        barber: MockBarbers.getById('barber_4'),
        services: [MockServices.getById('service_5')!],
        bookingDate: now.add(const Duration(days: 3)),
        timeSlot: '14:30',
        status: BookingStatus.pending,
        totalPrice: 350000,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      BookingModel(
        id: 'booking_3',
        customerId: 'customer_2',
        customerName: 'Trần Thị Bình',
        shopId: 'shop_1',
        shop: MockShops.getById('shop_1'),
        barberId: 'barber_2',
        barber: MockBarbers.getById('barber_2'),
        services: [MockServices.getById('service_2')!],
        bookingDate: now.subtract(const Duration(days: 2)),
        timeSlot: '09:00',
        status: BookingStatus.completed,
        totalPrice: 120000,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      BookingModel(
        id: 'booking_4',
        customerId: 'customer_1',
        customerName: 'Nguyễn Văn An',
        shopId: 'shop_3',
        shop: MockShops.getById('shop_3'),
        barberId: 'barber_6',
        barber: MockBarbers.getById('barber_6'),
        services: [MockServices.getById('service_6')!],
        bookingDate: now.subtract(const Duration(days: 5)),
        timeSlot: '16:00',
        status: BookingStatus.completed,
        totalPrice: 300000,
        note: 'Combo VIP đặc biệt',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      BookingModel(
        id: 'booking_5',
        customerId: 'customer_3',
        customerName: 'Lê Hoàng Cường',
        shopId: 'shop_1',
        shop: MockShops.getById('shop_1'),
        barberId: 'barber_1',
        barber: MockBarbers.getById('barber_1'),
        services: [MockServices.getById('service_1')!],
        bookingDate: now.subtract(const Duration(days: 1)),
        timeSlot: '11:00',
        status: BookingStatus.cancelled,
        totalPrice: 80000,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  static List<BookingModel> getByCustomerId(String customerId) {
    return getBookings().where((b) => b.customerId == customerId).toList();
  }

  static List<BookingModel> getByBarberId(String barberId) {
    return getBookings().where((b) => b.barberId == barberId).toList();
  }

  static List<BookingModel> getByStatus(BookingStatus status) {
    return getBookings().where((b) => b.status == status).toList();
  }

  static List<BookingModel> getTodayBookings(String barberId) {
    final today = DateTime.now();
    return getBookings().where((b) {
      return b.barberId == barberId &&
          b.bookingDate.year == today.year &&
          b.bookingDate.month == today.month &&
          b.bookingDate.day == today.day;
    }).toList();
  }
}
