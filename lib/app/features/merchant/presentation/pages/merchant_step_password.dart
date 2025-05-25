import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/widgets/merchant_form_fields.dart';
import 'package:provider/provider.dart';

import '../../../../interface/Navigators/routes.dart';

class MerchantStepPassword extends StatefulWidget {
  final bool isAddingRole;
  
  const MerchantStepPassword({super.key, this.isAddingRole = false});

  @override
  State<MerchantStepPassword> createState() => _MerchantStepPasswordState();
}

class _MerchantStepPasswordState extends State<MerchantStepPassword> {
  final _fKey = GlobalKey<FormState>();
  final _pw   = TextEditingController();
  final _pw2  = TextEditingController();
  bool _hide1 = true, _hide2 = true;
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<MerchantRegistrationController>();

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
                            'Confirmando el rol de Comerciante para tu cuenta existente.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Solo mostrar campos de contraseña si NO es agregar rol
                if (!widget.isAddingRole) ...[
                  MerchantFields(
                    group      : MerchantFieldGroup.password,
                    pw         : _pw,
                    pwConfirm  : _pw2,
                    hidePw     : _hide1,
                    hidePw2    : _hide2,
                    togglePw   : () => setState(() => _hide1 = !_hide1),
                    togglePw2  : () => setState(() => _hide2 = !_hide2),
                  ),
                ] else ...[
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store, size: 80, color: Color(0xffd72a23)),
                          SizedBox(height: 20),
                          Text(
                            '¡Listo para ser Comerciante!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffd72a23),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Ya puedes empezar a gestionar tu negocio',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffd72a23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),                    onPressed: ctrl.state == MerchantRegistrationState.loading
                        ? null
                        : () async {
                            // Si es agregar rol, no necesita validar contraseña
                            if (!widget.isAddingRole) {
                              if (!_fKey.currentState!.validate()) return;
                            }
                            
                            final ok = await ctrl.finishRegistration(
                              password: widget.isAddingRole ? '' : _pw.text,
                              isAddingRole: widget.isAddingRole,
                            );
                            
                            if (!mounted) return;
                            if (ok) {
                              if (widget.isAddingRole) {
                                // Mostrar mensaje de éxito y redirigir a home
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Rol de Comerciante agregado con éxito!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Routes.home_food,
                                  (route) => false,
                                );
                              } else {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Routes.driverPending,
                                  (_) => false,
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ctrl.errorMessage ??
                                        'Ocurrió un error inesperado',
                                  ),
                                ),
                              );
                            }
                          },                    child: ctrl.state == MerchantRegistrationState.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.isAddingRole ? 'Agregar Rol' : 'Registrar',
                            style: const TextStyle(fontSize: 20),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }
}
