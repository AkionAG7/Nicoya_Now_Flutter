import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ComerseForm extends StatefulWidget {
  const ComerseForm({Key? key}) : super(key: key);

  @override
  _ComerseFormState createState() => _ComerseFormState();
}

class _ComerseFormState extends State<ComerseForm> {
  File? _selectedImage;

  Future<void> seleccionarImagen() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagen = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (imagen != null) {
        setState(() {
          _selectedImage = File(imagen.path);
        });
      }

      print('Imagen seleccionada: ${_selectedImage?.path}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _selectedImage?.delete();
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
              'Crea tu cuenta de comercio',
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
                children: [
                  TextFormField(
                    key: Key('cedulaJuridica'),
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    buildCounter:
                        (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                    decoration: const InputDecoration(
                      labelText: 'Cedula juridica',
                      hintText: '00000000000',
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    key: Key('nombre'),
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del comercio',
                      hintText: 'Tacos el Perez',
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    key: Key('telefono'),
                    keyboardType: TextInputType.phone,
                    maxLength: 8,
                    buildCounter:
                        (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                    decoration: const InputDecoration(
                      labelText: 'Telefono',
                      hintText: '00993322',
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    key: Key('direccion'),
                    keyboardType: TextInputType.streetAddress,
                    decoration: const InputDecoration(
                      labelText: 'Direccion del local',
                      hintText: '75 metros al este de la plaza de Nicoya',
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    key: Key('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'gomesmartin@gmail.com',
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'Selecciona una imagen del comercio',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffffffff),
                        side: BorderSide(
                          color: const Color(0xffd72a23),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: seleccionarImagen,

                      child: Text(
                        'Seleccionar imagen',
                        style: TextStyle(
                          color: const Color(0xffd72a23),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffd72a23),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Registrar comercio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
