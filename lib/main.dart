// FalaTEA - Aplicativo de Comunicação Aumentativa e Alternativa
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Serviços
import 'package:projeto/services/auth_services.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:projeto/services/tts_service.dart';

// Páginas
import 'package:projeto/pages/splash_page.dart';
import 'package:projeto/pages/login_page.dart';
import 'package:projeto/pages/home_page.dart';
import 'package:projeto/pages/selecao_perfil_page.dart';

// AuthCheck
import 'package:projeto/widgets/auth_check.dart';

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
        ],
        child: const FalaTEA(),
      ),
    );
  });
}

class FalaTEA extends StatelessWidget {
  const FalaTEA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FalaTEA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
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
