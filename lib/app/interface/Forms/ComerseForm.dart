import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComerseForm extends StatefulWidget {
  const ComerseForm({Key? key}) : super(key: key);
  @override State<ComerseForm> createState() => _ComerseFormState();
}

class _ComerseFormState extends State<ComerseForm> {
  final _formKey = GlobalKey<FormState>();

  final _legalId   = TextEditingController();
  final _name      = TextEditingController();
  final _phone     = TextEditingController();
  final _address   = TextEditingController();
  final _email     = TextEditingController();
  final _pass      = TextEditingController();
  final _passConf  = TextEditingController();

  XFile? _logo;
  bool _hidePw = true, _hidePw2 = true, _loading = false;
  String? _error;

  final supa = GetIt.I<SupabaseClient>();

  // ───────── image picker ─────────
  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 70);
    if (img != null) setState(() => _logo = img);
  }

  // ───────── registrar comercio ─────────
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_logo == null) {
      setState(() => _error = 'Debes seleccionar un logo'); return;
    }
    if (_pass.text != _passConf.text) {
      setState(() => _error = 'Las contraseñas no coinciden'); return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      // 1· crear usuario auth
      final res = await supa.auth.signUp(
        email: _email.text.trim(),
        password: _pass.text,
      );
      if (res.user == null) throw const AuthException('No se pudo crear cuenta');
      final uid = res.user!.id;

      // 2· actualizar profile
      await supa.from('profile').update({
        'first_name': _name.text.trim(),   
        'role'      : 'merchant',
      }).eq('user_id', uid);

     // 3· address (principal)
final addr = await supa
    .from('address')
    .insert({
      'user_id': uid,
      'street' : _address.text.trim(),
      'district': '',
    })
    .select('address_id')
    .single();                            

final addressId = addr['address_id'] as String;   


      // 4· subir logo
      final ext = _logo!.name.split('.').last;
      final path = 'merchant/$uid/logo.$ext';

      if (kIsWeb) {
        final bytes = await _logo!.readAsBytes();
        await supa.storage.from('merchant-assets')
            .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert:true));
      } else {
        await supa.storage.from('merchant-assets')
            .upload(path, File(_logo!.path),
                    fileOptions: const FileOptions(upsert:true));
      }

      final publicUrl = supa.storage.from('merchant-assets').getPublicUrl(path);

      // 5· insertar merchant
      await supa.from('merchant').insert({
        'merchant_id'    : uid,           
        'owner_id'       : uid,
        'legal_id'       : _legalId.text.trim(),
        'business_name'  : _name.text.trim(),
        'logo_url'       : publicUrl,
        'main_address_id': addressId,
        'is_active'      : false,
      });

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context, Routes.driverPending, (_) => false);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String l)=>InputDecoration(labelText:l);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white, scrolledUnderElevation: 0,
      title: const Text('Crea tu cuenta de comercio',
          style: TextStyle(fontSize:25,fontWeight:FontWeight.bold,color:Colors.black)),
      automaticallyImplyLeading:false,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20,20,20,0),
        child: Form(
          key: _formKey,
          child: Column(children:[
            TextFormField(controller:_legalId, decoration:_dec('Cédula jurídica'),
              maxLength:11, keyboardType:TextInputType.number,
              validator:(v)=>v!.length==11?null:'11 dígitos'),
            const SizedBox(height:20),
            TextFormField(controller:_name, decoration:_dec('Nombre del comercio'),
              validator:(v)=>v!.isNotEmpty?null:'Requerido'),
            const SizedBox(height:20),
            TextFormField(controller:_phone, decoration:_dec('Teléfono'),
              keyboardType:TextInputType.phone, maxLength:8,
              validator:(v)=>v!.length==8?null:'8 dígitos'),
            const SizedBox(height:20),
            TextFormField(controller:_address, decoration:_dec('Dirección del local'),
              validator:(v)=>v!.isNotEmpty?null:'Requerido'),
            const SizedBox(height:20),
            TextFormField(controller:_email, decoration:_dec('Email'),
              keyboardType:TextInputType.emailAddress,
              validator:(v)=>v!.contains('@')?null:'Correo inválido'),
            const SizedBox(height:20),
            // Logo
            const Text('Selecciona una imagen del comercio',
                style: TextStyle(fontWeight:FontWeight.bold)),
            const SizedBox(height:10),
            SizedBox(
              height:120,width:double.infinity,
              child:ElevatedButton(
                style:ElevatedButton.styleFrom(
                  backgroundColor:Colors.white,
                  side: const BorderSide(color:Color(0xffd72a23),width:2),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))),
                onPressed:_pickLogo,
                child:Text(
                  _logo==null?'Seleccionar imagen':'Imagen seleccionada ✔',
                  style:const TextStyle(color:Color(0xffd72a23),fontSize:20,fontWeight:FontWeight.bold)),
              ),
            ),
            const SizedBox(height:20),
            // Password
            TextFormField(controller:_pass, decoration:_dec('Contraseña'),
              obscureText:_hidePw,
              validator:(v)=>v!.length>=6?null:'Mín 6'),
            const SizedBox(height:20),
            TextFormField(controller:_passConf, decoration:_dec('Confirmar contraseña'),
              obscureText:_hidePw2,
              validator:(v)=>v==_pass.text?null:'No coincide'),
            const SizedBox(height:20),
            if(_error!=null)Text(_error!,style:const TextStyle(color:Colors.red)),
            const SizedBox(height:12),
            SizedBox(
              width:double.infinity,height:70,
              child:ElevatedButton(
                onPressed:_loading?null:_register,
                style:ElevatedButton.styleFrom(
                  backgroundColor:const Color(0xffd72a23),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))),
                child:_loading
                  ? const CircularProgressIndicator(color:Colors.white)
                  : const Text('Registrar comercio',
                      style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    for (final c in [_legalId,_name,_phone,_address,_email,_pass,_passConf]) {
      c.dispose();
    }
    super.dispose();
  }
}
