import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto/models/botao_aac_model.dart';
import 'package:projeto/pages/configuracoes_page.dart';
import 'package:projeto/pages/selecao_perfil_page.dart';
import 'package:projeto/services/auth_services.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:projeto/services/tts_service.dart';
import 'package:provider/provider.dart';
import 'dart:io';

/// Tela principal que gerencia as categorias e botões de comunicação
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // VARIÁVEIS DE ESTADO E CONTROLADORES
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
    super.dispose();
  }

  // PERSISTÊNCIA DE DADOS
  Future<void> _salvarBotoesPersonalizados() async {
    try {
      final perfilService = context.read<PerfilService>();
      await perfilService.salvarBotoesPerfilAtivo(categorias);
      print('Botões personalizados salvos com sucesso!');
    } catch (e) {
      print('Erro ao salvar botões personalizados: $e');
    }
  }

  Future<void> _carregarConfigsSalvas() async {
    try {
      final perfilService = context.read<PerfilService>();
      final botoesPersonalizados = perfilService.getBotoesPerfilAtivo();

      botoesPersonalizados.forEach((categoria, botoes) {
        if (categorias.containsKey(categoria)) {
          categorias[categoria]!.addAll(botoes);
        }
      });

      if (mounted) setState(() {});
      print('Botões personalizados carregados com sucesso!');
    } catch (e) {
      print('Erro ao carregar botões personalizados: $e');
    }
  }

  Future<void> _limparDadosSalvos() async {
    final perfilService = context.read<PerfilService>();
    await perfilService.salvarBotoesPerfilAtivo({});
    print('Dados do perfil atual limpos!');
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
    context.read<TtsService>().falar(palavra);
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 34),
                  const Text('Criar novo botão'),
                ],
              ),
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
                        decoration: InputDecoration(
                          labelText: 'Texto do botão',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.text_fields),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.category, size: 20, color: Colors.indigo[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Categoria:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: categoriaSelecionada,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        isExpanded: true,
                        items: categorias.keys
                            .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(fontSize: 15)),
                        ))
                            .toList(),
                        onChanged: (String? valor) {
                          setDialogState(() {
                            categoriaSelecionada = valor ?? categorias.keys.first;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.image, size: 20, color: Colors.indigo[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Imagem (Opcional):',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setDialogState(() {
                              imagemSelecionada = picked.path;
                            });
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text(imagemSelecionada == null ? 'Procure na galeria' : 'Trocar Imagem'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo[700],
                          side: BorderSide(color: Colors.indigo[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                      if (imagemSelecionada != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(imagemSelecionada!),
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Imagem selecionada',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    setDialogState(() {
                                      imagemSelecionada = null;
                                    });
                                  },
                                  tooltip: 'Remover',
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.star, size: 20, color: Colors.indigo[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Ícone:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Icons.star, Icons.favorite, Icons.face, Icons.cake,
                            Icons.home, Icons.pets, Icons.school, Icons.accessibility,
                            Icons.bathroom, Icons.directions_car, Icons.music_note, Icons.smartphone,
                          ].map((icon) {
                            final isSelected = icon == iconSelecionado;
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  iconSelecionado = icon;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.indigo[100] : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Colors.indigo[700]! : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  size: 28,
                                  color: isSelected ? Colors.indigo[700] : Colors.grey[600],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.palette, size: 20, color: Colors.indigo[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Cor do Botão:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Colors.orange, Colors.blue, Colors.teal, Colors.lightGreen,
                            Colors.red, Colors.amber, Colors.pink, Colors.cyan, Colors.lime,
                          ].map((cor) {
                            final isSelected = cor == corSelecionada;
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  corSelecionada = cor;
                                });
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.white,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: cor.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                  ],
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
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
                ElevatedButton.icon(
                  onPressed: () async {
                    if (labelController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Digite o texto do botão'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      categorias[categoriaSelecionada]!.add(
                        BotaoAAC(
                          labelController.text.trim(),
                          imagemSelecionada == null ? iconSelecionado : null,
                          corSelecionada,
                          imagePath: imagemSelecionada,
                        ),
                      );
                    });
                    await _salvarBotoesPersonalizados();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Botão "${labelController.text.trim()}" criado!'),
                          ],
                        ),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  label: const Text('Criar Botão'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
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
    int crossAxisCount = _currentOrientation == Orientation.portrait ? 3 : 5;

    return Consumer<PerfilService>(
      builder: (context, perfilService, child) {
        final perfilAtivo = perfilService.perfilAtivo;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.indigo[800]!, Colors.indigo[600]!],
                ),
              ),
            ),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SelecaoPerfilPage()),
                );
              },
              tooltip: 'Voltar para seleção',
            ),
            title: Column(
              children: [
                const Text(
                  'FalaTEA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                if (perfilAtivo != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          perfilAtivo.nome,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'configuracoes') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConfiguracoesPage()),
                    );
                  } else if (value == 'limpar_dados') {
                    bool? confirmar = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Limpar Dados'),
                        content: Text('Isso removerá todos os botões personalizados de ${perfilAtivo?.nome}. Deseja continuar?'),
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
                  } else if (value == 'trocar_perfil') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SelecaoPerfilPage()),
                    );
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
                    value: 'configuracoes',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text('Configurações'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'trocar_perfil',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Trocar Perfil'),
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
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: tabController,
                  isScrollable: true,
                  tabs: categorias.keys.map((cat) => Tab(
                    text: cat,
                    height: 48,
                  )).toList(),
                  indicatorColor: Colors.indigo[600],
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20),
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: mostrarDialogoAdicionarBotao,
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
            label: const Icon(Icons.add),
          ),
        );
      },
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