import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EmocoesGame extends StatefulWidget {
  const EmocoesGame({super.key});

  @override
  State<EmocoesGame> createState() => _EmocoesGameState();
}

class _EmocoesGameState extends State<EmocoesGame>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();

  late AnimationController _controller;

  bool ajudaAtivada = false;

  int estrelas = 0;

  int faseAtual = 0;

  final List<Map<String, dynamic>> fases = [
    {'imagem': 'assets/jogos/emocoes/feliz_real.png', 'resposta': 'FELIZ'},

    {'imagem': 'assets/jogos/emocoes/triste_real.png', 'resposta': 'TRISTE'},

    {'imagem': 'assets/jogos/emocoes/bravo_real.png', 'resposta': 'BRAVO'},

    {'imagem': 'assets/jogos/emocoes/cansado_real.png', 'resposta': 'CANSADO'},
  ];

  final List<Map<String, String>> opcoes = [
    {'texto': 'FELIZ', 'imagem': 'assets/jogos/emocoes/feliz.png'},

    {'texto': 'TRISTE', 'imagem': 'assets/jogos/emocoes/triste.png'},

    {'texto': 'BRAVO', 'imagem': 'assets/jogos/emocoes/bravo.png'},

    {'texto': 'CANSADO', 'imagem': 'assets/jogos/emocoes/cansado.png'},
  ];

  late List<Map<String, dynamic>> fasesEmbaralhadas;

  @override
  void initState() {
    super.initState();

    fasesEmbaralhadas = List.from(fases);

    fasesEmbaralhadas.shuffle(Random());

    _controller = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    falarEmocaoAtual();
  }

  Future<void> falarEmocaoAtual() async {
    final emocao = fasesEmbaralhadas[faseAtual]['resposta'];

    await flutterTts.setLanguage('pt-BR');

    await flutterTts.setSpeechRate(0.45);

    await flutterTts.speak(emocao);
  }

  void selecionarResposta(String respostaSelecionada) {
    final respostaCorreta = fasesEmbaralhadas[faseAtual]['resposta'];

    if (respostaSelecionada == respostaCorreta) {
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

    falarEmocaoAtual();
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
  void dispose() {
    _controller.dispose();

    flutterTts.stop();

    super.dispose();
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
          'Emoções',

          style: TextStyle(fontWeight: FontWeight.bold),
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
            Card(
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),

              child: Padding(
                padding: const EdgeInsets.all(14),

                child: Column(
                  children: [
                    Text(
                      'Como essa pessoa está?',

                      style: TextStyle(
                        fontSize: 24,

                        fontWeight: FontWeight.bold,

                        color: Colors.indigo[700],
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 170,

                      child: Image.asset(
                        fasesEmbaralhadas[faseAtual]['imagem'],

                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 10),

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

                        onPressed: falarEmocaoAtual,

                        icon: const Icon(Icons.volume_up_rounded, size: 22),

                        label: const Text(
                          'Ouvir Emoção',

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
            ),

            const SizedBox(height: 12),

            Expanded(
              child: GridView.builder(
                itemCount: opcoes.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,

                  crossAxisSpacing: 12,

                  mainAxisSpacing: 12,

                  childAspectRatio: 1,
                ),

                itemBuilder: (context, index) {
                  final opcao = opcoes[index];

                  final bool ehCorreto = opcao['texto'] == respostaCorreta;

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
                            selecionarResposta(opcao['texto']!);
                          },

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              SizedBox(
                                height: 130,

                                child: Image.asset(
                                  opcao['imagem']!,

                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                opcao['texto']!,

                                textAlign: TextAlign.center,

                                style: const TextStyle(
                                  fontSize: 16,

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
