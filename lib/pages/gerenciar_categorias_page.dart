import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:projeto/widgets/avisos.dart';
import 'package:projeto/pages/home_page.dart';

class GerenciarCategoriasPage extends StatelessWidget {
  const GerenciarCategoriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final perfilService = context.watch<PerfilService>();
    final perfil = perfilService.perfilAtivo;

    if (perfil == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gerenciar Categorias')),
        body: const Center(child: Text('Nenhum perfil ativo.')),
      );
    }

    // Categorias carregadas DO HOME
    final categorias = perfilService.categoriasSalvas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        centerTitle: true,
      ),
      body: ListView(
        children:
            categorias.keys.map((categoria) {
              final bool isFixa = HomePageStateStatic.categoriasFixas.contains(
                categoria,
              );

              return ListTile(
                title: Text(categoria),
                trailing:
                    isFixa
                        ? const Icon(Icons.lock, color: Colors.grey)
                        : Icon(Icons.delete, color: Colors.red[700]),
                onTap:
                    isFixa
                        ? null
                        : () => _confirmarExclusao(context, categoria),
              );
            }).toList(),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, String categoria) async {
    final confirmar = await confirmarAcao(
      context,
      titulo: 'Excluir categoria',
      mensagem:
          'Tem certeza que deseja excluir "$categoria"?\n'
          'Todos os botões desta categoria serão removidos.',
      textoConfirmar: 'Excluir',
    );

    if (!confirmar || !context.mounted) return;

    final perfilService = context.read<PerfilService>();
    await perfilService.excluirCategoria(categoria);

    if (!context.mounted) return;

    // Volta para a tela e mostra feedback
    mostrarAviso(
      context,
      'Categoria "$categoria" excluída.',
      tipo: TipoAviso.sucesso,
    );

    Navigator.pop(context);
  }
}
