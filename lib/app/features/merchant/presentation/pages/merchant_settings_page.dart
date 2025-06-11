// lib/app/features/merchant/presentation/pages/merchant_settings_page.dart

import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/edit_address_page.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/edit_phone_merchant.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantSettingsPage extends StatefulWidget {
  const MerchantSettingsPage({Key? key}) : super(key: key);

  @override
  _MerchantSettingsPageState createState() => _MerchantSettingsPageState();
}

class _MerchantSettingsPageState extends State<MerchantSettingsPage> {
  late Future<Map<String, dynamic>> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  Future<void> _reload() async {
    setState(() {
      _loadFuture = _loadData();
    });
  }

  Future<Map<String, dynamic>> _loadData() async {
    final supa   = Supabase.instance.client;
    final userId = supa.auth.currentUser!.id;

    // 1) Merchant con su dirección relacional
    final m = await supa
        .from('merchant')
        .select('''
          merchant_id,
          owner_id,
          legal_id,
          business_name,
          corporate_name,
          logo_url,
          is_active,
          created_at,
          main_address:main_address_id (street)
        ''')
        .eq('owner_id', userId)
        .maybeSingle();
    if (m == null) throw Exception('No existe merchant para $userId');

    // 2) Perfil para teléfono, cédula, etc.
    final p = await supa
        .from('profile')
        .select('phone, id_number')
        .eq('user_id', userId)
        .maybeSingle();

    return {
      'merchant': Map<String, dynamic>.from(m as Map),
      'profile' : p == null ? {} : Map<String, dynamic>.from(p as Map),
      'email'   : supa.auth.currentUser!.email  ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final data     = snap.data!;
          final merchant = data['merchant'] as Map<String, dynamic>;
          final profile  = data['profile']  as Map<String, dynamic>;
          final email    = data['email']    as String;
          final address  = merchant['main_address'] as Map<String, dynamic>?;

          final cedula = (merchant['legal_id'] as String?)?.isNotEmpty == true
            ? merchant['legal_id'] as String
            : (profile['id_number'] as String? ?? '-');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Logo
              if ((merchant['logo_url'] as String?)?.isNotEmpty ?? false)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage(merchant['logo_url'] as String),
                  ),
                ),
              const SizedBox(height: 16),

              // Nombre y Razón Social
              ListTile(
                leading: const Icon(Icons.store),
                title: Text(merchant['business_name'] as String),
                subtitle: const Text('Nombre Corporativo'),
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: Text(merchant['corporate_name'] as String? ?? '-'),
                subtitle: const Text('Razón Social'),
              ),

              const Divider(),

              // Datos del encargado
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(email),
                subtitle: const Text('Correo'),
              ),
             ListTile(
  leading: const Icon(Icons.phone),
  title: Text(profile['phone'] as String? ?? '-'),
  subtitle: const Text('Teléfono'),
  trailing: TextButton(
    onPressed: () {
      Navigator.of(context)
          .push(MaterialPageRoute(
            builder: (_) => const EditPhonePage(),
          ))
          .then((_) {
            // Al volver de EditPhonePage, recarga los datos
            _reload();
          });
    },
    child: const Text('Editar'),
  ),
),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: Text(cedula),
                subtitle: const Text('Cédula'),
              ),

              const Divider(),

              // Dirección principal
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(address?['street'] as String? ?? '-'),
                subtitle: const Text('Dirección Principal'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                          builder: (_) => const EditAddressPage(addressId: '',),
                        ))
                        .then((_) {
                          // Al volver de la edición, recarga los datos
                          _reload();
                        });
                  },
                  child: const Text('Editar'),
                ),
              ),

              const Divider(),

              // Activo y Fecha de creación
              ListTile(
                leading: const Icon(Icons.toggle_on),
                title:
                    Text((merchant['is_active'] as bool) ? 'Sí' : 'No'),
                subtitle: const Text('Activo'),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  DateTime.parse(
                    merchant['created_at'] as String,
                  ).toLocal().toString(),
                ),
                subtitle: const Text('Creado en'),
              ),

              const SizedBox(height: 24),

              // Cerrar sesión
              TextButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Cerrar sesión',
                    style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.preLogin, (route) => false);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
