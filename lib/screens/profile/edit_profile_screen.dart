import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const EditProfileScreen({super.key, required this.currentData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoPaternoController;
  late TextEditingController _apellidoMaternoController; // ◄ Agregado
  late TextEditingController _direccionController;
  bool _isLoading = false;

  // --- PALETA DE COLORES CLEAN ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.currentData["nombre"] ?? "",
    );
    _apellidoPaternoController = TextEditingController(
      text: widget.currentData["apellidoPaterno"] ?? "",
    );
    _apellidoMaternoController = TextEditingController(
      text: widget.currentData["apellidoMaterno"] ?? "", // ◄ Inicializado
    );
    _direccionController = TextEditingController(
      text: widget.currentData["direccion"] ?? "",
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose(); // ◄ Liberado
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc("JEsqUxkKPaushkSUn3I7")
          .update({
            "nombre": _nombreController.text.trim(),
            "apellidoPaterno": _apellidoPaternoController.text.trim(),
            "apellidoMaterno": _apellidoMaternoController.text
                .trim(), // ◄ Guardado en Firebase
            "direccion": _direccionController.text.trim(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Perfil actualizado correctamente"),
            backgroundColor: Colors.green.shade600,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "EDITAR PERFIL",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Información básica",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Campo: Nombre
              _buildCleanTextField(
                controller: _nombreController,
                label: "Nombre",
                icon: Icons.person_outline,
                validator: (value) => value == null || value.trim().isEmpty
                    ? "El nombre es obligatorio"
                    : null,
              ),
              const SizedBox(height: 18),

              // Campo: Apellido Paterno
              _buildCleanTextField(
                controller: _apellidoPaternoController,
                label: "Apellido Paterno",
                icon: Icons.badge_outlined,
                validator: (value) => value == null || value.trim().isEmpty
                    ? "El apellido paterno es obligatorio"
                    : null,
              ),
              const SizedBox(height: 18),

              // Campo: Apellido Materno ◄ ¡NUEVO!
              _buildCleanTextField(
                controller: _apellidoMaternoController,
                label: "Apellido Materno",
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 18),

              // Campo: Dirección
              _buildCleanTextField(
                controller: _direccionController,
                label: "Dirección de residencia",
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 40),

              // Botón de Acción Principal Estilizado
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: medicalBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _guardarCambios,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Guardar Cambios",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET GENERADOR DE INPUTS FLUIDOS Y MINIMALISTAS ---
  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: textSecondary.withOpacity(0.8),
          fontSize: 13,
        ),
        floatingLabelStyle: TextStyle(
          color: medicalBlue,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        filled: true,
        fillColor: surfaceColor,
        prefixIcon: Icon(icon, color: textSecondary.withOpacity(0.7), size: 20),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: medicalBlue.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
