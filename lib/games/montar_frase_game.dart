import 'package:flutter/material.dart';

class MontarFraseGame extends StatefulWidget {
  const MontarFraseGame({super.key});

  @override
  State<MontarFraseGame> createState() => _MontarFraseGameState();
}

class _MontarFraseGameState extends State<MontarFraseGame> {

  final List<Map<String, dynamic>> fases = [

    {
      'imagem': 'assets/imagens/maca.png',

      'frase': [
        'EU',
        'QUERO',
        'MAÇÃ',
      ],
    },

    {
      'imagem': 'assets/imagens/agua.png',

      'frase': [
        'EU',
        'QUERO',
        'ÁGUA',
      ],
    },

    {
      'imagem': 'assets/imagens/bola.png',

      'frase': [
        'EU',
        'QUERO',
        'BOLA',
      ],
    },

  ];

  int faseAtual = 0;

  final List<Map<String, String>> palavras = [
    {
      'texto': 'EU',
      'imagem': 'assets/imagens/eu.png',
    },

    {
      'texto': 'QUERO',
      'imagem': 'assets/imagens/quero.png',
    },

    {
      'texto': 'MAÇÃ',
      'imagem': 'assets/imagens/maca.png',
    },

    {
      'texto': 'ÁGUA',
      'imagem': 'assets/imagens/agua.png',
    },

    {
      'texto': 'CARRO',
      'imagem': 'assets/imagens/carro.png',
    },

    {
      'texto': 'BOLA',
      'imagem': 'assets/imagens/bola.png',
    },
  ];

  List<String> respostaUsuario = [];

  int estrelas = 0;

  void adicionarPalavra(String palavra) {
    setState(() {
      respostaUsuario.add(palavra);
    });
  }

  void removerUltima() {
    if (respostaUsuario.isNotEmpty) {
      setState(() {
        respostaUsuario.removeLast();
      });
    }
  }

  void limparFrase() {
    setState(() {
      respostaUsuario.clear();
    });
  }

  void verificarResposta() {

    if (respostaUsuario.join(' ') ==
        fases[faseAtual]['frase'].join(' ')) {

      setState(() {
        estrelas++;

        if (faseAtual < fases.length - 1) {

          faseAtual++;

        } else {

          faseAtual = 0;

        }
      });

      mostrarResultado(true);

    } else {

      mostrarResultado(false);

    }
  }

  void mostrarResultado(bool acertou) {

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            acertou
                ? 'Muito bem! ⭐'
                : 'Ops 😅',
            textAlign: TextAlign.center,
          ),
          content: Text(
            acertou
                ? 'Você montou a frase corretamente!'
                : 'Tente novamente.',
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

                  setState(() {
                    respostaUsuario.clear();
                  });

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

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(

        centerTitle: true,

        foregroundColor: Colors.white,

        title: const Text(
          'Montar Frases',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo[800]!,
                Colors.indigo[600]!,
              ],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            // ESTRELAS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 30,
                ),

                const SizedBox(width: 8),

                Text(
                  '$estrelas',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // FRASE OBJETIVO
            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  ),
                ],
              ),

              child: Column(
                children: [

                  const Text(
                    'Monte a frase:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(

                    height: 120,

                    child: Image.asset(
                      fases[faseAtual]['imagem'],
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FRASE DO USUARIO
            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),

                border: Border.all(
                  color: Colors.indigo,
                  width: 2,
                ),
              ),

              child: Text(

                respostaUsuario.isEmpty
                    ? 'Sua frase aparecerá aqui'
                    : respostaUsuario.join(' '),

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: respostaUsuario.isEmpty
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÕES
            Expanded(

              child: GridView.builder(

                itemCount: palavras.length,

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount: 3,

                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,

                  childAspectRatio: 0.9,
                ),

                itemBuilder: (context, index) {

                  final palavra = palavras[index];

                  return ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.white,

                      foregroundColor: Colors.black,

                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    onPressed: () =>
                        adicionarPalavra(
                          palavra['texto']!,
                        ),

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        SizedBox(

                          height: 70,

                          child: Image.asset(
                            palavra['imagem']!,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          palavra['texto']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // BOTÕES INFERIORES
            Row(

              children: [

                Expanded(
                  child: ElevatedButton.icon(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.orange,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: removerUltima,

                    icon: const Icon(Icons.backspace),

                    label: const Text(
                      'Apagar',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.red,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: limparFrase,

                    icon: const Icon(Icons.delete),

                    label: const Text(
                      'Limpar',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // VERIFICAR
            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.green,

                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: verificarResposta,

                icon: const Icon(Icons.check_circle),

                label: const Text(
                  'Verificar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}