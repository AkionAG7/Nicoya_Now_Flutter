
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/widgets/merchant_form_fields.dart';
import 'package:provider/provider.dart';
import '../../../../interface/Navigators/routes.dart';

class MerchantStepBusiness extends StatefulWidget {
  final bool isAddingRole;
  
  const MerchantStepBusiness({super.key, this.isAddingRole = false});

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

  @override
  void initState() {
    super.initState();
    
    // Si es agregar rol, pre-llenar datos del usuario existente
    if (widget.isAddingRole) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctrl = context.read<MerchantRegistrationController>();
        ctrl.fillExistingUserData();
      });
    }
  }

  Future<void> _pickLogo() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (img != null) setState(() => _logo = img);
  }

  void _onCedulaTypeChanged(bool juridica) =>
      setState(() => _isCedulaJuridica = juridica);

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<MerchantRegistrationController>();    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAddingRole 
            ? 'Agregar rol de Comerciante' 
            : 'Crear cuenta de comercio'),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Mostrar información si es agregar rol
            if (widget.isAddingRole) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                        'Agregando rol de Comerciante a tu cuenta existente. '
                        'Proporciona la información del negocio.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
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
                  key: _fKey,                  child: MerchantFields(
                    group              : MerchantFieldGroup.business,
                    businessName       : _name,
                    corpName           : _corpName,
                    legalId            : _legalId,
                    address            : _address,
                    logo               : _logo,
                    onPickLogo         : _pickLogo,
                    isCedulaJuridica   : _isCedulaJuridica,
                    onCedulaTypeChanged: _onCedulaTypeChanged,
                    isAddingRole       : widget.isAddingRole,
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
                      borderRadius: BorderRadius.circular(8))),
                  onPressed: (_logo == null)
                      ? null
                      : () {
                          if (!_fKey.currentState!.validate()) return;
                          ctrl.updateBusinessInfo(
                            legalId          : _legalId.text.trim(),
                            businessName     : _name.text.trim(),
                            corporateName    : _corpName.text.trim(),
                            address          : _address.text.trim(),
                            logo             : _logo!,
                            isCedulaJuridica : _isCedulaJuridica,
                          );                          Navigator.pushNamed(
                            context, 
                            Routes.merchantStepOwner,
                            arguments: {'isAddingRole': widget.isAddingRole},
                          );
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
