import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto/services/tts_service.dart';
import 'package:projeto/widgets/avisos.dart';

class CoresGame extends StatefulWidget {
  const CoresGame({super.key});

  @override
  State<CoresGame> createState() => _CoresGameState();
}

class _CoresGameState extends State<CoresGame>
    with SingleTickerProviderStateMixin {
  late final TtsService tts;

  final Random random = Random();

  late AnimationController _controller;

  bool ajudaAtivada = false;

  int estrelas = 0;

  int faseAtual = 0;

  // CORES
  final List<Map<String, dynamic>> cores = [
    {'nome': 'VERMELHO', 'cor': Colors.red},

    {'nome': 'AZUL', 'cor': Colors.blue},

    {'nome': 'AMARELO', 'cor': Colors.yellow},

    {'nome': 'VERDE', 'cor': Colors.green},

    {'nome': 'LARANJA', 'cor': Colors.orange},

    {'nome': 'ROXO', 'cor': Colors.purple},

    {'nome': 'ROSA', 'cor': Colors.pink[200]},

    {'nome': 'MARROM', 'cor': Colors.brown},

    {'nome': 'PRETO', 'cor': Colors.black},
  ];

  late List<Map<String, dynamic>> fasesEmbaralhadas;

  late List<String> opcoes;

  @override
  void initState() {
    super.initState();

    tts = context.read<TtsService>();

    fasesEmbaralhadas = List.from(cores);

    fasesEmbaralhadas.shuffle(random);

    opcoes = sortearOpcoes();

    _controller = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  // Resposta certa + 3 cores aleatórias
  List<String> sortearOpcoes() {
    final respostaCorreta = fasesEmbaralhadas[faseAtual]['nome'] as String;

    final outras =
        cores
            .map((c) => c['nome'] as String)
            .where((nome) => nome != respostaCorreta)
            .toList()
          ..shuffle(random);

    return [respostaCorreta, ...outras.take(3)]..shuffle(random);
  }

  Future<void> falarCorAtual() async {
    final String cor = fasesEmbaralhadas[faseAtual]['nome'];

    await tts.falar(cor.toLowerCase());
  }

  void selecionarResposta(String respostaSelecionada) {
    final respostaCorreta = fasesEmbaralhadas[faseAtual]['nome'];

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

        fasesEmbaralhadas.shuffle(random);
      }

      opcoes = sortearOpcoes();
    });
  }

  Future<void> mostrarResultado(bool acertou) async {
    await mostrarResultadoJogo(context, acertou: acertou);

    if (acertou) proximaFase();
  }

  @override
  void dispose() {
    _controller.dispose();

    tts.parar();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final respostaCorreta = fasesEmbaralhadas[faseAtual]['nome'];

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        centerTitle: true,

        foregroundColor: Colors.white,

        title: const Text(
          'Cores',

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

                activeThumbColor: Colors.amber,

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
                      'Que cor é essa?',

                      style: TextStyle(
                        fontSize: 24,

                        fontWeight: FontWeight.bold,

                        color: Colors.indigo[700],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // COR DA FASE
                    Container(
                      height: 150,

                      width: 150,

                      decoration: BoxDecoration(
                        color: fasesEmbaralhadas[faseAtual]['cor'],

                        shape: BoxShape.circle,

                        border: Border.all(color: Colors.black12, width: 3),

                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

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

                        onPressed: falarCorAtual,

                        icon: const Icon(Icons.volume_up_rounded, size: 22),

                        label: const Text(
                          'Ouvir Cor',

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

            // NOMES DAS CORES
            Expanded(
              child: GridView.builder(
                itemCount: opcoes.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,

                  crossAxisSpacing: 12,

                  mainAxisSpacing: 12,

                  childAspectRatio: 1.6,
                ),

                itemBuilder: (context, index) {
                  final opcao = opcoes[index];

                  final bool ehCorreto = opcao == respostaCorreta;

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
                                      color: Colors.green.withValues(
                                        alpha: 0.2 + (_controller.value * 0.4),
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
                            selecionarResposta(opcao);
                          },

                          child: FittedBox(
                            fit: BoxFit.scaleDown,

                            child: Text(
                              opcao,

                              textAlign: TextAlign.center,

                              style: const TextStyle(
                                fontSize: 22,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
