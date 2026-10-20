// FalaTEA - Aplicativo de Comunicação Aumentativa e Alternativa
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Serviços
import 'package:projeto/services/acessibilidade_service.dart';
import 'package:projeto/services/auth_services.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:projeto/services/tts_service.dart';

// Páginas
import 'package:projeto/pages/splash_page.dart';
import 'package:projeto/pages/login_page.dart';
import 'package:projeto/pages/home_page.dart';
import 'package:projeto/pages/selecao_perfil_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => PerfilService()),
          ChangeNotifierProvider(create: (_) => TtsService()),
          ChangeNotifierProvider(create: (_) => AcessibilidadeService()),
        ],
        child: const FalaTEA(),
      ),
    );
  });
}

class FalaTEA extends StatelessWidget {
  const FalaTEA({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FalaTEA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // Limita o tamanho da fonte do celular
      builder:
          (context, child) => MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: child!,
          ),

      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/selecionar_perfil': (_) => const SelecaoPerfilPage(),
      },

      home: const SplashPage(),
    );
  }
}
