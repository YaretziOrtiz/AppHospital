import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  final bool obscureText;
  final bool enabled;

  final TextInputType keyboardType;

  final String? Function(String?)? validator;

  final Widget? suffixIcon;

  const CustomTextField({
    super.key,

    required this.controller,

    required this.label,

    required this.hint,

    required this.icon,

    this.obscureText = false,

    this.enabled = true,

    this.keyboardType = TextInputType.text,

    this.validator,

    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      obscureText: obscureText,

      enabled: enabled,

      keyboardType: keyboardType,

      validator: validator,

      style: const TextStyle(color: AppColors.textPrimary),

      decoration: InputDecoration(
        labelText: label,

        hintText: hint,

        prefixIcon: Icon(icon, color: AppColors.primary),

        suffixIcon: suffixIcon,

        filled: true,

        fillColor: Colors.white,

        labelStyle: const TextStyle(color: AppColors.textSecondary),

        hintStyle: const TextStyle(color: AppColors.textLight),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: AppColors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
