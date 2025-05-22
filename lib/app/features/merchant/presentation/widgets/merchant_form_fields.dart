import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MerchantFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController legalIdController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final XFile? logo;
  final bool hidePw;
  final bool hidePw2;
  final VoidCallback onPickLogo;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final String? error;

  const MerchantFormFields({
    Key? key,
    required this.formKey,
    required this.legalIdController,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmController,
    this.logo,
    required this.hidePw,
    required this.hidePw2,
    required this.onPickLogo,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(children: [
        TextFormField(
          controller: legalIdController,
          decoration: _dec('Cédula jurídica'),
          maxLength: 11, 
          keyboardType: TextInputType.number,
          validator: (v) => v!.length == 11 ? null : '11 dígitos'
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: nameController,
          decoration: _dec('Nombre del comercio'),
          validator: (v) => v!.isNotEmpty ? null : 'Requerido'
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: phoneController,
          decoration: _dec('Teléfono'),
          keyboardType: TextInputType.phone,
          maxLength: 8,
          validator: (v) => v!.length == 8 ? null : '8 dígitos'
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: addressController,
          decoration: _dec('Dirección del local'),
          validator: (v) => v!.isNotEmpty ? null : 'Requerido'
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: emailController,
          decoration: _dec('Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v!.contains('@') ? null : 'Correo inválido'
        ),
        const SizedBox(height: 20),
        // Logo
        const Text(
          'Selecciona una imagen del comercio',
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 10),
        LogoSelectionButton(
          hasLogo: logo != null,
          onPickLogo: onPickLogo,
        ),
        const SizedBox(height: 20),
        // Password
        PasswordField(
          controller: passwordController,
          hidePassword: hidePw,
          onToggleVisibility: onTogglePassword,
          label: 'Contraseña',
        ),
        const SizedBox(height: 20),
        PasswordField(
          controller: passwordConfirmController,
          hidePassword: hidePw2,
          onToggleVisibility: onToggleConfirmPassword,
          label: 'Confirmar contraseña',
          validateAgainst: passwordController.text,
        ),
        const SizedBox(height: 20),
        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),
      ]),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(labelText: label);
}

class LogoSelectionButton extends StatelessWidget {
  final bool hasLogo;
  final VoidCallback onPickLogo;

  const LogoSelectionButton({
    Key? key,
    required this.hasLogo,
    required this.onPickLogo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xffd72a23), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPickLogo,
        child: Text(
          hasLogo ? 'Imagen seleccionada ✔' : 'Seleccionar imagen',
          style: const TextStyle(
            color: Color(0xffd72a23),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool hidePassword;
  final VoidCallback onToggleVisibility;
  final String label;
  final String? validateAgainst;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.hidePassword,
    required this.onToggleVisibility,
    required this.label,
    this.validateAgainst,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
      obscureText: hidePassword,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (v.length < 6) return 'Mín 6 caracteres';
        if (validateAgainst != null && v != validateAgainst) return 'No coincide';
        return null;
      },
    );
  }
}
