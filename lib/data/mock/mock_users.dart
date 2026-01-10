import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

/// Mock users for testing
class MockUsers {
  MockUsers._();

  static final List<UserModel> customers = [
    UserModel(
      id: 'customer_1',
      name: 'Nguyễn Văn An',
      email: 'an.nguyen@email.com',
      phone: '0901234567',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      role: UserRole.customer,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      id: 'customer_2',
      name: 'Trần Thị Bình',
      email: 'binh.tran@email.com',
      phone: '0912345678',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      role: UserRole.customer,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    UserModel(
      id: 'customer_3',
      name: 'Lê Hoàng Cường',
      email: 'cuong.le@email.com',
      phone: '0923456789',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      role: UserRole.customer,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  static final List<UserModel> barbers = [
    UserModel(
      id: 'barber_1',
      name: 'Phạm Minh Đức',
      email: 'duc.pham@barbershop.com',
      phone: '0934567890',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      role: UserRole.barber,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    UserModel(
      id: 'barber_2',
      name: 'Hoàng Văn Em',
      email: 'em.hoang@barbershop.com',
      phone: '0945678901',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      role: UserRole.barber,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    UserModel(
      id: 'barber_3',
      name: 'Ngô Thanh Phong',
      email: 'phong.ngo@barbershop.com',
      phone: '0956789012',
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
      role: UserRole.barber,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
  ];

  static final List<UserModel> admins = [
    UserModel(
      id: 'admin_1',
      name: 'Admin System',
      email: 'admin@barbershop.com',
      phone: '0967890123',
      avatarUrl: 'https://i.pravatar.cc/150?img=60',
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
    ),
  ];

  static List<UserModel> get all => [...customers, ...barbers, ...admins];

  static UserModel? getById(String id) {
    try {
      return all.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}
