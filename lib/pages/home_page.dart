import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto/models/botao_aac_model.dart';
import 'package:projeto/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

/// Tela principal que gerencia as categorias e botões de comunicação
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // VARIÁVEIS DE ESTADO E CONTROLADORES
  final FlutterTts tts = FlutterTts();
  late TabController tabController;
  Orientation? _currentOrientation;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};
  String _textoFalado = '';

  // DADOS DAS CATEGORIAS E BOTÕES PREDEFINIDOS
  final Map<String, List<BotaoAAC>> categorias = {
    'Ações': [
      BotaoAAC('quero', null, Colors.orange, isFixo: true, imagePath: 'assets/imagens/quero.png'),
      BotaoAAC('comer', null, Colors.orange, isFixo: true, imagePath: 'assets/imagens/comer.png'),
      BotaoAAC('beber', null, Colors.orange, isFixo: true, imagePath: 'assets/imagens/beber.png'),
      BotaoAAC('dormir', null, Colors.orange, isFixo: true, imagePath: 'assets/imagens/dormir.png'),
      BotaoAAC('ir', null, Colors.orange, isFixo: true, imagePath: 'assets/imagens/ir.png'),
    ],
    'Pessoas': [
      BotaoAAC('Eu', null, Colors.blue, isFixo: true, imagePath: 'assets/imagens/eu.png'),
      BotaoAAC('você', null, Colors.blue, isFixo: true, imagePath: 'assets/imagens/voce.png'),
      BotaoAAC('mamãe', null, Colors.blue, isFixo: true, imagePath: 'assets/imagens/mamae.png'),
      BotaoAAC('papai', null, Colors.blue, isFixo: true, imagePath: 'assets/imagens/papai.png'),
    ],
    'Objetos': [
      BotaoAAC('água', null, Colors.teal, isFixo: true, imagePath: 'assets/imagens/agua.png'),
      BotaoAAC('leite', null, Colors.teal, isFixo: true, imagePath: 'assets/imagens/leite.png'),
      BotaoAAC('brinquedo', null, Colors.teal, isFixo: true, imagePath: 'assets/imagens/brinquedo.png'),
      BotaoAAC('bola', null, Colors.teal, isFixo: true, imagePath: 'assets/imagens/bola.png'),
    ],
    'Emoções': [
      BotaoAAC('feliz', null, Colors.lightGreen, isFixo: true, imagePath: 'assets/imagens/feliz.png'),
      BotaoAAC('triste', null, Colors.lightGreen, isFixo: true, imagePath: 'assets/imagens/triste.png'),
      BotaoAAC('nervoso', null, Colors.lightGreen, isFixo: true, imagePath: 'assets/imagens/nervoso.png'),
      BotaoAAC('ansioso', null, Colors.lightGreen, isFixo: true, imagePath: 'assets/imagens/ansioso.png'),
    ],
    'Negação': [
      BotaoAAC('não', null, Colors.red, isFixo: true, imagePath: 'assets/imagens/nao.png'),
      BotaoAAC('pare', null, Colors.red, isFixo: true, imagePath: 'assets/imagens/pare.png'),
      BotaoAAC('acabou', null, Colors.red, isFixo: true, imagePath: 'assets/imagens/acabou.png'),
    ],
  };

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: categorias.length, vsync: this);
    _inicializarTTS();
    _carregarConfigsSalvas();

    for (String categoria in categorias.keys) {
      _categoryKeys[categoria] = GlobalKey();
    }

    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        _scrollToCategory(tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureOrientationListener();
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    _scrollController.dispose();
    tts.stop();
    super.dispose();
  }

  // CONFIGURAÇÃO DO SINTETIZADOR DE VOZ
  Future<void> _inicializarTTS() async {
    await tts.setLanguage('pt-BR');
    await tts.setSpeechRate(0.5);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
  }

  // PERSISTÊNCIA DE DADOS
  Future<void> _salvarBotoesPersonalizados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, List<Map<String, dynamic>>> botoesPersonalizados = {};

      categorias.forEach((categoria, botoes) {
        List<BotaoAAC> botoesNaoFixos = botoes.where((botao) => !botao.isFixo).toList();
        if (botoesNaoFixos.isNotEmpty) {
          botoesPersonalizados[categoria] = botoesNaoFixos.map((botao) => botao.toJson()).toList();
        }
      });

      String jsonString = json.encode(botoesPersonalizados);
      await prefs.setString('botoes_personalizados', jsonString);
      print('Botões personalizados salvos com sucesso!');
    } catch (e) {
      print('Erro ao salvar botões personalizados: $e');
    }
  }

  Future<void> _carregarConfigsSalvas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('botoes_personalizados');

      if (jsonString != null && jsonString.isNotEmpty) {
        Map<String, dynamic> dadosSalvos = json.decode(jsonString);

        dadosSalvos.forEach((categoria, botoesList) {
          if (categorias.containsKey(categoria)) {
            List<BotaoAAC> botoesPersonalizados =
            (botoesList as List).map((botaoJson) => BotaoAAC.fromJson(botaoJson)).toList();
            categorias[categoria]!.addAll(botoesPersonalizados);
          }
        });

        if (mounted) setState(() {});
        print('Botões personalizados carregados com sucesso!');
      }
    } catch (e) {
      print('Erro ao carregar botões personalizados: $e');
    }
  }

  Future<void> _limparDadosSalvos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('botoes_personalizados');
    print('Dados salvos limpos!');
  }

  // NAVEGAÇÃO E SCROLL
  void _scrollToCategory(int index) {
    String categoria = categorias.keys.elementAt(index);
    final key = _categoryKeys[categoria];

    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _configureOrientationListener() {
    // Implementação futura
  }

  // MANIPULAÇÃO DE FALA
  void falarPalavra(String palavra) {
    setState(() {
      _textoFalado = palavra;
    });
    tts.speak(palavra);
  }

  void _limparTexto() {
    setState(() {
      _textoFalado = '';
    });
  }

  // GERENCIAMENTO DE BOTÕES PERSONALIZADOS
  void _mostrarDialogoExcluirBotao(BotaoAAC botao) {
    if (botao.isFixo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este botão não pode ser excluído.')),
      );
      return;
    }

    String? categoriaEncontrada;
    categorias.forEach((categoria, lista) {
      if (lista.contains(botao)) {
        categoriaEncontrada = categoria;
      }
    });

    if (categoriaEncontrada == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir botão'),
          content: Text('Deseja excluir o botão "${botao.label}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  categorias[categoriaEncontrada!]!.remove(botao);
                });
                await _salvarBotoesPersonalizados();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botão excluído com sucesso!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void mostrarDialogoAdicionarBotao() {
    final labelController = TextEditingController();
    final orientation = MediaQuery.of(context).orientation;

    IconData iconSelecionado = Icons.star;
    Color corSelecionada = Colors.orange;
    String categoriaSelecionada = categorias.keys.first;
    String? imagemSelecionada;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Criar novo botão'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width * 0.8
                      : MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: labelController,
                        decoration: const InputDecoration(
                          labelText: 'Texto do botão',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Selecione uma categoria:'),
                      DropdownButton<String>(
                        value: categoriaSelecionada,
                        isExpanded: true,
                        items: categorias.keys
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (String? valor) {
                          setDialogState(() {
                            categoriaSelecionada = valor ?? categorias.keys.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Escolha uma imagem (opcional):'),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setDialogState(() {
                              imagemSelecionada = picked.path;
                            });
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text("Escolher imagem"),
                      ),
                      if (imagemSelecionada != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Image.file(File(imagemSelecionada!), height: 80),
                        ),
                      const Text('Selecione um ícone:'),
                      DropdownButton<IconData>(
                        value: iconSelecionado,
                        items: [
                          Icons.star, Icons.favorite, Icons.face, Icons.cake,
                          Icons.home, Icons.pets, Icons.school, Icons.accessibility,
                          Icons.bathroom, Icons.directions_car, Icons.music_note, Icons.smartphone,
                        ].map((icon) => DropdownMenuItem(value: icon, child: Icon(icon))).toList(),
                        onChanged: (IconData? valor) {
                          setDialogState(() {
                            iconSelecionado = valor ?? Icons.star;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Selecione uma cor:'),
                      DropdownButton<Color>(
                        value: corSelecionada,
                        items: [
                          Colors.orange, Colors.blue, Colors.teal, Colors.lightGreen,
                          Colors.red, Colors.amber, Colors.pink, Colors.cyan, Colors.lime,
                        ].map((color) => DropdownMenuItem(
                          value: color,
                          child: Container(width: 50, height: 20, color: color),
                        )).toList(),
                        onChanged: (Color? valor) {
                          setDialogState(() {
                            corSelecionada = valor ?? Colors.orange;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (labelController.text.isNotEmpty) {
                      setState(() {
                        categorias[categoriaSelecionada]!.add(
                          BotaoAAC(
                            labelController.text,
                            imagemSelecionada == null ? iconSelecionado : null,
                            corSelecionada,
                            imagePath: imagemSelecionada,
                          ),
                        );
                      });
                      await _salvarBotoesPersonalizados();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Botão criado com sucesso!')),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Adicionar'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _currentOrientation = MediaQuery.of(context).orientation;
    int crossAxisCount = _currentOrientation == Orientation.portrait ? 3 : 5;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'FalaTEA',
          style: TextStyle(
            fontFamily: 'WDXLLubrifontTC-Regular',
            fontSize: _currentOrientation == Orientation.portrait ? 30 : 20,
          ),
        ),
        elevation: 2.0,
        toolbarHeight: _currentOrientation == Orientation.portrait ? 56 : 36,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'limpar_dados') {
                bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpar Dados'),
                    content: const Text('Isso removerá todos os botões personalizados. Deseja continuar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Limpar'),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  await _limparDadosSalvos();
                  setState(() {
                    categorias.forEach((categoria, botoes) {
                      botoes.removeWhere((botao) => !botao.isFixo);
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dados limpos com sucesso!')),
                  );
                }
              } else if (value == 'logout') {
                bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sair'),
                    content: const Text('Deseja realmente sair da sua conta?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  try {
                    await context.read<AuthService>().logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout realizado com sucesso!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao fazer logout: $e')),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'limpar_dados',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpar Dados'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_currentOrientation == Orientation.portrait ? 40 : 28),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              tabs: categorias.keys.map((cat) => Tab(text: cat)).toList(),
              indicatorColor: Colors.white,
              labelPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              tabAlignment: TabAlignment.start,
            ),
          ),
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white60,
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _textoFalado.isEmpty ? 'Clique em um botão para falar...' : _textoFalado,
                        style: TextStyle(
                          fontSize: orientation == Orientation.portrait ? 18 : 16,
                          fontWeight: FontWeight.w500,
                          color: _textoFalado.isEmpty ? Colors.grey[600] : Colors.black87,
                        ),
                      ),
                    ),
                    if (_textoFalado.isNotEmpty)
                      IconButton(
                        onPressed: _limparTexto,
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        tooltip: 'Limpar texto',
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    for (var categoria in categorias.keys)
                      Column(
                        key: _categoryKeys[categoria],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              12.0,
                              categoria == categorias.keys.first ? 8 : 0,
                              12.0,
                              8,
                            ),
                            child: Text(
                              categoria,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GridView.count(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: orientation == Orientation.portrait ? 10 : 6,
                              crossAxisSpacing: orientation == Orientation.portrait ? 10 : 6,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: orientation == Orientation.portrait ? 1.0 : 1.3,
                              children: categorias[categoria]!
                                  .map((btn) => _buildBotaoComunicacao(btn, orientation))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 0),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarDialogoAdicionarBotao,
        tooltip: 'Adicionar novo botão',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBotaoComunicacao(BotaoAAC btn, Orientation orientation) {
    double iconSize = orientation == Orientation.portrait ? 36 : 28;
    double fontSize = orientation == Orientation.portrait ? 18 : 16;

    return GestureDetector(
      onLongPress: () => _mostrarDialogoExcluirBotao(btn),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: btn.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(orientation == Orientation.portrait ? 8 : 6),
          elevation: 4,
        ),
        onPressed: () => falarPalavra(btn.label),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (btn.imagePath != null)
              btn.imagePath!.startsWith('assets/')
                  ? Image.asset(btn.imagePath!, height: iconSize + 37)
                  : Image.file(File(btn.imagePath!), height: iconSize + 37)
            else
              Icon(btn.icon, size: iconSize, color: Colors.black87),
            SizedBox(height: orientation == Orientation.portrait ? 10 : 6),
            Text(
              btn.label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}