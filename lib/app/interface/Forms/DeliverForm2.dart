import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
class DeliverForm2 extends StatefulWidget {
  const DeliverForm2({super.key});
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
  String _safeName(String original) {
  final cleaned = original.toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9._-]'), '_');
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
      setState(() => _error = 'Selecciona vehículo y al menos un archivo'); return;
    }
    setState(() { _loading = true; _error = null; });

    final folder = 'driver/$_driverId/';      

    try {
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


      await supa.from('driver').upsert({
        'driver_id'      : _driverId,
        'vehicle_type'   : _selectedOption,
        'license_number' : _licenseNumber,
        'docs_url'       : folder,
        'is_verified'    : false,
      });

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context, Routes.driverPending, (_) => false);
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
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
      backgroundColor: Colors.white, scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: const Text('Crea tu cuenta de repartidor',
          style: TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20,20,20,0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
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
            const SizedBox(height:16),

            SizedBox(
              height:70,width:double.infinity,
              child:ElevatedButton(
                onPressed:_loading?null:_uploadAndSave,
                style:ElevatedButton.styleFrom(
                  backgroundColor:const Color(0xffd72a23),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))),
                child:_loading
                  ? const CircularProgressIndicator(color:Colors.white)
                  : const Text('Registrar',style:TextStyle(fontSize:20,color:Colors.white)),
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
