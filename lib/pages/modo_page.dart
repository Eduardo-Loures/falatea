import 'package:flutter/material.dart';

import 'package:projeto/pages/home_page.dart';
import 'package:projeto/games/escolher_game.dart';
import 'package:provider/provider.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:projeto/pages/selecao_perfil_page.dart';
import 'package:projeto/pages/jogos_page.dart';

class ModoPage extends StatelessWidget {
  const ModoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [
              Colors.indigo[800]!,
              Colors.indigo[600]!,
              Colors.indigo[300]!,
            ],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                // LOGO
                SizedBox(
                  height: 320,

                  child: Image.asset(
                    'assets/logo/falatea.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 0),
                const Text(
                  'Escolha um modo',

                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),

                const SizedBox(height: 60),

                // BOTÃO AAC
                _buildModoButton(
                  context: context,

                  titulo: 'Comunicação',

                  subtitulo: 'Utilize os botões AAC para comunicação.',

                  icon: Icons.record_voice_over_rounded,

                  cor: Colors.blue,

                  onTap: () async {
                    final perfilService = context.read<PerfilService>();

                    await perfilService.carregarDadosUsuario();

                    if (perfilService.temPerfis) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SelecaoPerfilPage(),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 25),

                // BOTÃO GAME
                _buildModoButton(
                  context: context,

                  titulo: 'Jogos',

                  subtitulo: 'Evolua relacionando imagens.',

                  icon: Icons.psychology_rounded,

                  cor: Colors.green,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JogosPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModoButton({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    required IconData icon,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),

      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: cor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),

              child: Icon(icon, color: cor, size: 38),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo,

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitulo,

                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
