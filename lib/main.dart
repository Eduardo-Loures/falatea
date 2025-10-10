// FalaTEA - Aplicativo de Comunicação Aumentativa e Alternativa


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto/services/auth_services.dart';
import 'package:projeto/widgets/auth_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';


// CONFIGURAÇÃO INICIAL E MAIN

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configura orientações permitidas do dispositivo
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthService()),
        ],
        child: FalaTEA(),
      ),
    );
  }
  );
}

// WIDGET RAIZ DA APLICAÇÃO
/// Widget raiz que configura o tema e inicializa o app
class FalaTEA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FalaTEA',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthCheck(),
    );
  }
}

// TELA PRINCIPAL - GERENCIAMENTO DE COMUNICAÇÃO
/// Tela principal que gerencia as categorias e botões de comunicação
class TelaInicial extends StatefulWidget {
  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> with SingleTickerProviderStateMixin {

  // VARIÁVEIS DE ESTADO E CONTROLADORES

  final FlutterTts tts = FlutterTts();                    // Sintetizador de voz
  late TabController tabController;                       // Controlador das abas
  Orientation? _currentOrientation;                       // Orientação atual da tela
  final ScrollController _scrollController = ScrollController(); // Controle de scroll
  final Map<String, GlobalKey> _categoryKeys = {};       // Chaves para navegação por categoria

  // NOVA VARIÁVEL PARA A CAIXA DE TEXTO
  String _textoFalado = '';                              // Texto atual sendo exibido

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

  // INICIALIZAÇÃO E CONFIGURAÇÃO

  @override
  void initState() {
    super.initState();

    // Inicializa o controlador de abas
    tabController = TabController(length: categorias.length, vsync: this);

    // Configura o sintetizador de voz
    _inicializarTTS();

    // Carrega configurações salvas - AGORA IMPLEMENTADO
    _carregarConfigsSalvas();

    // Cria chaves para navegação por categoria
    for (String categoria in categorias.keys) {
      _categoryKeys[categoria] = GlobalKey();
    }

    // Configura listener para mudanças de aba
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        _scrollToCategory(tabController.index);
      }
    });

    // Configura listener de orientação após build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureOrientationListener();
    });
  }

  @override
  void dispose() {
    // Limpa recursos ao destruir o widget
    tabController.dispose();
    _scrollController.dispose();
    tts.stop();
    super.dispose();
  }

  // CONFIGURAÇÃO DO SINTETIZADOR DE VOZ

  /// Inicializa e configura o Text-to-Speech
  Future<void> _inicializarTTS() async {
    await tts.setLanguage('pt-BR');    // Define idioma português brasileiro
    await tts.setSpeechRate(0.5);      // Velocidade da fala (0.0 a 1.0)
    await tts.setVolume(1.0);          // Volume máximo
    await tts.setPitch(1.0);           // Tom de voz normal
  }

  // PERSISTÊNCIA DE DADOS - NOVO CÓDIGO

  /// Salva os botões personalizados no SharedPreferences
  Future<void> _salvarBotoesPersonalizados() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cria um mapa para armazenar apenas os botões personalizados (não fixos)
      Map<String, List<Map<String, dynamic>>> botoesPersonalizados = {};

      categorias.forEach((categoria, botoes) {
        // Filtra apenas botões não fixos
        List<BotaoAAC> botoesNaoFixos = botoes.where((botao) => !botao.isFixo).toList();

        if (botoesNaoFixos.isNotEmpty) {
          botoesPersonalizados[categoria] = botoesNaoFixos
              .map((botao) => botao.toJson())
              .toList();
        }
      });

      // Salva no SharedPreferences
      String jsonString = json.encode(botoesPersonalizados);
      await prefs.setString('botoes_personalizados', jsonString);

      print('Botões personalizados salvos com sucesso!');
    } catch (e) {
      print('Erro ao salvar botões personalizados: $e');
    }
  }

  /// Carrega os botões personalizados do SharedPreferences
  Future<void> _carregarConfigsSalvas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('botoes_personalizados');

      if (jsonString != null && jsonString.isNotEmpty) {
        Map<String, dynamic> dadosSalvos = json.decode(jsonString);

        // Adiciona os botões personalizados às categorias existentes
        dadosSalvos.forEach((categoria, botoesList) {
          if (categorias.containsKey(categoria)) {
            List<BotaoAAC> botoesPersonalizados = (botoesList as List)
                .map((botaoJson) => BotaoAAC.fromJson(botaoJson))
                .toList();

            // Adiciona os botões personalizados à categoria
            categorias[categoria]!.addAll(botoesPersonalizados);
          }
        });

        // Atualiza a UI
        if (mounted) {
          setState(() {});
        }

        print('Botões personalizados carregados com sucesso!');
      }
    } catch (e) {
      print('Erro ao carregar botões personalizados: $e');
    }
  }

  /// Limpa todos os dados salvos (útil para debug ou reset)
  Future<void> _limparDadosSalvos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('botoes_personalizados');
    print('Dados salvos limpos!');
  }

  // NAVEGAÇÃO E SCROLL

  /// Rola a tela para mostrar a categoria selecionada
  void _scrollToCategory(int index) {
    String categoria = categorias.keys.elementAt(index);
    final key = _categoryKeys[categoria];

    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Configura listener para mudanças de orientação (placeholder)
  void _configureOrientationListener() {
    // Implementação futura para reagir a mudanças de orientação
  }

  // MANIPULAÇÃO DE FALA DIRETA
  /// Fala a palavra imediatamente ao clicar no botão e atualiza a caixa de texto
  void falarPalavra(String palavra) {
    setState(() {
      _textoFalado = palavra; // Atualiza o texto exibido
    });
    tts.speak(palavra);
  }

  /// Limpa a caixa de texto
  void _limparTexto() {
    setState(() {
      _textoFalado = '';
    });
  }

  // GERENCIAMENTO DE BOTÕES PERSONALIZADOS
  /// Exibe dialog para confirmação de exclusão de botão
  void _mostrarDialogoExcluirBotao(BotaoAAC botao) {
    // Impede exclusão de botões fixos
    if (botao.isFixo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Este botão não pode ser excluído.')),
      );
      return;
    }

    // Encontra a categoria do botão
    String? categoriaEncontrada;
    categorias.forEach((categoria, lista) {
      if (lista.contains(botao)) {
        categoriaEncontrada = categoria;
      }
    });

    if (categoriaEncontrada == null) return;

    // Exibe diálogo de confirmação
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Excluir botão'),
          content: Text('Deseja excluir o botão "${botao.label}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  categorias[categoriaEncontrada!]!.remove(botao);
                });

                // Salva as alterações
                await _salvarBotoesPersonalizados();

                Navigator.pop(context);

                // Mostra confirmação
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Botão excluído com sucesso!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  /// Exibe diálogo para criação de novo botão personalizado
  void mostrarDialogoAdicionarBotao() {
    final _labelController = TextEditingController();
    final orientation = MediaQuery.of(context).orientation;

    // Variáveis de estado para o diálogo
    IconData _iconSelecionado = Icons.star;
    Color _corSelecionada = Colors.orange;
    String _categoriaSelecionada = categorias.keys.first;
    String? _imagemSelecionada;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Criar novo botão'),
              content: SingleChildScrollView(
                child: Container(
                  width: orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width * 0.8
                      : MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Campo de texto para label do botão
                      TextField(
                        controller: _labelController,
                        decoration: InputDecoration(
                          labelText: 'Texto do botão',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Seleção de categoria
                      Text('Selecione uma categoria:'),
                      DropdownButton<String>(
                        value: _categoriaSelecionada,
                        isExpanded: true,
                        items: categorias.keys
                            .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                            .toList(),
                        onChanged: (String? valor) {
                          setDialogState(() {
                            _categoriaSelecionada = valor ?? categorias.keys.first;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Seleção de imagem personalizada
                      Text('Escolha uma imagem (opcional):'),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setDialogState(() {
                              _imagemSelecionada = picked.path;
                            });
                          }
                        },
                        icon: Icon(Icons.image),
                        label: Text("Escolher imagem"),
                      ),

                      // Preview da imagem selecionada
                      if (_imagemSelecionada != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Image.file(File(_imagemSelecionada!), height: 80),
                        ),

                      // Seleção de ícone
                      Text('Selecione um ícone:'),
                      DropdownButton<IconData>(
                        value: _iconSelecionado,
                        items: [
                          Icons.star, Icons.favorite, Icons.face, Icons.cake,
                          Icons.home, Icons.pets, Icons.school, Icons.accessibility,
                          Icons.bathroom, Icons.directions_car, Icons.music_note, Icons.smartphone,
                        ]
                            .map((icon) => DropdownMenuItem(
                          value: icon,
                          child: Icon(icon),
                        ))
                            .toList(),
                        onChanged: (IconData? valor) {
                          setDialogState(() {
                            _iconSelecionado = valor ?? Icons.star;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Seleção de cor
                      Text('Selecione uma cor:'),
                      DropdownButton<Color>(
                        value: _corSelecionada,
                        items: [
                          Colors.orange, Colors.blue, Colors.teal, Colors.lightGreen,
                          Colors.red, Colors.amber, Colors.pink, Colors.cyan, Colors.lime,
                        ]
                            .map((color) => DropdownMenuItem(
                          value: color,
                          child: Container(width: 50, height: 20, color: color),
                        ))
                            .toList(),
                        onChanged: (Color? valor) {
                          setDialogState(() {
                            _corSelecionada = valor ?? Colors.orange;
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
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_labelController.text.isNotEmpty) {
                      setState(() {
                        categorias[_categoriaSelecionada]!.add(
                          BotaoAAC(
                            _labelController.text,
                            _imagemSelecionada == null ? _iconSelecionado : null,
                            _corSelecionada,
                            imagePath: _imagemSelecionada,
                          ),
                        );
                      });

                      // Salva o novo botão
                      await _salvarBotoesPersonalizados();

                      // Mostra confirmação
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Botão criado com sucesso!')),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Adicionar'),
                )
              ],
            );
          },
        );
      },
    );
  }

  // CONSTRUÇÃO DA INTERFACE

  @override
  Widget build(BuildContext context) {
    _currentOrientation = MediaQuery.of(context).orientation;

    // Ajusta número de colunas baseado na orientação
    int crossAxisCount = _currentOrientation == Orientation.portrait ? 3 : 5;

    return Scaffold(
      // ===== BARRA DE APLICAÇÃO =====
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
        // Adiciona menu de opções
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'limpar_dados') {
                // Confirma antes de limpar
                bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Limpar Dados'),
                    content: Text('Isso removerá todos os botões personalizados. Deseja continuar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text('Limpar'),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  await _limparDadosSalvos();
                  // Recarrega a tela removendo botões personalizados
                  setState(() {
                    categorias.forEach((categoria, botoes) {
                      botoes.removeWhere((botao) => !botao.isFixo);
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dados limpos com sucesso!')),
                  );
                }
              } else if (value == 'logout') {
                // Confirma antes de fazer logout
                bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Sair'),
                    content: Text('Deseja realmente sair da sua conta?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text('Sair'),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  try {
                    await context.read<AuthService>().logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout realizado com sucesso!')),
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
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
              PopupMenuItem(
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
              labelPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              tabAlignment: TabAlignment.start,
            ),
          ),
        ),
      ),

      // ===== CORPO PRINCIPAL =====
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Column(
            children: [
              // ===== CAIXA DE TEXTO PARA MOSTRAR PALAVRAS FALADAS =====
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

              // ===== ÁREA DE BOTÕES DE COMUNICAÇÃO =====
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Itera por todas as categorias
                    for (var categoria in categorias.keys)
                      Column(
                        key: _categoryKeys[categoria],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título da categoria
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                12.0,
                                categoria == categorias.keys.first ? 8 : 0,
                                12.0,
                                8
                            ),
                            child: Text(
                              categoria,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),

                          // Grid de botões da categoria
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GridView.count(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: orientation == Orientation.portrait ? 10 : 6,
                              crossAxisSpacing: orientation == Orientation.portrait ? 10 : 6,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              childAspectRatio: orientation == Orientation.portrait ? 1.0 : 1.3,
                              children: categorias[categoria]!
                                  .map((btn) => _buildBotaoComunicacao(btn, orientation))
                                  .toList(),
                            ),
                          ),
                          SizedBox(height: 0),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // ===== BOTÃO FLUTUANTE PARA ADICIONAR BOTÕES =====
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarDialogoAdicionarBotao,
        tooltip: 'Adicionar novo botão',
        child: Icon(Icons.add),
      ),
    );
  }

  /// Constrói botões de comunicação individuais
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
            // Exibe imagem ou ícone
            if (btn.imagePath != null)
              btn.imagePath!.startsWith('assets/')
                  ? Image.asset(btn.imagePath!, height: iconSize + 37)
                  : Image.file(File(btn.imagePath!), height: iconSize + 37)
            else
              Icon(btn.icon, size: iconSize, color: Colors.black87),

            SizedBox(height: orientation == Orientation.portrait ? 10 : 6),

            // Texto do botão
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

// MODELO DE DADOS - BOTÃO DE COMUNICAÇÃO ATUALIZADO
/// Classe que representa um botão de comunicação AAC com serialização
class BotaoAAC {
  final String label;
  final IconData? icon;
  final String? imagePath;
  final Color color;
  final bool isFixo;

  BotaoAAC(
      this.label,
      this.icon,
      this.color, {
        this.imagePath,
        this.isFixo = false,
      });

  // NOVOS MÉTODOS PARA SERIALIZAÇÃO

  /// Converte o botão para JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'iconCodePoint': icon?.codePoint,
      'imagePath': imagePath,
      'colorValue': color,
      'isFixo': isFixo,
    };
  }

  /// Cria um botão a partir de JSON
  factory BotaoAAC.fromJson(Map<String, dynamic> json) {
    return BotaoAAC(
      json['label'],
      json['iconCodePoint'] != null ? IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons') : null,
      Color(json['colorValue']),
      imagePath: json['imagePath'],
      isFixo: json['isFixo'] ?? false,
    );
  }
}