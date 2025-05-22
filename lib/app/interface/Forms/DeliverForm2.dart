import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliverForm2 extends StatefulWidget {
  const DeliverForm2({Key? key}) : super(key: key);

  @override
  State<DeliverForm2> createState() => _DeliverForm2State();
}

class _DeliverForm2State extends State<DeliverForm2> {
  // ───────── data que llega desde la pantalla 1 ─────────
late String _driverId;
late String _licenseNumber;
bool _initDone = false; 

  // ───────── estado local ─────────
  String? _selectedOption;      // car | motorbike | bike
  File? _licencia;
  File? _antecedentes;
  bool _loading = false;
  String? _error;

  final supa = GetIt.I<SupabaseClient>();

  // ───────── helpers ─────────
  Future<File?> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    return res != null ? File(res.files.single.path!) : null;
  }

  Future<void> _uploadAndSave() async {
    if (_selectedOption == null || _licencia == null || _antecedentes == null) {
      setState(() => _error = 'Completa vehículo y ambos documentos');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final extLic = _licencia!.path.split('.').last;
    final extRec = _antecedentes!.path.split('.').last;
    final pathLic = 'driver/$_driverId/license.$extLic';
    final pathRec = 'driver/$_driverId/record.$extRec';

    try {
      // 1· Subir archivos al bucket privado
      await supa.storage.from('driver-docs').upload(
        pathLic, _licencia!,
        fileOptions: const FileOptions(upsert: true),
      );
      await supa.storage.from('driver-docs').upload(
        pathRec, _antecedentes!,
        fileOptions: const FileOptions(upsert: true),
      );

      // 2· Insertar fila driver
      await supa.from('driver').insert({
        'driver_id'          : _driverId,
        'vehicle_type'       : _selectedOption,      // car/motorbike/bike
        'license_number'     : _licenseNumber,
        'insurance_doc_url'  : pathLic,
        'criminal_record_url': pathRec,
        // is_verified -> false por default
      });

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.driverPending,
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ───────── ciclo de vida ─────────
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (_initDone) return;                 // ya lo hicimos una vez
  final args = ModalRoute.of(context)!.settings.arguments as Map;
  _driverId       = args['uid'] as String;
  _licenseNumber  = args['licenseNumber'] as String;
  _initDone = true;
}

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          title: const Text(
            'Crea tu cuenta de repartidor',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ───────── dropdown vehículo ─────────
                  DropdownButtonFormField<String>(
                    value: _selectedOption,
                    items: const [
                      DropdownMenuItem(value: 'car',       child: Text('Automóvil')),
                      DropdownMenuItem(value: 'motorbike', child: Text('Motocicleta')),
                      DropdownMenuItem(value: 'bike',      child: Text('Bicicleta')),
                    ],
                    onChanged: (v) => setState(() => _selectedOption = v),
                    decoration: const InputDecoration(
                      labelText: 'Selecciona el tipo de vehículo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ───────── textos y botón archivo según tipo ─────────
                  if (_selectedOption != null) ...[
                    const Text(
                      'Documentos requeridos para registrar el vehículo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
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
                    _btnSelectFile(
                      label: _licencia == null ? 'Subir licencia' : 'Licencia ✔',
                      onTap: () async {
                        final f = await _pickFile();
                        if (f != null) setState(() => _licencia = f);
                      },
                    ),
                    const SizedBox(height: 12),
                    _btnSelectFile(
                      label: _antecedentes == null
                          ? 'Subir certificado de antecedentes'
                          : 'Antecedentes ✔',
                      onTap: () async {
                        final f = await _pickFile();
                        if (f != null) setState(() => _antecedentes = f);
                      },
                    ),
                  ],

                  if (_selectedOption == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Por favor selecciona un tipo de vehiculo',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),

                  // ───────── botón Registrar ─────────
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffd72a23),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _loading ? null : _uploadAndSave,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Registrar', style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── widget botón seleccionar archivo ─────────
  Widget _btnSelectFile({required String label, required VoidCallback onTap}) {
    return Center(
      child: SizedBox(
        height: 55,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffd72a23),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onTap,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
