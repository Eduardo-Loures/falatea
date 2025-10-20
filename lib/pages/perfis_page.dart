import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto/models/perfil_model.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// Tela de gerenciamento de perfis
class PerfisPage extends StatelessWidget {
  const PerfisPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Perfis'),
        centerTitle: true,
      ),
      body: Consumer<PerfilService>(
        builder: (context, perfilService, child) {
          if (perfilService.perfis.isEmpty) {
            return _buildEmptyState(context);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: perfilService.perfis.length,
            itemBuilder: (context, index) {
              final perfil = perfilService.perfis[index];
              final isAtivo = perfilService.perfilAtivo?.id == perfil.id;

              return _buildPerfilCard(context, perfil, isAtivo, perfilService);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoCriarPerfil(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Perfil'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum perfil criado',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie perfis para seus alunos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoCriarPerfil(context),
            icon: const Icon(Icons.add),
            label: const Text('Criar Primeiro Perfil'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfilCard(
      BuildContext context,
      Perfil perfil,
      bool isAtivo,
      PerfilService perfilService,
      ) {
    return Card(
      elevation: isAtivo ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isAtivo
            ? BorderSide(color: perfil.cor, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () async {
          await perfilService.selecionarPerfil(perfil.id);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto ou Ícone
            if (perfil.foto != null)
              ClipOval(
                child: Image.file(
                  File(perfil.foto!),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) {
                    return _buildIconeAvatar(perfil);
                  },
                ),
              )
            else
              _buildIconeAvatar(perfil),

            const SizedBox(height: 12),

            // Nome
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                perfil.nome,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (isAtivo)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: perfil.cor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ATIVO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const Spacer(),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _mostrarDialogoEditarPerfil(context, perfil),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _confirmarExclusao(context, perfil, perfilService),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconeAvatar(Perfil perfil) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: perfil.cor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        perfil.icone,
        size: 40,
        color: perfil.cor,
      ),
    );
  }

  void _mostrarDialogoCriarPerfil(BuildContext context) {
    _mostrarDialogoPerfil(context, null);
  }

  void _mostrarDialogoEditarPerfil(BuildContext context, Perfil perfil) {
    _mostrarDialogoPerfil(context, perfil);
  }

  void _mostrarDialogoPerfil(BuildContext context, Perfil? perfilExistente) {
    final nomeController = TextEditingController(text: perfilExistente?.nome);
    String? fotoPath = perfilExistente?.foto;
    Color corSelecionada = perfilExistente?.cor ?? Colors.blue;
    IconData iconeSelecionado = perfilExistente?.icone ?? Icons.person;

    final cores = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.pink, Colors.teal, Colors.amber,
      Colors.indigo, Colors.cyan, Colors.lime, Colors.brown,
    ];

    final icones = [
      Icons.person, Icons.child_care, Icons.face, Icons.mood,
      Icons.star, Icons.favorite, Icons.pets, Icons.sports_soccer,
      Icons.music_note, Icons.palette, Icons.school, Icons.toys,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(perfilExistente == null ? 'Criar Perfil' : 'Editar Perfil'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campo Nome
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do aluno',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    // Botão Adicionar Foto
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            fotoPath = picked.path;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(fotoPath == null ? 'Adicionar Foto' : 'Alterar Foto'),
                    ),

                    if (fotoPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ClipOval(
                          child: Image.file(
                            File(fotoPath!),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    const Text('Selecione um ícone:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // Grid de Ícones
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icones.map((icone) {
                        final isSelected = icone == iconeSelecionado;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              iconeSelecionado = icone;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? corSelecionada.withOpacity(0.2) : Colors.grey[100],
                              border: Border.all(
                                color: isSelected ? corSelecionada : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icone, color: isSelected ? corSelecionada : Colors.grey[600]),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    const Text('Selecione uma cor:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // Grid de Cores
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cores.map((cor) {
                        final isSelected = cor == corSelecionada;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              corSelecionada = cor;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.white,
                                width: isSelected ? 3 : 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nomeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Digite o nome do aluno')),
                      );
                      return;
                    }

                    final perfilService = context.read<PerfilService>();

                    if (perfilExistente == null) {
                      // Criar novo
                      final novoPerfil = Perfil(
                        id: const Uuid().v4(),
                        nome: nomeController.text.trim(),
                        foto: fotoPath,
                        cor: corSelecionada,
                        icone: iconeSelecionado,
                      );
                      await perfilService.criarPerfil(novoPerfil);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Perfil "${novoPerfil.nome}" criado!')),
                      );
                    } else {
                      // Editar existente
                      final perfilAtualizado = perfilExistente.copyWith(
                        nome: nomeController.text.trim(),
                        foto: fotoPath,
                        cor: corSelecionada,
                        icone: iconeSelecionado,
                      );
                      await perfilService.atualizarPerfil(perfilAtualizado);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil atualizado!')),
                      );
                    }

                    Navigator.pop(context);
                  },
                  child: Text(perfilExistente == null ? 'Criar' : 'Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarExclusao(BuildContext context, Perfil perfil, PerfilService perfilService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Perfil'),
          content: Text('Deseja excluir o perfil de "${perfil.nome}"?\n\nTodos os botões personalizados deste perfil serão perdidos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await perfilService.excluirPerfil(perfil.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Perfil "${perfil.nome}" excluído')),
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
}