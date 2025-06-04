import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/widgets/merchant_form_fields.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

import '../../../../interface/Navigators/routes.dart';

class MerchantStepPassword extends StatefulWidget {
  const MerchantStepPassword({super.key});

  @override
  State<MerchantStepPassword> createState() => _MerchantStepPasswordState();
}

class _MerchantStepPasswordState extends State<MerchantStepPassword> {
  final _fKey = GlobalKey<FormState>();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _hide1 = true, _hide2 = true;
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<MerchantRegistrationController>();
    final authController = context.read<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crea tu cuenta de comercio')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _fKey,
            child: Column(
              children: [
                MerchantFields(
                  group: MerchantFieldGroup.password,
                  pw: _pw,
                  pwConfirm: _pw2,
                  hidePw: _hide1,
                  hidePw2: _hide2,
                  togglePw: () => setState(() => _hide1 = !_hide1),
                  togglePw2: () => setState(() => _hide2 = !_hide2),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffd72a23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                        ctrl.state == MerchantRegistrationState.loading
                            ? null
                            : () async {
                              if (!_fKey.currentState!.validate()) return;

                              try {
                                // Mostrar un indicador de carga
                                setState(() {});

                                final ok = await ctrl.finishRegistration(
                                  password: _pw.text,
                                  authController: authController,
                                );

                                if (!mounted) return;

                                if (ok) {
                                  // Show success message
                                  //ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Cuenta creada exitosamente',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  // Navigate to the merchant pending page as verification is required
                                  Navigator.pushNamedAndRemoveUntil(
                                    //ignore: use_build_context_synchronously
                                    context,
                                    Routes.merchantPending,
                                    (_) => false,
                                  );
                                } else {
                                  // Show error message with more details
                                  //ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ctrl.errorMessage ??
                                            'Ocurrió un error inesperado',
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Capturar y mostrar cualquier error inesperado
                                if (mounted) {
                                  //ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 7),
                                    ),
                                  );
                                }
                              }
                            },
                    child:
                        ctrl.state == MerchantRegistrationState.loading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Registrar',
                              style: TextStyle(fontSize: 20),
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
