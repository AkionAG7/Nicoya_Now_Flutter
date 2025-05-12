import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({Key? key}) : super(key: key);

  @override
  _ClientForm1State createState() => _ClientForm1State();
}

// correo, numero de telefono, domiciolio, nombre, apellido, contraseña, confirmar contraseña
class _ClientForm1State extends State<ClientForm> {
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

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
              'Crea tu cuenta',
              style: TextStyle(
                fontSize: 30,
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
                    key: Key('nombre'),
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Martin',
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    key: Key('apellidos'),
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                      hintText: 'Gomez Lopez',
                    ),
                  ),

                  const SizedBox(height: 30),

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

                  const SizedBox(height: 30),

                  TextFormField(
                    key: Key('domicilio'),
                    keyboardType: TextInputType.streetAddress,
                    decoration: const InputDecoration(
                      labelText: 'Domicilio',
                      hintText: '75 metros al norte de la plaza',
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    key: Key('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'gomesmartin@gmail.com',
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    key: const Key('contraseña'),
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'contraseña',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    key: const Key('confirmar_contraseña'),
                    keyboardType: TextInputType.visiblePassword,
                    controller: _confirmpasswordController,
                    obscureText: _obscureTextConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      hintText: 'contraseña',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureTextConfirm = !_obscureTextConfirm;
                          });
                        },
                        icon: Icon(
                          _obscureTextConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => print('Funcion de OnSubmit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffd72a23),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                          ),
                          child: Text(
                            'Registar',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          
                        ),

                        ElevatedButton(
                          onPressed: () => print('Funcion de login con google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffffffff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              side: BorderSide(color: Color(0xffd72a23)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(NicoyaNowIcons.google, size: 25,),
                              SizedBox(width: 5),
                              Text(
                                'Google',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xffd72a23),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
