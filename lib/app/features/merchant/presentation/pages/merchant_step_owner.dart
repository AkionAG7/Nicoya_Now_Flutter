
import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/widgets/merchant_form_fields.dart';
import 'package:provider/provider.dart';
import '../../../../interface/Navigators/routes.dart';

class MerchantStepOwner extends StatefulWidget {
  const MerchantStepOwner({super.key});

  @override
  State<MerchantStepOwner> createState() => _MerchantStepOwnerState();
}

class _MerchantStepOwnerState extends State<MerchantStepOwner> {
  final _fKey   = GlobalKey<FormState>();
  final _name   = TextEditingController();
  final _last1  = TextEditingController();
  final _last2  = TextEditingController();
  final _email  = TextEditingController();
  final _phone  = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<MerchantRegistrationController>();

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
                  group      : MerchantFieldGroup.owner,
                  firstName  : _name,
                  lastName1  : _last1,
                  lastName2  : _last2,
                  email      : _email,
                  phone      : _phone,
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
                      Navigator.pushNamed(context, Routes.merchantStepPassword);
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
