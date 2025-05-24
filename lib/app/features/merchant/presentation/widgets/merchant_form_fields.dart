// lib/app/features/merchant/presentation/widgets/merchant_fields.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Paso (business | owner | password) que se debe renderizar
enum MerchantFieldGroup { business, owner, password }

class MerchantFields extends StatelessWidget {
  /* ──────────── BUSINESS ──────────── */
  final TextEditingController? legalId;
  final TextEditingController? businessName;
  final TextEditingController? corpName;
  final TextEditingController? address;
  final XFile?                logo;
  final VoidCallback?         onPickLogo;

  /* ──────────── OWNER ──────────── */
  final TextEditingController? firstName;
  final TextEditingController? lastName1;
  final TextEditingController? lastName2;
  final TextEditingController? email;
  final TextEditingController? phone;

  /* ─────────── PASSWORD ─────────── */
  final TextEditingController? pw;
  final TextEditingController? pwConfirm;
  final bool                   hidePw;
  final bool                   hidePw2;
  final VoidCallback?          togglePw;
  final VoidCallback?          togglePw2;

  /* ─────────── CONFIG ─────────── */
  final MerchantFieldGroup     group;
  final String?                error;

  const MerchantFields({
    super.key,
    required this.group,
    /* business */
    this.legalId,
    this.businessName,
    this.corpName,
    this.address,
    this.logo,
    this.onPickLogo,
    /* owner */
    this.firstName,
    this.lastName1,
    this.lastName2,
    this.email,
    this.phone,
    /* pw */
    this.pw,
    this.pwConfirm,
    this.hidePw = true,
    this.hidePw2 = true,
    this.togglePw,
    this.togglePw2,
    /* misc */
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];

if (group == MerchantFieldGroup.business) {
  widgets.addAll([
    _text(businessName , 'Nombre del comercio'),
    _sp,
    _text(corpName     , 'Razón social (opcional)', required: false),
    _sp,
    _text(legalId      , 'Cédula jurídica',
          keyboard: TextInputType.number, maxLen: 11),
    _sp,
    _text(address      , 'Dirección del local', maxLines: 2),
    const SizedBox(height: 25),
    _logoButton(),
  ]);
}

if (group == MerchantFieldGroup.owner) {
  widgets.addAll([
    _text(firstName , 'Nombre del encargado'),
    _sp,
    _text(lastName1 , 'Primer apellido del encargado'),
    _sp,
    _text(lastName2 , 'Segundo apellido del encargado'),
    _sp,
    _text(email     , 'Correo del comercio/encargado',
          keyboard: TextInputType.emailAddress,
          validator: (v) => v!.contains('@') ? null : 'Correo inválido'),
    _sp,
    _text(phone     , 'Número del comercio/encargado',
          keyboard: TextInputType.phone, maxLen: 8),
  ]);
}

// 3️⃣ PASSWORD
if (group == MerchantFieldGroup.password) {
  widgets.addAll([
    _password(pw       , hidePw ,  togglePw ,  'Contraseña'),
    _sp,
    _password(pwConfirm, hidePw2, togglePw2,
              'Confirmar contraseña', validate: pw?.text),
  ]);
}

    if (error != null) {
      widgets
        ..add(const SizedBox(height:10))
        ..add(Text(error!, style: const TextStyle(color: Colors.red)));
    }

    return Column(children: widgets);
  }

  /* ───────────────────────── helpers ───────────────────────── */

  static const _sp = SizedBox(height: 20);

  InputDecoration _dec(String lbl) => InputDecoration(
        labelText: lbl,
        border: const OutlineInputBorder(),
      );

  Widget _text(TextEditingController? c, String lbl,
      {bool required = true,
       int? maxLen,
       int maxLines = 1,
       TextInputType keyboard = TextInputType.text,
       String? Function(String?)? validator}) {
    assert(c != null, 'Controller para $lbl no provisto');

    return TextFormField(
      controller: c,
      maxLength : maxLen,
      maxLines  : maxLines,
      keyboardType: keyboard,
      decoration: _dec(lbl),
      validator : validator ??
          (v) => required && (v == null || v.trim().isEmpty) ? 'Requerido' : null,
    );
  }

  Widget _password(TextEditingController? c, bool hide, VoidCallback? onToggle,
      String lbl, {String? validate}) {
    assert(c != null, 'Controller para $lbl no provisto');

    return TextFormField(
      controller: c,
      obscureText: hide,
      decoration: InputDecoration(
        labelText: lbl,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (v.length < 6) return 'Mín 6 caracteres';
        if (validate != null && v != validate) return 'No coincide';
        return null;
      },
    );
  }

  Widget _logoButton() => SizedBox(
        height: 120,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPickLogo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xffd72a23), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            logo == null ? 'Seleccionar imagen'
                          : 'Imagen seleccionada ✔',
            style: const TextStyle(
              color: Color(0xffd72a23),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
