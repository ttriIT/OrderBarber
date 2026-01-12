import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await context.read<AuthProvider>().register(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
          );

      if (success && mounted) {
        Navigator.pushReplacementNamed(
          context, 
          AppRoutes.otp,
          arguments: {'phone': _phoneController.text},
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Điền thông tin bên dưới để bắt đầu',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              CustomTextField(
                controller: _nameController,
                label: 'Họ và tên',
                hint: 'Nhập họ và tên',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) => 
                  value?.isEmpty ?? true ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Nhập địa chỉ email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (value) => 
                  value?.isEmpty ?? true ? 'Vui lòng nhập email' : null,
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                hint: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                validator: (value) => 
                  value?.isEmpty ?? true ? 'Vui lòng nhập số điện thoại' : null,
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _passwordController,
                label: 'Mật khẩu',
                hint: 'Nhập mật khẩu (ít nhất 6 ký tự)',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (value) => 
                  (value?.length ?? 0) < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
              ),
              const SizedBox(height: 32),
              
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return CustomButton(
                    text: 'Đăng ký',
                    isLoading: auth.isLoading,
                    onPressed: _handleRegister,
                  );
                },
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản?'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
