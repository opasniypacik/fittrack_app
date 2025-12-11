import 'package:flutter/material.dart';
import 'package:kpp_lab/core/constants/app_strings.dart';
import 'package:kpp_lab/core/services/auth_repository.dart';
import 'package:kpp_lab/features/home/screens/home_screen.dart';
import 'package:kpp_lab/shared_widgets/custom_auth_button.dart';
import 'package:kpp_lab/shared_widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authRepository.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Створити акаунт'), elevation: 0, backgroundColor: Colors.transparent),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomTextField(labelText: AppStrings.nameLabel),
                  CustomTextField(
                    controller: _emailController,
                    labelText: AppStrings.emailLabel,
                    validator: (val) => val != null && !val.contains('@') ? AppStrings.invalidEmailError : null,
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: AppStrings.passwordLabel,
                    isPassword: true,
                    validator: (val) => val != null && val.length < 6 ? AppStrings.shortPasswordError : null,
                  ),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: AppStrings.confirmPasswordLabel,
                    isPassword: true,
                    validator: (val) => val != _passwordController.text ? AppStrings.passwordMismatchError : null,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomAuthButton(text: AppStrings.registerButton, onPressed: _handleRegister),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}