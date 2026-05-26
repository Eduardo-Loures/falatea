import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

class EscolherPictogramaGame extends StatefulWidget {
  const EscolherPictogramaGame({super.key});

  @override
  State<EscolherPictogramaGame> createState() => _EscolherPictogramaGameState();
}

class _EscolherPictogramaGameState extends State<EscolherPictogramaGame>
    with SingleTickerProviderStateMixin {
  // FASES
  late List<Map<String, dynamic>> fasesEmbaralhadas;

  final List<Map<String, dynamic>> fases = [
    {'imagemReal': 'assets/imagens_reais/maca_real.jpg', 'resposta': 'MAÇÃ'},

    {'imagemReal': 'assets/imagens_reais/agua_real.jpg', 'resposta': 'ÁGUA'},

    {'imagemReal': 'assets/imagens_reais/bola_real.jpg', 'resposta': 'BOLA'},

    {'imagemReal': 'assets/imagens_reais/leite_real.png', 'resposta': 'LEITE'},

    {'imagemReal': 'assets/imagens_reais/carro_real.jpg', 'resposta': 'CARRO'},

    {'imagemReal': 'assets/imagens_reais/pao_real.jpg', 'resposta': 'PÃO'},

    {'imagemReal': 'assets/imagens_reais/suco_real.jpg', 'resposta': 'SUCO'},

    {'imagemReal': 'assets/imagens_reais/cama_real.jpg', 'resposta': 'CAMA'},

    {
      'imagemReal': 'assets/imagens_reais/caneta_real.jpg',
      'resposta': 'CANETA',
    },
  ];

  // PICTOGRAMAS
  final List<Map<String, String>> pictogramas = [
    {'texto': 'MAÇÃ', 'imagem': 'assets/imagens/maca.png'},

    {'texto': 'ÁGUA', 'imagem': 'assets/imagens/agua.png'},

    {'texto': 'BOLA', 'imagem': 'assets/imagens/bola.png'},

    {'texto': 'LEITE', 'imagem': 'assets/imagens/leite.png'},

    {'texto': 'CARRO', 'imagem': 'assets/imagens/carro.png'},

    {'texto': 'PÃO', 'imagem': 'assets/imagens/pao.png'},

    {'texto': 'SUCO', 'imagem': 'assets/imagens/suco.png'},

    {'texto': 'CAMA', 'imagem': 'assets/imagens/cama.png'},

    {'texto': 'CANETA', 'imagem': 'assets/imagens/caneta.png'},
  ];

  int faseAtual = 0;
  int estrelas = 0;

  bool ajudaAtivada = false;

  late AnimationController _controller;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();

    fasesEmbaralhadas = List.from(fases);

    fasesEmbaralhadas.shuffle(Random());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    falarPalavraAtual();
  }

  Future<void> falarPalavraAtual() async {
    final palavra = fasesEmbaralhadas[faseAtual]['resposta'];

    await flutterTts.setLanguage('pt-BR');

    await flutterTts.setSpeechRate(0.45);

    await flutterTts.speak(palavra);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void selecionarResposta(String resposta) {
    final respostaCorreta = fasesEmbaralhadas[faseAtual]['resposta'];

    if (resposta == respostaCorreta) {
      setState(() {
        estrelas++;
      });

      mostrarResultado(true);
    } else {
      mostrarResultado(false);
    }
  }

  void proximaFase() {
    setState(() {
      if (faseAtual < fasesEmbaralhadas.length - 1) {
        faseAtual++;
      } else {
        faseAtual = 0;

        fasesEmbaralhadas.shuffle(Random());
      }
    });

    falarPalavraAtual();
  }

  void mostrarResultado(bool acertou) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            acertou ? 'Muito bem! ⭐' : 'Ops 😅',
            textAlign: TextAlign.center,
          ),

          content: Text(
            acertou ? 'Você acertou' : 'Tente novamente.',
            textAlign: TextAlign.center,
          ),

          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),

                onPressed: () {
                  Navigator.pop(context);

                  if (acertou) {
                    proximaFase();
                  }
                },

                child: const Text('Continuar'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final respostaCorreta = fasesEmbaralhadas[faseAtual]['resposta'];

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

        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 6),

            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),

                const SizedBox(width: 4),

                Text(
                  '$estrelas',

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[700], size: 28),

              Switch(
                value: ajudaAtivada,
                activeColor: Colors.amber,
                onChanged: (value) {
                  setState(() {
                    ajudaAtivada = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),

        child: Column(
          children: [
            const SizedBox(height: 10),

            // IMAGEM REAL
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),

              child: Column(
                children: [
                  const Text(
                    'Escolha o correto:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 150,

                    child: Image.asset(
                      fasesEmbaralhadas[faseAtual]['imagemReal'],
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,

                        foregroundColor: Colors.white,

                        padding: const EdgeInsets.symmetric(vertical: 10),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: falarPalavraAtual,

                      icon: const Icon(Icons.volume_up_rounded, size: 22),

                      label: const Text(
                        'Ouvir Palavra',

                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // PICTOGRAMAS
            Expanded(
              child: GridView.builder(
                itemCount: pictogramas.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,

                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,

                  childAspectRatio: 0.9,
                ),

                itemBuilder: (context, index) {
                  final pictograma = pictogramas[index];

                  final bool ehCorreto = pictograma['texto'] == respostaCorreta;

                  return AnimatedBuilder(
                    animation: _controller,

                    builder: (context, child) {
                      final brilho = ajudaAtivada && ehCorreto;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),

                          boxShadow:
                              brilho
                                  ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(
                                        0.2 + (_controller.value * 0.4),
                                      ),
                                      blurRadius: 10 + (_controller.value * 18),
                                      spreadRadius: 1 + (_controller.value * 4),
                                    ),
                                  ]
                                  : [],
                        ),

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,

                            foregroundColor: Colors.black,

                            elevation: 3,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          onPressed: () {
                            selecionarResposta(pictograma['texto']!);
                          },

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              SizedBox(
                                height: 70,

                                child: Image.asset(
                                  pictograma['imagem']!,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                pictograma['texto']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
