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
import 'dart:collection';


// Tela principal que gerencia as categorias e botões de comunicação
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class HomePageStateStatic {
  static const categoriasFixas = {
    'Ações',
    'Pessoas',
    'Objetos',
    'Emoções',
    'Negação',
  };
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // VARIÁVEIS DE ESTADO E CONTROLADORES
  late TabController tabController;
  Orientation? _currentOrientation;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};
  String _textoFalado = '';

  //Categorias Fixas
  final Set<String> categoriasFixas = {
    'Ações',
    'Pessoas',
    'Objetos',
    'Emoções',
    'Negação',
  };

  //Cores Categorias
  final Map<String, Color> corDasCategorias = {
    'Ações': Colors.orange,
    'Pessoas': Colors.blue,
    'Objetos': Colors.teal,
    'Emoções': Colors.lightGreen,
    'Negação': Colors.red,
  };

  // DADOS DAS CATEGORIAS E BOTÕES PREDEFINIDOS
  final LinkedHashMap<String, List<BotaoAAC>> categorias = LinkedHashMap<String, List<BotaoAAC>>();

  @override
  void initState() {
    super.initState();

    // Inicializa as categorias em ordem fixa
    categorias.addAll({
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
    });

    // Cria TabController com ordem garantida
    tabController = TabController(length: categorias.length, vsync: this);

    // Limpa botões não fixos antes de carregar personalizados
    categorias.forEach((categoria, botoes) {
      botoes.removeWhere((botao) => !botao.isFixo);
    });

    _carregarConfigsSalvas();

    // Recria keys SEMPRE seguindo a ordem correta
    categorias.keys.forEach((key) {
      _categoryKeys[key] = GlobalKey();
    });

    //Listener do TabController sem overflow
    tabController.addListener(() {
      if (!tabController.indexIsChanging) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollToCategory(tabController.index);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureOrientationListener();
      context.read<PerfilService>().addListener(_onPerfilServiceChanged);
    });
  }

  @override
  void dispose() {
    // remove listener antes de descartar
    try {
      context.read<PerfilService>().removeListener(_onPerfilServiceChanged);
    } catch (_) {}
    tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  // PERSISTÊNCIA DE DADOS
  Future<void> _salvarBotoesPersonalizados() async {
    try {
      final perfilService = context.read<PerfilService>();

      // Cria um novo mapa contendo APENAS os botões não-fixos
      final Map<String, List<BotaoAAC>> botoesParaSalvar = {};

      categorias.forEach((categoria, botoes) {
        final botoesNaoFixos = botoes.where((botao) => !botao.isFixo).toList();
        if (botoesNaoFixos.isNotEmpty) {
          botoesParaSalvar[categoria] = botoesNaoFixos;
        }
      });

      await perfilService.salvarBotoesPerfilAtivo(botoesParaSalvar);
      print('Botões personalizados salvos com sucesso!');
    } catch (e) {
      print('Erro ao salvar botões personalizados: $e');
    }
  }

  Future<void> _carregarConfigsSalvas() async {
    try {
      final perfilService = context.read<PerfilService>();

      //Carrega categorias salvas
      final coresSalvas = await perfilService.carregarCategoriasPerfilAtivo();

      coresSalvas.forEach((nome, cor) {
        if (!categorias.containsKey(nome)) {
          categorias[nome] = [];
        }
        corDasCategorias[nome] = cor;
      });

      // Continua carregando os botões personalizados
      final botoesPersonalizados = await perfilService.getBotoesPerfilAtivoAsync();

      categorias.forEach((categoria, botoes) {
        botoes.removeWhere((botao) => !botao.isFixo);
      });

      botoesPersonalizados.forEach((categoria, botoes) {
        if (categorias.containsKey(categoria)) {
          final botoesNaoFixos = botoes.where((botao) => !botao.isFixo).toList();
          categorias[categoria]!.addAll(botoesNaoFixos);
        }
      });

      if (mounted) setState(() {});

      print('Categorias e botões carregados com sucesso!');

    } catch (e) {
      print('Erro ao carregar configs: $e');
    }
  }

  Future<void> _limparDadosSalvos() async {
    final perfilService = context.read<PerfilService>();
    await perfilService.salvarBotoesPerfilAtivo({});
    print('Dados do perfil atual limpos!');
  }

  void _onPerfilServiceChanged() {
    // chama o metodo que já carrega categorias e botões salvos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _carregarConfigsSalvas();
    });
  }

  // NAVEGAÇÃO E SCROLL
  void _scrollToCategory(int index) {
    // SE A ÁRVORE AINDA NÃO EXISTE = NÃO ROLE NADA
    if (!mounted || !_scrollController.hasClients) return;

    // Se a lista ainda não foi construída, evita cálculo de altura inválido
    if (_categoryKeys.isEmpty || categorias.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {

        final orientation = MediaQuery.of(context).orientation;
        final crossAxisCount = orientation == Orientation.portrait ? 3 : 5;

        double offset = 0;

        // Para cada categoria antes da selecionada
        for (int i = 0; i < index; i++) {
          final categoria = categorias.keys.elementAt(i);
          final numBotoes = categorias[categoria]!.length;

          // Calcula quantas linhas essa categoria ocupa
          final linhas = (numBotoes / crossAxisCount).ceil();

          final childAspectRatio = orientation == Orientation.portrait ? 1.0 : 1.4;
          final itemHeight = (MediaQuery.of(context).size.width - 16) / crossAxisCount / childAspectRatio;
          final spacing = orientation == Orientation.portrait ? 10 : 8;

          offset += 40; // Título da categoria
          offset += (linhas * itemHeight) + ((linhas - 1) * spacing);
          offset += 16; // Padding entre categorias
        }

        // Faz o scroll
        _scrollController.animateTo(
          offset.clamp(
            0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        print('Erro ao calcular scroll: $e');
      }
    });
  }

  void _configureOrientationListener() {
    // Implementação futura
  }

  void _updateTabControllerIfNeeded({int? preferIndex}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final newLength = categorias.length;

      if (tabController.length == newLength) return;

      final safeIndex = (preferIndex ?? tabController.index).clamp(0, newLength - 1);

      tabController.dispose();

      tabController = TabController(
        length: newLength,
        vsync: this,
        initialIndex: safeIndex,
      );

      tabController.addListener(() {
        if (tabController.indexIsChanging) {
          _scrollToCategory(tabController.index);
        }
      });

      setState(() {}); // força rebuild
    });
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
                _scrollController.jumpTo(0);
                setState(() {
                  categorias[categoriaEncontrada!]!.remove(botao);
                });
                // Garantir tabs atualizadas
                _updateTabControllerIfNeeded(
                  preferIndex: categorias.keys.toList().indexOf(categoriaEncontrada!),
                );

                await _salvarBotoesPersonalizados();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botão excluído com sucesso!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // o
                ),
              ),
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoCriarCategoria(VoidCallback? onCategoriacriada) {
    final nomeController = TextEditingController();
    Color corSelecionada = Colors.purple;

    final coresDisponiveis = [
      Colors.purple,
      Colors.indigo,
      Colors.brown,
      Colors.deepPurple,
      Colors.deepOrange,
      Colors.amber,
      Colors.cyan,
      Colors.pink,
      Colors.lime,
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.create_new_folder, color: Colors.green),
                  SizedBox(width: 12),
                  Text('Nova Categoria', style: TextStyle(fontSize: 18)),
                ],
              ),

              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome da categoria',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.label),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        textCapitalization: TextCapitalization.words,
                        autofocus: true,
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cor da categoria:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: coresDisponiveis.map((cor) {
                          final isSelected = cor == corSelecionada;
                          return InkWell(
                            onTap: () => setDialogState(() => corSelecionada = cor),
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
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Criar"),
                  onPressed: () {
                    final nome = nomeController.text.trim();

                    if (nome.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Digite o nome da categoria")),
                      );
                      return;
                    }

                    if (categorias.containsKey(nome)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Essa categoria já existe")),
                      );
                      return;
                    }

                    // Atualiza apenas o mapa
                    _scrollController.jumpTo(0);
                    setState(() {
                      categorias[nome] = [];
                      corDasCategorias[nome] = corSelecionada;
                    });
                    context.read<PerfilService>().salvarCategoriasPerfilAtivo(corDasCategorias);
                    _updateTabControllerIfNeeded(preferIndex: categorias.length - 1);

                    Navigator.pop(dialogContext);

                    // Atualiza drop-down do diálogo de adicionar botão
                    if (onCategoriacriada != null) onCategoriacriada!();
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoExcluirCategoria(String categoria) {
    // Impede excluir categorias fixas
    if (categoriasFixas.contains(categoria)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Categorias fixas não podem ser excluídas.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red[700]),
              const SizedBox(width: 12),
              Text("Excluir categoria"),
            ],
          ),
          content: Text(
            'Tem certeza que deseja excluir a categoria "$categoria"?\n'
                'Todos os botões dentro dela também serão removidos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // Reseta scroll antes de mudar árvore (evita overflow)
                _scrollController.jumpTo(0);

                setState(() {
                  categorias.remove(categoria);
                  corDasCategorias.remove(categoria);
                  _categoryKeys.remove(categoria);
                });

                _updateTabControllerIfNeeded();

                // Salva categorias atualizadas
                context
                    .read<PerfilService>()
                    .salvarCategoriasPerfilAtivo(corDasCategorias);

                // Salva botões atualizados
                await _salvarBotoesPersonalizados();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Categoria "$categoria" excluída!'),
                    backgroundColor: Colors.red[700],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  void mostrarDialogoAdicionarBotao() {
    print("Qtd categorias = ${categorias.length}");

    final labelController = TextEditingController();
    final orientation = MediaQuery.of(context).orientation;

    IconData iconSelecionado = Icons.star;
    String categoriaSelecionada = categorias.keys.first;
    String? imagemSelecionada;

    // Lista de ícones disponíveis
    final Map<String, IconData> iconesDisponiveis = {
      'Estrela': Icons.star,
      'Coração': Icons.favorite,
      'Rosto': Icons.face,
      'Bolo': Icons.cake,
      'Casa': Icons.home,
      'Pet': Icons.pets,
      'Escola': Icons.school,
      'Pessoa': Icons.accessibility,
      'Banheiro': Icons.bathroom,
      'Carro': Icons.directions_car,
      'Música': Icons.music_note,
      'Celular': Icons.smartphone,
    };

    String iconeSelecionadoNome = 'Estrela';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Center(
                child: Text(
                  'Criar novo botão',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                ),
                child: SingleChildScrollView(
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

                      // CATEGORIA
                      Row(
                        children: [
                          Icon(Icons.category, size: 20, color: Colors.indigo[700]),
                          const SizedBox(width: 8),
                          const Text('Categoria:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          const Spacer(),

                          TextButton.icon(
                            onPressed: () {
                              _mostrarDialogoCriarCategoria(() {
                                setState(() {});
                                setDialogState(() {});
                              });
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nova', style: TextStyle(fontSize: 13)),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green[700],
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: categoriaSelecionada,
                        items: categorias.keys.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (String? valor) {
                          setDialogState(() {
                            categoriaSelecionada = valor ?? categorias.keys.first;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Imagem (Opcional)
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

                      // Ícone
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
                      DropdownButtonFormField<String>(
                        value: iconeSelecionadoNome,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        isExpanded: true,
                        items: iconesDisponiveis.keys
                            .map((nome) => DropdownMenuItem(
                          value: nome,
                          child: Row(
                            children: [
                              Icon(iconesDisponiveis[nome]!, size: 20),
                              const SizedBox(width: 12),
                              Text(nome, style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        ))
                            .toList(),
                        onChanged: (String? valor) {
                          setDialogState(() {
                            iconeSelecionadoNome = valor ?? 'Estrela';
                            iconSelecionado = iconesDisponiveis[iconeSelecionadoNome]!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (labelController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Digite o texto do botão')),
                      );
                      return;
                    }

                    final corDaCategoria = corDasCategorias[categoriaSelecionada] ?? Colors.grey;

                    final novoBotao = BotaoAAC(
                      labelController.text.trim(),
                      imagemSelecionada == null ? iconSelecionado : null,
                      corDaCategoria,
                      imagePath: imagemSelecionada,
                    );

                    Navigator.pop(dialogContext);

                    // Garantir Tabs antes de alterar UI
                    _updateTabControllerIfNeeded(
                      preferIndex: categorias.keys.toList().indexOf(categoriaSelecionada),
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      if (!mounted) return;

                      _scrollController.jumpTo(0);
                      setState(() {
                        categorias[categoriaSelecionada]!.add(novoBotao);
                      });

                      await _salvarBotoesPersonalizados();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Botão "${labelController.text.trim()}" criado!'),
                          backgroundColor: Colors.green[700],
                        ),
                      );
                    });
                  },

                  icon: const Icon(Icons.check),
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

    // Verifica se está em modo paisagem
    final isLandscape = _currentOrientation == Orientation.landscape;

    return Consumer<PerfilService>(
      builder: (context, perfilService, child) {
        final perfilAtivo = perfilService.perfilAtivo;

        return Scaffold(
          appBar: AppBar(
            // Reduz a altura do AppBar em landscape
            toolbarHeight: isLandscape ? 48 : 56,
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
            // Mostrar título apenas em portrait
            title: isLandscape
                ? null  // Esconde completamente em landscape
                : Column(
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
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: mostrarDialogoAdicionarBotao,
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'Adicionar novo botão',
                  iconSize: 28,
                ),
              ),
              PopupMenuButton<String>(
                // Ícone menor em landscape
                iconSize: isLandscape ? 20 : 24,
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
                        title: const Text('Limpar dados'),
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
                ],
              ),
            ],
            bottom: PreferredSize(
              // Reduz altura das tabs em landscape
              preferredSize: Size.fromHeight(isLandscape ? 40 : 48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: tabController,
                  isScrollable: true,
                  tabs: categorias.keys.map((cat) => Tab(
                    text: cat,
                    height: isLandscape ? 40 : 48,
                  )).toList(),
                  indicatorColor: Colors.indigo[600],
                  indicatorWeight: 3,
                  labelStyle: TextStyle(
                    fontSize: isLandscape ? 14 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: isLandscape ? 13 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 16 : 20,
                  ),
                  tabAlignment: TabAlignment.start,
                ),
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final orientation = MediaQuery.of(context).orientation;
              final crossAxisCount = orientation == Orientation.portrait ? 3 : 5;

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: categorias.length + 1, // +1 para barra de fala
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildBarraFala(orientation);
                  }

                  final categoria = categorias.keys.elementAt(index - 1);
                  final botoes = categorias[categoria]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTituloCategoria(categoria, orientation),
                      botoes.isEmpty
                          ? _buildCategoriaVazia()
                          : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 0,
                            maxHeight: double.infinity,
                          ),
                          child: LayoutBuilder(
                            builder: (context, box) {
                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: orientation == Orientation.portrait ? 1.0 : 1.4,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: botoes.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (_, i) => _buildBotaoComunicacao(botoes[i], orientation),
                              );
                            },
                          ),
                        )
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBarraFala(Orientation orientation) {
    return Container(
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
              _textoFalado.isEmpty
                  ? 'Clique em um botão para falar...'
                  : _textoFalado,
              style: TextStyle(
                fontSize: orientation == Orientation.portrait ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: _textoFalado.isEmpty
                    ? Colors.grey[600]
                    : Colors.black87,
              ),
            ),
          ),
          if (_textoFalado.isNotEmpty)
            IconButton(
              onPressed: _limparTexto,
              icon: Icon(Icons.clear, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildTituloCategoria(String categoria, Orientation orientation) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12.0,
        categoria == categorias.keys.first ? 8 : 0,
        12.0,
        orientation == Orientation.portrait ? 8 : 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              categoria,
              style: TextStyle(
                fontSize: orientation == Orientation.portrait ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCategoriaVazia() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Ainda não há botões nesta categoria.\nToque no + para adicionar botões aqui.',
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildBotaoComunicacao(BotaoAAC btn, Orientation orientation) {
    final double cardMaxHeight = orientation == Orientation.portrait ? 150 : 120;

    return SizedBox(
      height: cardMaxHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: btn.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(6),
        ),
        onPressed: () => falarPalavra(btn.label),
        onLongPress: () => _mostrarDialogoExcluirBotao(btn),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // IMAGEM OU ÍCONE COM ALTURA LIMITADA
            SizedBox(
              height: orientation == Orientation.portrait ? 60 : 45,
              child: btn.imagePath != null
                  ? (btn.imagePath!.startsWith('assets/')
                  ? Image.asset(btn.imagePath!, fit: BoxFit.contain)
                  : Image.file(File(btn.imagePath!), fit: BoxFit.contain))
                  : Icon(
                       btn.icon ?? Icons.help_outline,
                       size: orientation == Orientation.portrait ? 34 : 28,
                       color: Colors.black87,
                  )
            ),

            const SizedBox(height: 6),

            // TEXTO LIMITADO
            SizedBox(
              height: orientation == Orientation.portrait ? 40 : 28,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  btn.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: orientation == Orientation.portrait ? 18 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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