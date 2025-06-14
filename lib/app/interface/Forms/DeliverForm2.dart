import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class DeliverForm2 extends StatefulWidget {
  const DeliverForm2({super.key});
  @override
  State<DeliverForm2> createState() => _DeliverForm2State();
}

class _DeliverForm2State extends State<DeliverForm2> {
  // args de la pantalla 1
  late String _driverId;
  String _licenseNumber = ''; // Inicializado como cadena vacía
  bool _isAddingRole =
      false; // Flag to detect if adding role vs new registration
  bool _initDone = false;

  // estado
  String? _selectedOption;
  List<PlatformFile> _files = [];
  bool _loading = false;
  String? _error;
  String _safeName(String original) {
    final cleaned = original.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9._-]'),
      '_',
    );
    return cleaned.isEmpty ? 'file' : cleaned;
  }

  final supa = GetIt.I<SupabaseClient>();

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (res != null) setState(() => _files = res.files);
  }

  Future<void> _uploadAndSave() async {
    if (_selectedOption == null || _files.isEmpty) {
      setState(() => _error = 'Selecciona vehículo y al menos un archivo');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final folder = 'driver/$_driverId/';

    try {
      for (final f in _files) {
        final safe = _safeName(f.name);
        final path = '$folder$safe';
        if (kIsWeb) {
          await supa.storage
              .from('driver-docs')
              .uploadBinary(
                path,
                f.bytes!,
                fileOptions: const FileOptions(upsert: true),
              );
        } else {
          await supa.storage
              .from('driver-docs')
              .upload(
                path,
                File(f.path!),
                fileOptions: const FileOptions(upsert: true),
              );
        }
      } // Usamos el license_number que fue pasado en los argumentos
      // Si _licenseNumber está vacío, debería haber sido un error antes de llegar aquí
      if (_licenseNumber.isEmpty) {
        setState(
          () =>
              _error =
                  'Falta el número de licencia. Regrese y complete el formulario anterior.',
        );
        throw Exception('Falta número de licencia');
      }

      // Crear o actualizar el registro en la tabla driver con TODOS los datos necesarios
      await supa.from('driver').upsert({
        'driver_id': _driverId,
        'vehicle_type': _selectedOption,
        'license_number': _licenseNumber,
        'docs_url': folder,
        'is_verified': false,
      });
      if (!mounted) return;      if (_isAddingRole) {
        // Show success message for role addition
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Rol de repartidor agregado exitosamente! Tu cuenta está pendiente de verificación. Por favor, inicia sesión nuevamente.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        
        // Sign out user to require fresh login
        await Supabase.instance.client.auth.signOut();
        
        // Navigate to login page instead of maintaining session
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login_page,
          (_) => false,
        );      } else {
        // New user registration - go to login page after signing out
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Registro exitoso! Tu cuenta está pendiente de verificación. Por favor, inicia sesión.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        
        // Sign out user to require fresh login
        await Supabase.instance.client.auth.signOut();
        
        // Navigate to login page instead of role selection
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login_page,
          (_) => false,
        );
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initDone) return;
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _driverId = args['uid'] as String;

    // Asignar licenseNumber solo si está presente en los argumentos
    if (args.containsKey('licenseNumber') && args['licenseNumber'] != null) {
      _licenseNumber = args['licenseNumber'] as String;
    }

    _isAddingRole = args['isAddingRole'] as bool? ?? false;
    _initDone = true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        _isAddingRole
            ? 'Completar registro de repartidor'
            : 'Crea tu cuenta de repartidor',
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown vehículo
            DropdownButtonFormField<String>(
              value: _selectedOption,
              items: const [
                DropdownMenuItem(value: 'car', child: Text('Automóvil')),
                DropdownMenuItem(
                  value: 'motorbike',
                  child: Text('Motocicleta'),
                ),
                DropdownMenuItem(value: 'bike', child: Text('Bicicleta')),
              ],
              onChanged: (v) => setState(() => _selectedOption = v),
              decoration: const InputDecoration(
                labelText: 'Selecciona el tipo de vehículo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            if (_selectedOption != null) ...[
              const Text(
                'Documentos requeridos para registrar el vehículo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              // (lista fija; la tuya original)
              if (_selectedOption == 'car') ...[
                const Text('- Certificado de antecedentes penales'),
                const Text('- Licencia de conducir'),
                const Text('- Marchamo vigente'),
                const Text('- Información bancaria'),
                const Text('- Revisión técnica vehicular'),
                const Text('- Póliza de seguro'),
              ] else if (_selectedOption == 'motorbike') ...[
                const Text('- Hoja de delincuencia'),
                const Text('- Licencia de conducir'),
                const Text('- Marchamo vigente'),
                const Text('- Información bancaria'),
                const Text('- Revisión técnica vehicular'),
                const Text('- Póliza de seguro'),
              ] else ...[
                const Text('- Hoja de delincuencia'),
                const Text('- Póliza de seguro'),
                const Text('- Información bancaria'),
              ],
              const SizedBox(height: 20),
              _btnSelectFiles(),
              if (_files.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${_files.length} archivo(s) seleccionado(s) ✔'),
                ),
            ],

            if (_selectedOption == null)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Por favor selecciona un tipo de vehículo',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 40),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),

            SizedBox(
              height: 70,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _uploadAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffd72a23),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Registrar',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _btnSelectFiles() => SizedBox(
    height: 55,
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _pickFiles,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffd72a23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Seleccionar archivos',
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}
