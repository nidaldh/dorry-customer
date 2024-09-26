import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? togglePasswordVisibility;
  final FormFieldValidator<String>? validator;
  final String? errorText;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.togglePasswordVisibility,
    this.validator, // Optional validator parameter
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator, // Add the validator here
      decoration: InputDecoration(
        errorText: errorText,
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: togglePasswordVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: isPassword ? !isPasswordVisible : false,
    );
  }
}
