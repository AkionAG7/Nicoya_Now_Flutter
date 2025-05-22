import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/widgets/merchant_form_fields.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:provider/provider.dart';

class ComerseForm extends StatefulWidget {
  const ComerseForm({Key? key}) : super(key: key);
  @override State<ComerseForm> createState() => _ComerseFormState();
}

class _ComerseFormState extends State<ComerseForm> {
  final _formKey = GlobalKey<FormState>();

  final _legalIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  XFile? _logo;
  bool _hidePw = true;
  bool _hidePw2 = true;
  String? _error;

  // ───────── image picker ─────────
  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 70);
    if (img != null) setState(() => _logo = img);
  }

  // ───────── registrar comercio ─────────
  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_logo == null) {
      setState(() => _error = 'Debes seleccionar un logo'); 
      return;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() => _error = 'Las contraseñas no coinciden'); 
      return;
    }
    
    final controller = Provider.of<MerchantRegistrationController>(context, listen: false);
    
    try {
      final success = await controller.registerMerchant(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        legalId: _legalIdController.text.trim(),
        businessName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        logo: _logo!,
      );
      
      if (!mounted) return;
      
      if (success) {
        Navigator.pushNamedAndRemoveUntil(
          context, Routes.driverPending, (_) => false);
      } else {
        setState(() => _error = controller.errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      title: const Text('Crea tu cuenta de comercio',
          style: TextStyle(fontSize:25,fontWeight:FontWeight.bold,color:Colors.black)),
      automaticallyImplyLeading: false,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(children: [
          MerchantFormFields(
            formKey: _formKey,
            legalIdController: _legalIdController,
            nameController: _nameController,
            phoneController: _phoneController,
            addressController: _addressController,
            emailController: _emailController,
            passwordController: _passwordController,
            passwordConfirmController: _passwordConfirmController,
            logo: _logo,
            hidePw: _hidePw,
            hidePw2: _hidePw2,
            onPickLogo: _pickLogo,
            onTogglePassword: () => setState(() => _hidePw = !_hidePw),
            onToggleConfirmPassword: () => setState(() => _hidePw2 = !_hidePw2),
            error: _error,
          ),
          const SizedBox(height: 12),
          Consumer<MerchantRegistrationController>(
            builder: (context, controller, _) {
              final isLoading = controller.state == MerchantRegistrationState.loading;
              
              return SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _register(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffd72a23),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar comercio',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              );
            }
          ),
        ]),
      ),
    ),
  );

  @override
  void dispose() {
    _legalIdController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }
}
