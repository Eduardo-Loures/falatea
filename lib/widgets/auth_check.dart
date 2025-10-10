import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projeto/main.dart';
import 'package:projeto/services/auth_services.dart';
import 'package:provider/provider.dart';

import '../pages/login_page.dart';



class AuthCheck extends StatefulWidget {
  AuthCheck({Key? key}) : super(key: key);

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    if(auth.isLoading) return loading();
    else if(auth.usuario == null) return LoginPage();
    else return TelaInicial();
  }

  loading() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

