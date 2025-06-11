import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/address/domain/entities/address.dart';
import 'package:nicoya_now/app/features/auth/data/datasources/auth_data_source.dart';
import 'package:nicoya_now/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/get_user_adress_usecase.dart';

import 'package:nicoya_now/app/features/auth/domain/usecases/update_customer_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustumerModifyInfo extends StatefulWidget {
  const CustumerModifyInfo({super.key});

  @override
  CustumerModifyInfoState createState() => CustumerModifyInfoState();
}

class CustumerModifyInfoState extends State<CustumerModifyInfo> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();

  final _address = TextEditingController();
  late List<Address> _addresses = [];
  Address? _selectedAddress;

  bool _loading = false;

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final dataSource = SupabaseAuthDataSource(Supabase.instance.client);
      final repo = AuthRepositoryImpl(dataSource);
      final updateCase = UpdateCustomerInfoCase(repo);

      await updateCase.call(
        userId: userId,
        phone: _phone.text.trim(),
        address: _address.text.trim(),
      );

      ScaffoldMessenger.of(
        //ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Información actualizada')));
    } catch (e) {
      ScaffoldMessenger.of(
        //ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _text(
    String label,
    TextEditingController c, {
    TextInputType? type,
    int? maxLen,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      maxLength: maxLen,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final dataSource = SupabaseAuthDataSource(Supabase.instance.client);
    final repo = AuthRepositoryImpl(dataSource);
    final getAddresses = GetUserAdressUsecase(repo);
    final addresses = await getAddresses.call(userId);

    setState(() {
      _addresses = addresses;
      if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.first;
        _address.text = _selectedAddress!.street;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Actualiza tu información',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context)..pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                _text('Teléfono', _phone, type: TextInputType.phone, maxLen: 8),
                const SizedBox(height: 20),

                DropdownButtonFormField<Address>(
                  value: _selectedAddress,
                  items:
                      _addresses.map((address) {
                        return DropdownMenuItem<Address>(
                          value: address,
                          child: Text(address.street),
                        );
                      }).toList(),
                  onChanged: (address) {
                    setState(() {
                      _selectedAddress = address;
                      _address.text = address?.street ?? '';
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Selecciona tu dirección',
                  ),
                ),

                const SizedBox(height: 20),
                _text(
                  'Modifica el domicilio',
                  _address,
                  type: TextInputType.streetAddress,
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _update,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffd72a23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _loading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Acutalizar información',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
