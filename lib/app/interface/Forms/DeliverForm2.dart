import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DeliverForm2 extends StatefulWidget {
  const DeliverForm2({Key? key}) : super(key: key);

  @override
  _DeliverForm2State createState() => _DeliverForm2State();
}

class _DeliverForm2State extends State<DeliverForm2> {
  String? _selectedOption;

  List<PlatformFile> _archivosSeleccionados = [];

  Future<void> seleccionarArchivos() async {
    try {
      final archivos = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf', 'docx'],
      );

      if (archivos != null) {
        setState(() {
          _archivosSeleccionados = archivos.files;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar archivos: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedOption = null;
  }

  @override
  void dispose() {
    _archivosSeleccionados.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: const Text(
              'Crea tu cuenta de repartidor',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xff000000),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedOption,
                    items: const [
                      DropdownMenuItem(value: 'Auto', child: Text('Automóvil')),
                      DropdownMenuItem(
                        value: 'Motocicleta',
                        child: Text('Motocicleta'),
                      ),
                      DropdownMenuItem(
                        value: 'Bicicleta',
                        child: Text('Bicicleta'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Selecciona el tipo de vehiculo',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  if (_selectedOption == 'Auto') ...[
                    SizedBox(height: 20),
                    Text(
                      'Documentos requeridos para registrar el vehículo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('- Certificado de antecedentes penales'),
                    Text('- Licencia de conducir'),
                    Text('- Marchamo vigente'),
                    Text('- Información bancaria'),
                    Text('- Revisión técnica vehicular'),
                    Text('- Póliza de seguro'),
                    SizedBox(height: 60),
                    botonSeleccionarArchivos(),
                  ],

                  if (_selectedOption == 'Motocicleta') ...[
                    SizedBox(height: 20),
                    Text(
                      'Documentos requeridos para registrar el vehículo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('- Hoja de delincuencia'),
                    Text('- Licencia de conducir'),
                    Text('- Marchamo vigente'),
                    Text('- Información bancaria'),
                    Text('- Revisión técnica vehicular'),
                    Text('- Póliza de seguro'),
                  ],

                  if (_selectedOption == 'Bicicleta') ...[
                    SizedBox(height: 20),
                    Text(
                      'Documentos requeridos para registrar el vehículo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('- Hoja de delincuencia'),
                    Text('- Póliza de seguro'),
                    Text('- Información bancaria'),
                  ],

                  if (_selectedOption == null)
                    Center(
                      child: const Text(
                        'Por favor selecciona un tipo de vehiculo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),


                  SizedBox(height: 150),
                  botonSubmit(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widgets reutilizables, el codigo en pantalla es el de arriba
  Widget botonSeleccionarArchivos() {
    return Center(
      child: SizedBox(
        height: 100,
        width: 250,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffd72a23),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: seleccionarArchivos,
          child: Text(
            'Seleccionar archivos',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget botonSubmit() {
    return Center(
      child: SizedBox(
        height: 70,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffd72a23),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            // Aquí puedes agregar la lógica para enviar el formulario
          },
          child: Text(
            'Registrar',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
