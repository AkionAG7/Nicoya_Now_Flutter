import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Widgets/BaseRegistrationForm.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliverForm1 extends BaseRegistrationForm {
  const DeliverForm1({Key? key, bool isAddingRole = false})
      : super(
          key: key,
          roleSlug: 'driver',
          roleTitle: 'Repartidor',
          isAddingRole: isAddingRole,
        );

  @override
  State<DeliverForm1> createState() => _DeliverForm1State();
}

class _DeliverForm1State extends BaseRegistrationFormState<DeliverForm1>
    with CommonFormFields {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _licenseController = TextEditingController();
  final supa = GetIt.I<SupabaseClient>();

  @override
  void initState() {
    super.initState();

    // Si es agregar rol, pre-llenar campos desde el usuario actual
    if (isAddingRole) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillExistingUserData();
      });
    }
  }

  void _fillExistingUserData() {
    final authController = context.read<AuthController>();
    final user = authController.user;

    if (user != null) {
      emailController.text = user.email;
      firstNameController.text = user.firstName ?? '';
      lastName1Controller.text = user.lastName1 ?? '';
      lastName2Controller.text = user.lastName2 ?? '';
      phoneController.text = user.phone ?? '';
    }
  }

  @override
  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Future<void> performRegistration() async {
    // Crear cuenta de usuario
    final res = await supa.auth.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    if (res.user == null) throw const AuthException('No se pudo crear la cuenta');
    final uid = res.user!.id;

    // Actualizar perfil
    await supa.from('profile').update({
      'first_name': firstNameController.text.trim(),
      'last_name1': lastName1Controller.text.trim(),
      'last_name2': lastName2Controller.text.trim(),
      'phone': phoneController.text.trim(),
      'role': 'driver',
      'id_number': _cedulaController.text.trim(),
    }).eq('user_id', uid);

    // Continuar al formulario 2 con los datos
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        Routes.deliver_Form2,
        arguments: {
          'uid': uid,
          'licenseNumber': _licenseController.text.trim(),
        },
      );
    }
  }

  @override
  Future<void> performRoleAddition() async {
    // Para agregar rol de driver, solo necesitamos continuar al siguiente paso
    // Los datos personales ya están en la cuenta
    final authController = context.read<AuthController>();
    final user = authController.user;
    
    if (user == null) {
      throw Exception('No hay sesión activa');
    }

    // Continuar al formulario 2 para cargar documentos
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        Routes.deliver_Form2,
        arguments: {
          'uid': user.id,
          'licenseNumber': _licenseController.text.trim(),
        },
      );
    }
  }

  @override
  void onRegistrationSuccess() {
    // No hacer nada aquí porque redirigimos al siguiente formulario
  }

  @override
  void dispose() {
    disposeCommonControllers();
    _cedulaController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            isAddingRole 
                ? 'Agregar rol de Repartidor' 
                : 'Crea tu cuenta de repartidor',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Mostrar información si es agregar rol
                if (isAddingRole) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Agregando rol de Repartidor a tu cuenta existente. '
                            'Solo necesitas proporcionar información adicional específica para repartidores.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                buildErrorWidget(),

                // Cédula
                buildTextField(
                  label: 'Cédula',
                  controller: _cedulaController,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  validator: (v) => v!.length == 9 ? null : '9 dígitos requeridos',
                ),
                const SizedBox(height: 20),

                // Número de Licencia
                buildTextField(
                  label: 'Número de licencia',
                  controller: _licenseController,
                  maxLength: 12,
                  validator: (v) => v!.isNotEmpty ? null : 'Requerido',
                ),
                const SizedBox(height: 20),

                // Información personal (deshabilitar si es agregar rol)
                buildTextField(
                  label: 'Nombre',
                  controller: firstNameController,
                  enabled: !isAddingRole,
                ),
                const SizedBox(height: 20),

                buildTextField(
                  label: 'Primer apellido',
                  controller: lastName1Controller,
                  enabled: !isAddingRole,
                ),
                const SizedBox(height: 20),

                buildTextField(
                  label: 'Segundo apellido',
                  controller: lastName2Controller,
                  enabled: !isAddingRole,
                ),
                const SizedBox(height: 20),

                buildTextField(
                  label: 'Teléfono',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 8,
                  validator: validatePhone,
                  enabled: !isAddingRole,
                ),
                const SizedBox(height: 20),

                buildTextField(
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  enabled: !isAddingRole,
                ),

                // Solo mostrar campos de contraseña si no es agregar rol
                if (!isAddingRole) ...[
                  const SizedBox(height: 20),
                  buildTextField(
                    label: 'Contraseña',
                    controller: passwordController,
                    obscureText: hidePassword,
                    validator: validatePassword,
                    suffix: IconButton(
                      icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    label: 'Confirmar contraseña',
                    controller: confirmPasswordController,
                    obscureText: hideConfirmPassword,
                    validator: validateConfirmPassword,
                    suffix: IconButton(
                      icon: Icon(hideConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => hideConfirmPassword = !hideConfirmPassword),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                buildSubmitButton(
                  label: 'Continuar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
