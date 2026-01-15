import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  const OTPScreen({super.key, required this.phone});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    // API verification temporary removed as per Swagger update
    if (_otpController.text.length >= 4) { // Allow 4-6 chars
       // Simulate delay
       // await Future.delayed(const Duration(seconds: 1));
       
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực giả định thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.main);
       }
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mã OTP không hợp lệ'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Nhập mã OTP đã được gửi đến số điện thoại của bạn',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _otpController,
              label: 'Mã OTP',
              hint: '123456',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              validator: (v) => (v?.length ?? 0) != 6 ? 'Mã OTP gồm 6 chữ số' : null,
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return CustomButton(
                  text: 'Xác nhận',
                  isLoading: auth.isLoading,
                  onPressed: _handleVerify,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
