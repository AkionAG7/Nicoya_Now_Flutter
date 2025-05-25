import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/interface/Widgets/BaseRegistrationForm.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class ClientForm extends BaseRegistrationForm {
  const ClientForm({Key? key, bool isAddingRole = false}) 
      : super(
          key: key,
          roleSlug: 'client',
          roleTitle: 'Cliente',
          isAddingRole: isAddingRole,
        );

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends BaseRegistrationFormState<ClientForm>
    with CommonFormFields {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

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
    final authController = context.read<AuthController>();
    
    final success = await authController.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
      firstName: firstNameController.text.trim(),
      lastName1: lastName1Controller.text.trim(),
      lastName2: lastName2Controller.text.trim(),
      phone: phoneController.text.trim(),
      address: _addressController.text.trim(),
      roleSlug: roleSlug,
    );

    if (!success) {
      throw Exception(authController.errorMessage ?? 'Error al crear la cuenta');
    }
  }

  @override
  Future<void> performRoleAddition() async {
    // Para cliente, solo necesitamos agregar el rol
    // Los datos personales ya existen
  }

  @override
  void onRegistrationSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAddingRole
            ? '¡Rol de Cliente agregado con éxito!'
            : '¡Cuenta de cliente creada con éxito!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.home_food,
      (route) => false,
    );
  }

  @override
  void dispose() {
    disposeCommonControllers();
    _addressController.dispose();
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
            isAddingRole ? 'Agregar rol de Cliente' : 'Crea tu cuenta de Cliente',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                            'Agregando rol de Cliente a tu cuenta existente. '
                            'Los campos están prellenados con tu información.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                buildErrorWidget(),

                buildTextField(
                  label: 'Nombre',
                  controller: firstNameController,
                  keyboardType: TextInputType.name,
                  enabled: !isAddingRole, // Deshabilitar si es agregar rol
                ),
                const SizedBox(height: 20),

                buildTextField(
                  label: 'Primer apellido',
                  controller: lastName1Controller,
                  keyboardType: TextInputType.name,
                  enabled: !isAddingRole,
                ),
                const SizedBox(height: 20),

                buildTextField(
                  label: 'Segundo apellido',
                  controller: lastName2Controller,
                  keyboardType: TextInputType.name,
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
                  label: 'Domicilio',
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
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
                  label: isAddingRole ? 'Agregar Rol de Cliente' : 'Registrar Cliente',
                ),

                // Solo mostrar botón de Google si no es agregar rol
                if (!isAddingRole) ...[
                  const SizedBox(height: 20),
                  Consumer<AuthController>(
                    builder: (context, authController, _) => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Implementar lógica de Google Sign-In
                        },
                        icon: const Icon(Icons.login, size: 24),
                        label: const Text('Google', style: TextStyle(fontSize: 18)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xffd72a23),
                          side: const BorderSide(color: Color(0xffd72a23)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
