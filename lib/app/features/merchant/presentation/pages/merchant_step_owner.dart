
import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/widgets/merchant_form_fields.dart';
import 'package:provider/provider.dart';
import '../../../../interface/Navigators/routes.dart';

class MerchantStepOwner extends StatefulWidget {
  final bool isAddingRole;
  
  const MerchantStepOwner({super.key, this.isAddingRole = false});

  @override
  State<MerchantStepOwner> createState() => _MerchantStepOwnerState();
}

class _MerchantStepOwnerState extends State<MerchantStepOwner> {
  final _fKey   = GlobalKey<FormState>();
  final _name   = TextEditingController();
  final _last1  = TextEditingController();
  final _last2  = TextEditingController();
  final _email  = TextEditingController();
  final _phone  = TextEditingController();  @override
  void initState() {
    super.initState();
    // Si es agregar rol, pre-llenar datos del usuario existente
    if (widget.isAddingRole) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctrl = context.read<MerchantRegistrationController>();
        
        // Llenar datos desde el AuthController
        ctrl.fillExistingUserData();
        
        // Pre-llenar campos en la UI después de llenar los datos
        _fillUIFields(ctrl);
        
        // Forzar rebuild para mostrar los datos
        setState(() {});
      });
    }
  }
  void _fillUIFields(MerchantRegistrationController ctrl) {
    print('🎯 [MerchantStepOwner] Llenando campos de UI...');
    
    // Pre-llenar campos en la UI con verificación de nulos
    if (ctrl.firstName != null && ctrl.firstName!.isNotEmpty) {
      _name.text = ctrl.firstName!;
      print('   ✅ firstName: "${ctrl.firstName}"');
    }
    if (ctrl.lastName1 != null && ctrl.lastName1!.isNotEmpty) {
      _last1.text = ctrl.lastName1!;
      print('   ✅ lastName1: "${ctrl.lastName1}"');
    }
    if (ctrl.lastName2 != null && ctrl.lastName2!.isNotEmpty) {
      _last2.text = ctrl.lastName2!;
      print('   ✅ lastName2: "${ctrl.lastName2}"');
    }
    if (ctrl.email != null && ctrl.email!.isNotEmpty) {
      _email.text = ctrl.email!;
      print('   ✅ email: "${ctrl.email}"');
    }
    if (ctrl.phone != null && ctrl.phone!.isNotEmpty) {
      _phone.text = ctrl.phone!;
      print('   ✅ phone: "${ctrl.phone}"');
    }
    
    print('🎯 [MerchantStepOwner] Campos llenados exitosamente');
  }@override
  Widget build(BuildContext context) {
    return Consumer<MerchantRegistrationController>(
      builder: (context, ctrl, child) {
        // Si es agregar rol, asegurar que los campos estén llenos
        if (widget.isAddingRole) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Verificar si hay datos del usuario para prellenar
            if (ctrl.firstName != null && ctrl.firstName!.isNotEmpty) {
              _fillUIFields(ctrl);
            } else {
              // Si no hay datos, llenarlos desde AuthController
              ctrl.fillExistingUserData();
            }
          });
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.isAddingRole 
                ? 'Agregar rol de Comerciante' 
                : 'Crea tu cuenta de comercio'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _fKey,
                child: Column(
                  children: [
                    // Mostrar información si es agregar rol
                    if (widget.isAddingRole) ...[
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
                                'Verificando información personal para el rol de Comerciante. '
                                'Estos datos se toman de tu cuenta existente.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    MerchantFields(
                      group      : MerchantFieldGroup.owner,
                      firstName  : _name,
                      lastName1  : _last1,
                      lastName2  : _last2,
                      email      : _email,
                      phone      : _phone,
                      isAddingRole: widget.isAddingRole,
                    ),

                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xffd72a23),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (!_fKey.currentState!.validate()) return;
                          ctrl.updateOwnerInfo(
                            firstName : _name.text.trim(),
                            lastName1 : _last1.text.trim(),
                            lastName2 : _last2.text.trim(),
                            email     : _email.text.trim(),
                            phone     : _phone.text.trim(),
                          );
                          Navigator.pushNamed(
                            context, 
                            Routes.merchantStepPassword,
                            arguments: {'isAddingRole': widget.isAddingRole},
                          );
                        },
                        child: const Text('Continuar',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _last1.dispose();
    _last2.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }
}
