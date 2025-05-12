import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class DeliverForm1 extends StatefulWidget {
  const DeliverForm1({Key? key}) : super(key: key);

  @override
  _DeliverForm1State createState() => _DeliverForm1State();
}

class _DeliverForm1State extends State<DeliverForm1> {
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
                children: [
                  TextFormField(
                    key: Key('cedula'),
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    buildCounter:
                        (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                    decoration: const InputDecoration(
                      labelText: 'Cedula',
                      hintText: '000000000',
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    key: Key('nombre'),
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Martin',
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    key: Key('apellidos'),
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                      hintText: 'Gomez Lopez',
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
                    key: Key('domicilio'),
                    keyboardType: TextInputType.streetAddress,
                    decoration: const InputDecoration(
                      labelText: 'Domicilio',
                      hintText: '75 metros al norte de la plaza',
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

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xfff10027),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          () =>
                              Navigator.pushNamed(context, Routes.deliver_Form2),
                      child: Text(
                        'Continuar',
                        style: TextStyle(color: Colors.white, fontSize: 30),
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
