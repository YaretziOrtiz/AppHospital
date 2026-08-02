import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;

  final double? height;

  final Color? color;

  const CustomCard({
    super.key,

    required this.child,

    this.padding,

    this.onTap,

    this.height,

    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Card(
        color: color ?? Colors.white,

        elevation: 3,

        shadowColor: AppColors.shadow,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        child: Container(
          height: height,

          padding: padding ?? const EdgeInsets.all(16),

          child: child,
        ),
      ),
    );
  }
}

// Tarjeta especializada para información médica
class MedicalInfoCard extends StatelessWidget {
  final String title;

  final String subtitle;

  final IconData icon;

  final Color iconColor;

  final VoidCallback? onTap;

  const MedicalInfoCard({
    super.key,

    required this.title,

    required this.subtitle,

    required this.icon,

    this.iconColor = AppColors.primary,

    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: iconColor, size: 28),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 16,

                    fontWeight: FontWeight.bold,

                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,

                  style: const TextStyle(
                    fontSize: 14,

                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
