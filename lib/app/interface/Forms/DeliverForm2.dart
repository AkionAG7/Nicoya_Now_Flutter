import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

class DeliverForm2 extends StatefulWidget {
  final bool isAddingRole;
  
  const DeliverForm2({Key? key, this.isAddingRole = false}) : super(key: key);
  
  @override State<DeliverForm2> createState() => _DeliverForm2State();
}

class _DeliverForm2State extends State<DeliverForm2> {
  // args de la pantalla 1
  late String _driverId;
  late String _licenseNumber;
  bool _initDone = false;

  // estado
  String? _selectedOption;               
  List<PlatformFile> _files = [];       
  bool _loading = false;
  String? _error;
    // Servicios
  final supa = GetIt.I<SupabaseClient>();
  late final AuthController _authController;

  String _safeName(String original) {
    final cleaned = original.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'file' : cleaned;
  }
  @override
  void initState() {
    super.initState();
    _authController = context.read<AuthController>();
  }


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
    setState(() { _loading = true; _error = null; });

    try {
      if (widget.isAddingRole) {
        await _addDriverRole();
      } else {
        await _performFullRegistration();
      }
      
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context, Routes.driverPending, (_) => false);
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  Future<void> _addDriverRole() async {
    final user = _authController.user;
    if (user == null) throw Exception('No hay sesión activa');

    // Subir documentos
    await _uploadDocuments();

    // Insertar datos en tabla driver
    await supa.from('driver').upsert({
      'driver_id': user.id,
      'vehicle_type': _selectedOption!,
      'license_number': _licenseNumber,
      'docs_url': 'driver/${user.id}/',
      'is_verified': false,    });

    // Agregar rol de driver usando solo AuthController
    await _authController.addRole('driver');
  }

  Future<void> _performFullRegistration() async {
    // Subir documentos
    await _uploadDocuments();

    // Insertar datos en tabla driver
    await supa.from('driver').upsert({
      'driver_id': _driverId,
      'vehicle_type': _selectedOption,
      'license_number': _licenseNumber,
      'docs_url': 'driver/$_driverId/',
      'is_verified': false,
    });
  }

  Future<void> _uploadDocuments() async {
    final userId = widget.isAddingRole ? _authController.user!.id : _driverId;
    final folder = 'driver/$userId/';

    for (final f in _files) {
      final safe = _safeName(f.name);
      final path = '$folder$safe';
      if (kIsWeb) {
        await supa.storage
            .from('driver-docs')
            .uploadBinary(path, f.bytes!,
                fileOptions: const FileOptions(upsert: true));
      } else {
        await supa.storage
            .from('driver-docs')
            .upload(path, File(f.path!),
                fileOptions: const FileOptions(upsert: true));
      }
    }
  }


  @override void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initDone) return;
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _driverId      = args['uid'] as String;
    _licenseNumber = args['licenseNumber'] as String;
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
        widget.isAddingRole 
          ? 'Agregar rol de repartidor' 
          : 'Crea tu cuenta de repartidor',
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información contextual cuando se está agregando rol
            if (widget.isAddingRole) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Agregando rol de repartidor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa los datos específicos del vehículo y documentos para activar tu rol de repartidor.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ],
            // Dropdown vehículo
            DropdownButtonFormField<String>(
              value: _selectedOption,
              items: const [
                DropdownMenuItem(value:'car',       child:Text('Automóvil')),
                DropdownMenuItem(value:'motorbike', child:Text('Motocicleta')),
                DropdownMenuItem(value:'bike',      child:Text('Bicicleta')),
              ],
              onChanged:(v)=>setState(()=>_selectedOption=v),
              decoration: const InputDecoration(
                labelText:'Selecciona el tipo de vehículo',
                border:OutlineInputBorder()),
            ),
            const SizedBox(height:20),

            if(_selectedOption!=null)...[
              const Text('Documentos requeridos para registrar el vehículo',
                  style:TextStyle(fontWeight:FontWeight.bold,fontSize:14)),
              const SizedBox(height:12),
              // (lista fija; la tuya original)
              if(_selectedOption=='car')...[
                const Text('- Certificado de antecedentes penales'),
                const Text('- Licencia de conducir'),
                const Text('- Marchamo vigente'),
                const Text('- Información bancaria'),
                const Text('- Revisión técnica vehicular'),
                const Text('- Póliza de seguro'),
              ] else if(_selectedOption=='motorbike')...[
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
              const SizedBox(height:20),
              _btnSelectFiles(),
              if(_files.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top:8),
                  child: Text('${_files.length} archivo(s) seleccionado(s) ✔'),
                ),
            ],

            if(_selectedOption==null)
              const Padding(
                padding:EdgeInsets.only(top:12),
                child:Text('Por favor selecciona un tipo de vehículo',
                    style:TextStyle(color:Colors.red,fontSize:16,fontWeight:FontWeight.bold)),
              ),

            const SizedBox(height:40),
            if(_error!=null) Text(_error!,style:const TextStyle(color:Colors.red)),
            const SizedBox(height:16),            SizedBox(
              height: 70, width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _uploadAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffd72a23),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.isAddingRole ? 'Agregar rol' : 'Registrar',
                      style: const TextStyle(fontSize: 20, color: Colors.white)
                    ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _btnSelectFiles() => SizedBox(
    height:55,width:double.infinity,
    child:ElevatedButton(
      onPressed:_pickFiles,
      style:ElevatedButton.styleFrom(
        backgroundColor:const Color(0xffd72a23),
        shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))),
      child: const Text('Seleccionar archivos',
          style:TextStyle(color:Colors.white)),
    ),
  );
}
