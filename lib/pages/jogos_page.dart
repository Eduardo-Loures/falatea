import 'package:flutter/material.dart';
import 'package:projeto/games/escolher_game.dart';
import 'package:projeto/games/emocoes_game.dart';

class JogosPage extends StatelessWidget {
  const JogosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        centerTitle: true,

        foregroundColor: Colors.white,

        title: const Text(
          'Jogos',

          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo[800]!, Colors.indigo[600]!],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // JOGO 1
            _buildJogoCard(
              context: context,

              titulo: 'Qual é?',

              descricao: 'Associe imagens reais aos pictogramas.',

              imagem: 'assets/jogos/escolher.png',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => const EscolherPictogramaGame(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // JOGO 2
            _buildJogoCard(
              context: context,

              titulo: 'Emoções',

              descricao: 'Aprenda a reconhecer emoções.',

              imagem: 'assets/jogos/emocoes.png',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const EmocoesGame()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJogoCard({
    required BuildContext context,
    required String titulo,
    required String descricao,
    required VoidCallback onTap,
    required String imagem,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),

      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(22),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),

        child: Row(
          children: [
            SizedBox(
              height: 90,
              width: 90,

              child: Image.asset(imagem, fit: BoxFit.contain),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo,

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    descricao,

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
