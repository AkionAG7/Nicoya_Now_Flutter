// lib/app/features/merchant/presentation/pages/edit_phone_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class EditPhonePage extends StatefulWidget {
  const EditPhonePage({Key? key}) : super(key: key);

  @override
  _EditPhonePageState createState() => _EditPhonePageState();
}

class _EditPhonePageState extends State<EditPhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supa = Supabase.instance.client;
      final userId = supa.auth.currentUser!.id;

      // Trae el teléfono actual del perfil
      final resp = await supa
          .from('profile')
          .select('phone')
          .eq('user_id', userId)
          .maybeSingle();

      if (resp != null && resp is Map<String, dynamic>) {
        _phoneController.text = resp['phone'] as String? ?? '';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _savePhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supa = Supabase.instance.client;
      final userId = supa.auth.currentUser!.id;

      // Actualiza el teléfono en la tabla `profile`
      await supa
          .from('profile')
          .update({
            'phone': _phoneController.text.trim(),
          })
          .eq('user_id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teléfono actualizado correctamente')),
      );

      Navigator.of(context).pop(); // Vuelve a MerchantSettingsPage
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Teléfono')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Obligatorio';
                            }
                            if (!RegExp(r'^\d{7,15}$').hasMatch(v.trim())) {
                              return 'Número inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _savePhone,
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Cerrar sesión',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                            final prefs =
                                await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.preLogin,
                              (_) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
