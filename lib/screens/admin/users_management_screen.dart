import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  // Cambiar el rol en Firestore
  Future<void> _changeUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'rol': newRole,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rol actualizado a "$newRole" exitosamente.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar rol: $e')),
        );
      }
    }
  }

  void _showRoleDialog(String userId, String currentRole, String userName) {
    String selectedRole = currentRole.toLowerCase();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Asignar Rol a $userName'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Paciente'),
                    value: 'paciente',
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setDialogState(() => selectedRole = value!);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Doctor'),
                    value: 'doctor',
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setDialogState(() => selectedRole = value!);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Administrador'),
                    value: 'administrador',
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setDialogState(() => selectedRole = value!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _changeUserRole(userId, selectedRole);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5BAA),
                  ),
                  child: const Text('Guardar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de usuarios'),
        backgroundColor: const Color(0xFF4A97E8),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final data = userDoc.data();
              final String name =
                  "${data['nombre'] ?? ''} ${data['apellidoPaterno'] ?? ''}"
                      .trim();
              final String email =
                  data['correo'] ?? data['email'] ?? 'Sin correo';
              final String role = data['rol'] ?? 'paciente';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1A5BAA),
                    child: Text(
                      role.isNotEmpty ? role[0].toUpperCase() : 'P',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(name.isEmpty ? 'Sin Nombre' : name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$email\nRol actual: ${role.toUpperCase()}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF1A5BAA)),
                    onPressed: () => _showRoleDialog(userDoc.id, role, name),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
