import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto/services/auth_services.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:projeto/pages/login_page.dart';
import 'package:projeto/pages/home_page.dart';
import 'package:projeto/pages/selecao_perfil_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _verificarEstado();
  }

  Future<void> _verificarEstado() async {
    await Future.delayed(const Duration(milliseconds: 1500)); // apenas animação

    final auth = context.read<AuthService>();
    final perfilService = context.read<PerfilService>();

    final usuario = auth.usuario;

    if (usuario == null) {
      // Ninguém logado → vai para login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    // Usuário logado → carrega perfis
    await perfilService.carregarDadosUsuario();

    if (!perfilService.temPerfis) {
      // Não tem perfil → vai criar/selecionar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelecaoPerfilPage()),
      );
      return;
    }

    // Já tem perfil ativo → ir para Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[700]!,
              Colors.indigo[500]!,
              Colors.indigo[300]!,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.record_voice_over,
                  size: 60,
                  color: Colors.indigo[700],
                ),
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'FalaTEA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Carregando...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
