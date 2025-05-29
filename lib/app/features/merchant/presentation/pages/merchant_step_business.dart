import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/widgets/merchant_form_fields.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import '../../../../interface/Navigators/routes.dart';

class MerchantStepBusiness extends StatefulWidget {
  const MerchantStepBusiness({super.key});

  @override
  State<MerchantStepBusiness> createState() => _MerchantStepBusinessState();
}

class _MerchantStepBusinessState extends State<MerchantStepBusiness> {
  final _fKey      = GlobalKey<FormState>();
  final _legalId   = TextEditingController();
  final _name      = TextEditingController();
  final _corpName  = TextEditingController();
  final _address   = TextEditingController();
  XFile? _logo;
  bool  _isCedulaJuridica = true;
  bool  _isAddingRole = false; // Flag para saber si estamos agregando un rol a un usuario existente
  bool  _isLoading = false;  // Flag para mostrar indicador de carga

  Future<void> _pickLogo() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (img != null) setState(() => _logo = img);
  }

  void _onCedulaTypeChanged(bool juridica) =>
      setState(() => _isCedulaJuridica = juridica);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if this page was navigated from RoleFormPage for adding a role to existing user
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _isAddingRole = args['isAddingRole'] as bool? ?? false;
    }
  }
  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<MerchantRegistrationController>();    return Scaffold(
      appBar: AppBar(
        title: Text(_isAddingRole 
          ? 'Agregar rol de comercio'
          : 'Crear cuenta de comercio'
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            if (_isAddingRole) ...[
              // Mensaje explicativo para usuarios que añaden rol
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Para agregar el rol de comerciante a tu cuenta, necesitamos algunos datos de tu negocio:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Form(
                  key: _fKey,
                  child: MerchantFields(
                    group              : MerchantFieldGroup.business,
                    businessName       : _name,
                    corpName           : _corpName,
                    legalId            : _legalId,
                    address            : _address,
                    logo               : _logo,
                    onPickLogo         : _pickLogo,
                    isCedulaJuridica   : _isCedulaJuridica,
                    onCedulaTypeChanged: _onCedulaTypeChanged,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xffd72a23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),                  onPressed: (_logo == null)
                      ? null
                      : () async {
                          if (!_fKey.currentState!.validate()) return;
                          ctrl.updateBusinessInfo(
                            legalId          : _legalId.text.trim(),
                            businessName     : _name.text.trim(),
                            corporateName    : _corpName.text.trim(),
                            address          : _address.text.trim(),
                            logo             : _logo!,
                            isCedulaJuridica : _isCedulaJuridica,
                          );
                          
                          if (_isAddingRole) {
                            // Si estamos agregando un rol a un usuario existente,
                            // no necesitamos los pasos de propietario y contraseña
                            final authController = Provider.of<AuthController>(context, listen: false);
                            
                            setState(() => _isLoading = true);
                            try {                              // Agregar rol de comerciante al usuario actual
                              final userId = authController.user?.id;
                              if (userId == null) {
                                throw Exception('Usuario no encontrado');
                              }                              // Prepare role data with all necessary information
                              final roleData = {
                                'id_number': _legalId.text.trim(),
                                'business_name': _name.text.trim(),
                                'corporate_name': _corpName.text.trim(),
                                'address': _address.text.trim(),
                                'logoPath': _logo!.path,
                                // Make sure the owner_id is explicitly set and correctly passed
                                'owner_id': userId,
                              };
                              
                              // Add the role to the current user
                              final success = await authController.addRoleToCurrentUser(
                                RoleType.merchant,
                                roleData
                              );
                                if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Rol de comerciante agregado correctamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );                                // Navigate to the merchant pending page since verification is required
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  Routes.merchantPending, 
                                  (route) => false
                                );
                              } else {
                                // Show a detailed error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authController.errorMessage ?? 'Error al agregar el rol'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          } else {
                            // Flujo normal para nuevos usuarios
                            Navigator.pushNamed(context, Routes.merchantStepOwner);
                          }
                        },
                  child: const Text('Continuar',
                      style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _legalId.dispose();
    _name.dispose();
    _corpName.dispose();
    _address.dispose();
    super.dispose();
  }
}
