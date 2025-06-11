// lib/app/features/merchant/presentation/pages/edit_address_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({Key? key, required String addressId}) : super(key: key);

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  bool    _loading    = true;
  String? _error;

  String? _addressId;
  final _streetController   = TextEditingController();
  final _districtController = TextEditingController();
  final _latController      = TextEditingController();
  final _lngController      = TextEditingController();
  final _noteController     = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    setState(() {
      _loading = true;
      _error   = null;
    });

    try {
      final supa   = Supabase.instance.client;
      final userId = supa.auth.currentUser!.id;

      // obtenemos solo la dirección principal del merchant
      final resp = await supa
          .from('merchant')
          .select('main_address:address (*)')
          .eq('owner_id', userId)
          .maybeSingle();

      if (resp == null) {
        throw Exception('No se encontró merchant para $userId');
      }

      final m       = resp as Map<String, dynamic>;
      final address = m['main_address'] as Map<String, dynamic>;

      _addressId = address['address_id'] as String;
      _streetController.text   = address['street']   as String? ?? '';
      _districtController.text = address['district'] as String? ?? '';
      _latController.text      = (address['lat']     as num?)?.toString() ?? '';
      _lngController.text      = (address['lng']     as num?)?.toString() ?? '';
      _noteController.text     = address['note']     as String? ?? '';
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _addressId == null) return;

    setState(() {
      _loading = true;
      _error   = null;
    });

    try {
      final supa = Supabase.instance.client;

      await supa
          .from('address')
          .update({
            'street'   : _streetController.text.trim(),
            'district' : _districtController.text.trim(),
            'lat'      : double.tryParse(_latController.text) ?? 0.0,
            'lng'      : double.tryParse(_lngController.text) ?? 0.0,
            'note'     : _noteController.text.trim(),
          })
          .eq('address_id', _addressId as Object);
          

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dirección actualizada correctamente')),
      );
      Navigator.of(context).pop(); // volvemos atrás
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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Editar Dirección')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Editar Dirección')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Dirección')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Calle / Avenida',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'Distrito',
                  prefixIcon: Icon(Icons.map),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'Latitud',
                  prefixIcon: Icon(Icons.pin_drop),
                ),
                keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(
                  labelText: 'Longitud',
                  prefixIcon: Icon(Icons.pin_drop_outlined),
                ),
                keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
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
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.preLogin, (_) => false);
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
    _streetController.dispose();
    _districtController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
