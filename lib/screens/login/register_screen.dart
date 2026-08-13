import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ============================================================
  // CONTROLADORES
  // ============================================================

  final nombreController = TextEditingController();
  final apellidoPaternoController = TextEditingController();
  final apellidoMaternoController = TextEditingController();

  final telefonoController = TextEditingController();
  final emailController = TextEditingController();
  final direccionController = TextEditingController();
  final alergiasController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  DateTime? fechaNacimiento;

  String? sexoSeleccionado;
  String? tipoSangreSeleccionado;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  // ============================================================
  // COLORES
  // ============================================================

  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nombreController.dispose();
    apellidoPaternoController.dispose();
    apellidoMaternoController.dispose();

    telefonoController.dispose();
    emailController.dispose();
    direccionController.dispose();
    alergiasController.dispose();

    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // CALCULAR EDAD
  // ============================================================

  int _calcularEdad(DateTime fecha) {
    final hoy = DateTime.now();

    int edad = hoy.year - fecha.year;

    if (hoy.month < fecha.month ||
        (hoy.month == fecha.month && hoy.day < fecha.day)) {
      edad--;
    }

    return edad;
  }

  // ============================================================
  // SELECCIONAR FECHA DE NACIMIENTO
  // ============================================================

  Future<void> _seleccionarFechaNacimiento() async {
    final DateTime hoy = DateTime.now();

    // Ajuste seguro para evitar desbordamiento en años bisiestos (29 feb)
    DateTime initialDate = DateTime(hoy.year - 18, hoy.month, hoy.day);
    if (initialDate.isAfter(hoy)) {
      initialDate = hoy;
    }

    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: hoy,
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      locale: const Locale('es', 'MX'),
    );

    if (fecha != null) {
      setState(() {
        fechaNacimiento = fecha;
      });
    }
  }

  // ============================================================
  // FORMATEAR FECHA
  // ============================================================

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  // ============================================================
  // REGISTRAR USUARIO
  // ============================================================

  Future<void> _registerUser() async {
    final nombre = nombreController.text.trim();
    final apellidoPaterno = apellidoPaternoController.text.trim();
    final apellidoMaterno = apellidoMaternoController.text.trim();

    final telefono = telefonoController.text.trim();
    final email = emailController.text.trim();
    final direccion = direccionController.text.trim();
    final alergias = alergiasController.text.trim();

    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // ==========================================================
    // VALIDACIONES
    // ==========================================================

    if (nombre.isEmpty ||
        apellidoPaterno.isEmpty ||
        apellidoMaterno.isEmpty ||
        telefono.isEmpty ||
        email.isEmpty ||
        direccion.isEmpty ||
        alergias.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar(
        'Por favor completa todos los campos',
        Colors.orange,
      );
      return;
    }

    if (fechaNacimiento == null) {
      _showSnackBar(
        'Selecciona tu fecha de nacimiento',
        Colors.orange,
      );
      return;
    }

    if (sexoSeleccionado == null) {
      _showSnackBar(
        'Selecciona tu sexo',
        Colors.orange,
      );
      return;
    }

    if (tipoSangreSeleccionado == null) {
      _showSnackBar(
        'Selecciona tu tipo de sangre',
        Colors.orange,
      );
      return;
    }

    if (password.length < 6) {
      _showSnackBar(
        'La contraseña debe tener al menos 6 caracteres',
        Colors.orange,
      );
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar(
        'Las contraseñas no coinciden',
        Colors.redAccent,
      );
      return;
    }

    // ==========================================================
    // CALCULAR EDAD
    // ==========================================================

    final edad = _calcularEdad(fechaNacimiento!);

    if (edad < 0) {
      _showSnackBar(
        'La fecha de nacimiento no es válida',
        Colors.redAccent,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // 1. CREAR USUARIO EN FIREBASE AUTHENTICATION
      // ========================================================

      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception(
          'No se pudo crear el usuario',
        );
      }

      final String uid = user.uid;

      // ========================================================
      // 2. GUARDAR NOMBRE EN AUTHENTICATION
      // ========================================================

      await user.updateDisplayName(
        '$nombre $apellidoPaterno $apellidoMaterno',
      );

      // ========================================================
      // 3. CREAR DOCUMENTO EN FIRESTORE
      // users/{uid}
      // ========================================================

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nombre': nombre,
        'apellidoPaterno': apellidoPaterno,
        'apellidoMaterno': apellidoMaterno,
        'fechaNacimiento': Timestamp.fromDate(fechaNacimiento!),
        'edad': edad,
        'sexo': sexoSeleccionado,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'tipoSangre': tipoSangreSeleccionado,
        'alergias': alergias,
        'fotoPerfil': '',
        'rol': 'paciente',
        'activo': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ========================================================
      // 4. REGISTRO CORRECTO
      // ========================================================

      if (!mounted) return;

      _showSnackBar(
        'Cuenta creada correctamente',
        Colors.green,
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje;

      switch (e.code) {
        case 'weak-password':
          mensaje = 'La contraseña debe tener al menos 6 caracteres';
          break;

        case 'email-already-in-use':
          mensaje = 'Este correo electrónico ya está registrado';
          break;

        case 'invalid-email':
          mensaje = 'El correo electrónico no es válido';
          break;

        case 'operation-not-allowed':
          mensaje = 'El registro con correo no está habilitado en Firebase';
          break;

        case 'network-request-failed':
          mensaje = 'No hay conexión a Internet';
          break;

        default:
          mensaje = 'No se pudo crear la cuenta: ${e.message}';
      }

      if (mounted) {
        _showSnackBar(
          mensaje,
          Colors.redAccent,
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        _showSnackBar(
          'Error de Firestore: ${e.message}',
          Colors.redAccent,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Ocurrió un error inesperado',
          Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
    String text,
    Color color,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'CREAR CUENTA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // ICONO
              // ==================================================

              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: medicalBlue.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_outlined,
                    size: 32,
                    color: medicalBlue,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // TITULO
              // ==================================================

              Text(
                'Registro de Usuario',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Completa tus datos para crear tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // NOMBRE
              // ==================================================

              _buildTextField(
                controller: nombreController,
                label: 'Nombre',
                icon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // APELLIDO PATERNO
              // ==================================================

              _buildTextField(
                controller: apellidoPaternoController,
                label: 'Apellido paterno',
                icon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // APELLIDO MATERNO
              // ==================================================

              _buildTextField(
                controller: apellidoMaternoController,
                label: 'Apellido materno',
                icon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // FECHA DE NACIMIENTO
              // ==================================================

              _buildDateField(),

              const SizedBox(height: 12),

              // ==================================================
              // SEXO
              // ==================================================

              _buildDropdown(
                value: sexoSeleccionado,
                label: 'Sexo',
                icon: Icons.wc_outlined,
                items: const [
                  'Femenino',
                  'Masculino',
                  'Otro',
                  'Prefiero no decirlo',
                ],
                onChanged: (value) {
                  setState(() {
                    sexoSeleccionado = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // ==================================================
              // TIPO DE SANGRE
              // ==================================================

              _buildDropdown(
                value: tipoSangreSeleccionado,
                label: 'Tipo de sangre',
                icon: Icons.bloodtype_outlined,
                items: const [
                  'A+',
                  'A-',
                  'B+',
                  'B-',
                  'AB+',
                  'AB-',
                  'O+',
                  'O-',
                ],
                onChanged: (value) {
                  setState(() {
                    tipoSangreSeleccionado = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // ==================================================
              // TELEFONO
              // ==================================================

              _buildTextField(
                controller: telefonoController,
                label: 'Teléfono',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // CORREO
              // ==================================================

              _buildTextField(
                controller: emailController,
                label: 'Correo electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // DIRECCION
              // ==================================================

              _buildTextField(
                controller: direccionController,
                label: 'Dirección',
                icon: Icons.location_on_outlined,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // ALERGIAS
              // ==================================================

              _buildTextField(
                controller: alergiasController,
                label: 'Alergias',
                hintText: 'Escribe "Ninguna" si no tienes',
                icon: Icons.warning_amber_outlined,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // CONTRASEÑA
              // ==================================================

              _buildTextField(
                controller: passwordController,
                label: 'Contraseña',
                icon: Icons.lock_outline,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: textSecondary.withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // CONFIRMAR CONTRASEÑA
              // ==================================================

              _buildTextField(
                controller: confirmPasswordController,
                label: 'Confirmar contraseña',
                icon: Icons.lock_reset_outlined,
                obscureText: obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: textSecondary.withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // BOTON
              // ==================================================

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: medicalBlue,
                    disabledBackgroundColor: medicalBlue.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // LOGIN
              // ==================================================

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                child: Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: medicalBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CAMPO DE TEXTO
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: obscureText ? 1 : maxLines,
      style: TextStyle(
        fontSize: 15,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          color: textSecondary.withOpacity(0.8),
          fontSize: 13,
        ),
        floatingLabelStyle: TextStyle(
          color: medicalBlue,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: surfaceColor,
        prefixIcon: Icon(
          icon,
          color: textSecondary.withOpacity(0.7),
          size: 20,
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: medicalBlue.withOpacity(0.4),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CAMPO FECHA
  // ============================================================

  Widget _buildDateField() {
    return InkWell(
      onTap: _seleccionarFechaNacimiento,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de nacimiento',
          labelStyle: TextStyle(
            color: textSecondary.withOpacity(0.8),
            fontSize: 13,
          ),
          floatingLabelStyle: TextStyle(
            color: medicalBlue,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: surfaceColor,
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
            color: textSecondary.withOpacity(0.7),
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade100,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 16,
          ),
        ),
        child: Text(
          fechaNacimiento == null
              ? 'Selecciona tu fecha'
              : _formatearFecha(
                  fechaNacimiento!,
                ),
          style: TextStyle(
            fontSize: 15,
            color: fechaNacimiento == null ? textSecondary : textPrimary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: textSecondary.withOpacity(0.8),
          fontSize: 13,
        ),
        floatingLabelStyle: TextStyle(
          color: medicalBlue,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: surfaceColor,
        prefixIcon: Icon(
          icon,
          color: textSecondary.withOpacity(0.7),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: medicalBlue.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 16,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
