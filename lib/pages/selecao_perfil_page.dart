import 'dart:io';
import 'package:flutter/material.dart';
import 'package:projeto/models/perfil_model.dart';
import 'package:projeto/pages/configuracoes_page.dart';
import 'package:projeto/pages/home_page.dart';
import 'package:projeto/pages/perfis_page.dart';
import 'package:projeto/services/auth_services.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:provider/provider.dart';

/// Tela intermediária para selecionar qual perfil usar
class SelecaoPerfilPage extends StatelessWidget {
  const SelecaoPerfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione um perfil'),
        centerTitle: true,
        actions: [
          // Botão Configurações
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfiguracoesPage()),
              );
            },
            tooltip: 'Configurações',
          ),
          // Botão Gerenciar Perfis
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfisPage()),
              );
            },
            tooltip: 'Gerenciar perfis',
          ),
        ],
      ),
      body: Consumer<PerfilService>(
        builder: (context, perfilService, child) {
          if (!perfilService.temPerfis) {
            return _buildEmptyState(context);
          }

          return _buildGridPerfis(context, perfilService);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PerfisPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Gerenciar Perfis'),
      ),
    );
  }



  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_outlined,
                size: 80,
                color: Colors.indigo[700],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Nenhum perfil criado',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Crie perfis personalizados para cada pessoa.\nCada perfil terá seus próprios botões!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfisPage()),
                );
              },
              icon: const Icon(Icons.add, size: 24),
              label: const Text(
                'Criar Primeiro Perfil',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                backgroundColor: Colors.indigo[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPerfis(BuildContext context, PerfilService perfilService) {
    final orientation = MediaQuery.of(context).orientation;
    final crossAxisCount = orientation == Orientation.portrait ? 2 : 3;

    return Column(
      children: [
        // Header com informações
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.indigo[50],
          child: Column(
            children: [
              Text(
                'Escolha um perfil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${perfilService.quantidadePerfis} ${perfilService.quantidadePerfis == 1 ? "perfil criado" : "perfis criados"}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.indigo[700],
                ),
              ),
            ],
          ),
        ),

        // Grid de perfis
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: perfilService.perfis.length,
            itemBuilder: (context, index) {
              final perfil = perfilService.perfis[index];
              final isAtivo = perfilService.perfilAtivo?.id == perfil.id;

              return _buildPerfilCard(context, perfil, isAtivo, perfilService);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPerfilCard(
      BuildContext context,
      Perfil perfil,
      bool isAtivo,
      PerfilService perfilService,
      ) {
    return Hero(
      tag: 'perfil_${perfil.id}',
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isAtivo
              ? BorderSide(color: perfil.cor, width: 3)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () async {
            await perfilService.selecionarPerfil(perfil.id);

            // Navega para a HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Foto ou Ícone
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (perfil.foto != null)
                      ClipOval(
                        child: Image.file(
                          File(perfil.foto!),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return _buildIconeAvatar(perfil);
                          },
                        ),
                      )
                    else
                      _buildIconeAvatar(perfil),

                    // Badge de perfil ativo
                    if (isAtivo)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Nome
                Text(
                  perfil.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Botão ou badge
                if (isAtivo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: perfil.cor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'EM USO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconeAvatar(Perfil perfil) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: perfil.cor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: perfil.cor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        perfil.icone,
        size: 45,
        color: perfil.cor,
      ),
    );
  }


  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<AuthService>().logout();
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao fazer logout: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}