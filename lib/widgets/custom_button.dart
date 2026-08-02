import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      height: 52,

      child: ElevatedButton(
        onPressed: loading ? null : onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,

          foregroundColor: textColor ?? Colors.white,

          disabledBackgroundColor: AppColors.primaryLight,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          elevation: 2,
        ),

        child: loading
            ? const SizedBox(
                height: 24,

                width: 24,

                child: CircularProgressIndicator(
                  strokeWidth: 2,

                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),

                    const SizedBox(width: 8),
                  ],

                  Text(
                    text,

                    style: const TextStyle(
                      fontSize: 16,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
