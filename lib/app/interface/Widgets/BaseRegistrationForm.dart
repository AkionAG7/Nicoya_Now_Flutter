import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

/// Widget base para formularios de registro que pueden manejar tanto
/// nuevos usuarios como usuarios existentes agregando roles
abstract class BaseRegistrationForm extends StatefulWidget {
  final String roleSlug;
  final String roleTitle;
  final bool isAddingRole; // true si es usuario existente agregando rol

  const BaseRegistrationForm({
    Key? key,
    required this.roleSlug,
    required this.roleTitle,
    this.isAddingRole = false,
  }) : super(key: key);
}

abstract class BaseRegistrationFormState<T extends BaseRegistrationForm>
    extends State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para el estado
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAddingRole => widget.isAddingRole;
  String get roleSlug => widget.roleSlug;
  String get roleTitle => widget.roleTitle;

  // Métodos que deben implementar las clases hijas
  bool validateForm();
  Future<void> performRegistration();
  Future<void> performRoleAddition();

  /// Método principal de registro que maneja ambos flujos
  Future<void> handleRegistration() async {
    if (!validateForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = context.read<AuthController>();

      if (isAddingRole) {
        // Si es agregar rol, verificar que esté autenticado
        if (authController.user == null) {
          throw Exception('No hay sesión activa para agregar el rol');
        }

        // Verificar si ya tiene este rol
        if (await authController.hasRole(roleSlug)) {
          throw Exception('Ya tienes el rol de $roleTitle');
        }

        await performRoleAddition();
        await authController.addRole(roleSlug);
      } else {
        // Registro normal de nuevo usuario
        await performRegistration();
      }

      // Navegación después del éxito
      if (mounted) {
        onRegistrationSuccess();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Método llamado después de un registro exitoso
  void onRegistrationSuccess() {
    // Implementación por defecto - las clases hijas pueden sobrescribir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAddingRole
            ? '¡Rol de $roleTitle agregado con éxito!'
            : '¡Cuenta creada con éxito!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home_food', // Ruta por defecto
      (route) => false,
    );
  }

  /// Widget para mostrar errores
  Widget buildErrorWidget() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para botón de envío principal
  Widget buildSubmitButton({
    required String label,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : (onPressed ?? handleRegistration),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffd72a23),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }

  /// Widget para campos de texto comunes
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    String? Function(String?)? validator,
    Widget? suffix,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      enabled: enabled,
      buildCounter: maxLength != null
          ? (_, {required currentLength, maxLength, required isFocused}) => null
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: suffix,
        filled: !enabled,
        fillColor: !enabled ? Colors.grey.shade100 : null,
      ),
      validator: validator ??
          (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
    );
  }
}

/// Mixin para manejar campos de formulario comunes
mixin CommonFormFields {
  // Controladores comunes
  final firstNameController = TextEditingController();
  final lastName1Controller = TextEditingController();
  final lastName2Controller = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Estado para contraseñas
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  void disposeCommonControllers() {
    firstNameController.dispose();
    lastName1Controller.dispose();
    lastName2Controller.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requerido';
    if (!value.contains('@')) return 'Email inválido';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Contraseña requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Teléfono requerido';
    if (value.length != 8) return 'Debe tener 8 dígitos';
    return null;
  }
}
