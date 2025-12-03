import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:projeto/pages/home_page.dart';

class GerenciarCategoriasPage extends StatelessWidget {
  const GerenciarCategoriasPage({Key? key}) : super(key: key);

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
    final categorias = perfilService.categoriasSalvas ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        centerTitle: true,
      ),
      body: ListView(
        children: categorias.keys.map((categoria) {
          final bool isFixa = HomePageStateStatic.categoriasFixas.contains(categoria);

          return ListTile(
            title: Text(categoria),
            trailing: isFixa
                ? const Icon(Icons.lock, color: Colors.grey)
                : Icon(Icons.delete, color: Colors.red[700]),
            onTap: isFixa
                ? null
                : () => _confirmarExclusao(context, categoria),
          );
        }).toList(),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, String categoria) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Tem certeza que deseja excluir "$categoria"?\n'
            'Todos os botões desta categoria serão removidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final perfilService = context.read<PerfilService>();
    await perfilService.excluirCategoria(categoria);

    // Volta para a tela e mostra feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Categoria "$categoria" excluída'),
        backgroundColor: Colors.red,
      ),
    );

    Navigator.pop(context);
  }
}
