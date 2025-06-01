import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/data/datasources/auth_data_source.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserBottomBarCustomer extends StatefulWidget {
  const UserBottomBarCustomer({super.key});

  @override
  UserBottomBarCustomerState createState() => UserBottomBarCustomerState();
}

class UserBottomBarCustomerState extends State<UserBottomBarCustomer> {
  final AuthDataSource authDataSource = SupabaseAuthDataSource(
    Supabase.instance.client,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf10027),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  await authDataSource.signOut();
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.pushNamedAndRemoveUntil(context,
                    Routes.login_page,
                    (route) => false,
                  );
                },
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
