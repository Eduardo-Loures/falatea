import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto/services/tts_service.dart';
import 'package:projeto/widgets/avisos.dart';

class RotinaGame extends StatefulWidget {
  const RotinaGame({super.key});

  @override
  State<RotinaGame> createState() => _RotinaGameState();
}

class _RotinaGameState extends State<RotinaGame>
    with SingleTickerProviderStateMixin {
  late final TtsService tts;

  final Random random = Random();

  late AnimationController _controller;

  bool ajudaAtivada = false;

  int estrelas = 0;

  int faseAtual = 0;

  // ROTINAS (passos na ordem certa)
  final List<Map<String, dynamic>> rotinas = [
    {
      'nome': 'Escovar os dentes',
      'passos': [
        {'texto': 'Pegar a escova', 'imagem': 'escova'},
        {'texto': 'Pôr a pasta', 'imagem': 'pasta'},
        {'texto': 'Escovar', 'imagem': 'escovar_dentes'},
        {'texto': 'Enxaguar a boca', 'imagem': 'enxaguar'},
      ],
    },

    {
      'nome': 'Ir ao banheiro',
      'passos': [
        {'texto': 'Usar o vaso', 'imagem': 'vaso'},
        {'texto': 'Dar descarga', 'imagem': 'descarga'},
        {'texto': 'Lavar as mãos', 'imagem': 'lavar_maos'},
      ],
    },

    {
      'nome': 'Hora de comer',
      'passos': [
        {'texto': 'Lavar as mãos', 'imagem': 'lavar_maos'},
        {'texto': 'Sentar à mesa', 'imagem': 'sentar_mesa'},
        {'texto': 'Comer', 'imagem': 'comer'},
      ],
    },

    {
      'nome': 'Tomar banho',
      'passos': [
        {'texto': 'Tirar a roupa', 'imagem': 'tirar_roupa'},
        {'texto': 'Tomar banho', 'imagem': 'tomar_banho'},
        {'texto': 'Secar com a toalha', 'imagem': 'secar'},
        {'texto': 'Vestir a roupa', 'imagem': 'vestir'},
      ],
    },

    {
      'nome': 'Hora de dormir',
      'passos': [
        {'texto': 'Vestir o pijama', 'imagem': 'pijama'},
        {'texto': 'Escovar os dentes', 'imagem': 'escovar_dentes'},
        {'texto': 'Deitar na cama', 'imagem': 'deitar'},
        {'texto': 'Dormir', 'imagem': 'dormir'},
      ],
    },
  ];

  late List<Map<String, dynamic>> rotinasEmbaralhadas;

  // Cartões ainda não colocados, fora de ordem
  late List<Map<String, String>> cartoes;

  // Passos já colocados na ordem certa
  final List<Map<String, String>> colocados = [];

  @override
  void initState() {
    super.initState();

    tts = context.read<TtsService>();

    rotinasEmbaralhadas = List.from(rotinas);

    rotinasEmbaralhadas.shuffle(random);

    cartoes = embaralharPassos();

    _controller = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  List<Map<String, String>> get passosAtuais =>
      List<Map<String, String>>.from(rotinasEmbaralhadas[faseAtual]['passos']);

  String imagemDoPasso(Map<String, String> passo) =>
      'assets/jogos/rotina/${passo['imagem']}.png';

  // Embaralha sem deixar os cartões já na ordem certa
  List<Map<String, String>> embaralharPassos() {
    final passos = passosAtuais;

    final embaralhados = List<Map<String, String>>.from(passos);

    do {
      embaralhados.shuffle(random);
    } while (_mesmaOrdem(embaralhados, passos));

    return embaralhados;
  }

  bool _mesmaOrdem(List<Map<String, String>> a, List<Map<String, String>> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i]['imagem'] != b[i]['imagem']) return false;
    }
    return true;
  }

  Future<void> falar(String texto) async {
    await tts.falar(texto);
  }

  void selecionarCartao(Map<String, String> cartao) {
    final proximo = passosAtuais[colocados.length];

    if (cartao['imagem'] != proximo['imagem']) {
      falar('Não é esse');

      mostrarResultadoJogo(
        context,
        acertou: false,
        mensagem: 'Esse não é o próximo passo.',
      );
      return;
    }

    setState(() {
      colocados.add(cartao);

      cartoes.remove(cartao);
    });

    falar(cartao['texto']!);

    if (colocados.length == passosAtuais.length) {
      setState(() {
        estrelas++;
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) mostrarResultado();
      });
    }
  }

  void proximaFase() {
    setState(() {
      if (faseAtual < rotinasEmbaralhadas.length - 1) {
        faseAtual++;
      } else {
        faseAtual = 0;

        rotinasEmbaralhadas.shuffle(random);
      }

      colocados.clear();

      cartoes = embaralharPassos();
    });
  }

  Future<void> mostrarResultado() async {
    await mostrarResultadoJogo(
      context,
      acertou: true,
      mensagem: 'Você completou a rotina!',
    );

    proximaFase();
  }

  @override
  void dispose() {
    _controller.dispose();

    tts.parar();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String nomeRotina = rotinasEmbaralhadas[faseAtual]['nome'];

    final passos = passosAtuais;

    final proximo =
        colocados.length < passos.length ? passos[colocados.length] : null;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        centerTitle: true,

        foregroundColor: Colors.white,

        title: const Text(
          'Minha Rotina',

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
                      nomeRotina,

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 24,

                        fontWeight: FontWeight.bold,

                        color: Colors.indigo[700],
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Coloque os passos na ordem',

                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),

                    const SizedBox(height: 12),

                    // ESPAÇOS NUMERADOS
                    Row(
                      children: [
                        for (int i = 0; i < passos.length; i++)
                          Expanded(child: _buildEspaco(i)),
                      ],
                    ),

                    const SizedBox(height: 12),

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

                        onPressed: () => falar(nomeRotina),

                        icon: const Icon(Icons.volume_up_rounded, size: 22),

                        label: const Text(
                          'Ouvir Rotina',

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

            // CARTÕES FORA DE ORDEM
            Expanded(
              child: GridView.builder(
                itemCount: cartoes.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,

                  crossAxisSpacing: 12,

                  mainAxisSpacing: 12,

                  childAspectRatio: 1,
                ),

                itemBuilder: (context, index) {
                  final cartao = cartoes[index];

                  final bool ehProximo =
                      proximo != null && cartao['imagem'] == proximo['imagem'];

                  return AnimatedBuilder(
                    animation: _controller,

                    builder: (context, child) {
                      final brilho = ajudaAtivada && ehProximo;

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

                            padding: const EdgeInsets.all(8),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          onPressed: () => selecionarCartao(cartao),

                          child: Column(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  imagemDoPasso(cartao),

                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(height: 6),

                              FittedBox(
                                fit: BoxFit.scaleDown,

                                child: Text(
                                  cartao['texto']!,

                                  textAlign: TextAlign.center,

                                  style: const TextStyle(
                                    fontSize: 16,

                                    fontWeight: FontWeight.bold,
                                  ),
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

  Widget _buildEspaco(int index) {
    final bool preenchido = index < colocados.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),

      child: AspectRatio(
        aspectRatio: 1,

        child: Container(
          decoration: BoxDecoration(
            color: preenchido ? Colors.white : Colors.indigo[50],

            borderRadius: BorderRadius.circular(14),

            border: Border.all(
              color: preenchido ? Colors.green : Colors.indigo[200]!,

              width: 2,
            ),
          ),

          child:
              preenchido
                  ? Padding(
                    padding: const EdgeInsets.all(4),

                    child: Image.asset(
                      imagemDoPasso(colocados[index]),

                      fit: BoxFit.contain,
                    ),
                  )
                  : Center(
                    child: Text(
                      '${index + 1}',

                      style: TextStyle(
                        fontSize: 26,

                        fontWeight: FontWeight.bold,

                        color: Colors.indigo[300],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
