// lib/app/features/merchant/presentation/pages/merchant_step_business.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/widgets/merchant_form_fields.dart';
import 'package:provider/provider.dart';

import '../../../../interface/Navigators/routes.dart';

class MerchantStepBusiness extends StatefulWidget {
  const MerchantStepBusiness({super.key});

  @override
  State<MerchantStepBusiness> createState() => _MerchantStepBusinessState();
}

class _MerchantStepBusinessState extends State<MerchantStepBusiness> {
  /* ──────────── form + controllers ──────────── */
  final _fKey      = GlobalKey<FormState>();
  final _legalId   = TextEditingController();
  final _name      = TextEditingController();
  final _corpName  = TextEditingController();
  final _address   = TextEditingController();

  XFile? _logo;

  Future<void> _pickLogo() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (img != null) setState(() => _logo = img);
  }

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
                  group        : MerchantFieldGroup.business,
                  businessName : _name,
                  corpName     : _corpName,
                  legalId      : _legalId,
                  address      : _address,
                  logo         : _logo,
                  onPickLogo   : _pickLogo,
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
                    onPressed: (_logo == null)
                        ? null
                        : () {
                            if (!_fKey.currentState!.validate()) return;
                            ctrl.updateBusinessInfo(
                              legalId      : _legalId.text.trim(),
                              businessName : _name.text.trim(),
                              corporateName: _corpName.text.trim(),
                              address      : _address.text.trim(),
                              logo         : _logo!,
                            );
                            Navigator.pushNamed(
                                context, Routes.merchantStepOwner);
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
    _legalId.dispose();
    _name.dispose();
    _corpName.dispose();
    _address.dispose();
    super.dispose();
  }
}
