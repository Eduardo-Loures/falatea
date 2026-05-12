import 'package:flutter/material.dart';

import 'package:projeto/pages/home_page.dart';
import 'package:projeto/games/montar_frase_game.dart';

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
                Container(

                  padding: const EdgeInsets.all(22),

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

                const SizedBox(height: 30),

                const Text(

                  'FalaTEA',

                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(

                  'Escolha um modo',

                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 60),

                // BOTÃO AAC
                _buildModoButton(

                  context: context,

                  titulo: 'Comunicação',

                  subtitulo:
                  'Utilize os botões AAC para comunicação.',

                  icon: Icons.record_voice_over_rounded,

                  cor: Colors.blue,

                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomePage(),
                      ),
                    );

                  },
                ),

                const SizedBox(height: 25),

                // BOTÃO GAME
                _buildModoButton(

                  context: context,

                  titulo: 'Aprender Jogando',

                  subtitulo:
                  'Aprenda formando frases e jogando.',

                  icon: Icons.psychology_rounded,

                  cor: Colors.green,

                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const MontarFraseGame(),
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

          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),

        child: Row(

          children: [

            Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: cor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: cor,
                size: 38,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

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

                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }
}