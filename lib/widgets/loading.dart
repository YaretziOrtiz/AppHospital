import 'package:flutter/material.dart';

import '../utils/colors.dart';

class Loading extends StatelessWidget {
  final double size;

  final Color? color;

  const Loading({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,

        width: size,

        child: CircularProgressIndicator(
          strokeWidth: 3,

          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

// Pantalla completa de carga
class FullScreenLoading extends StatelessWidget {
  final String message;

  const FullScreenLoading({super.key, this.message = "Cargando..."});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Loading(size: 50),

            const SizedBox(height: 20),

            Text(
              message,

              style: const TextStyle(
                fontSize: 16,

                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón de carga
class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,

      width: double.infinity,

      decoration: BoxDecoration(
        color: AppColors.primary,

        borderRadius: BorderRadius.circular(12),
      ),

      child: const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
    );
  }
}
