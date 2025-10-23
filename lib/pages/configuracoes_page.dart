import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:projeto/pages/selecao_perfil_page.dart';
import 'package:projeto/services/auth_services.dart';
import 'package:projeto/services/perfil_service.dart';
import 'package:projeto/services/tts_service.dart';
import 'package:provider/provider.dart';

/// Tela de Configurações do App
class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({Key? key}) : super(key: key);

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _carregarVozesDisponiveis();
  }

  Future<void> _carregarVozesDisponiveis() async {
    await _tts.setLanguage('pt-BR');
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final perfilService = context.watch<PerfilService>();
    final ttsService = context.watch<TtsService>();
    final usuario = authService.usuario;
    final perfilAtivo = perfilService.perfilAtivo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView(
        children: [
          // ===== SEÇÃO: USUÁRIO =====
          _buildSecaoHeader('Usuário', Icons.person),
          _buildCardUsuario(usuario?.email ?? 'Não logado', usuario?.uid),

          const SizedBox(height: 16),

          // ===== SEÇÃO: PERFIL ATIVO =====
          _buildSecaoHeader('Perfil Ativo', Icons.account_circle),
          if (perfilAtivo != null)
            _buildCardPerfilAtivo(perfilAtivo, perfilService)
          else
            _buildCardSemPerfil(),

          const SizedBox(height: 16),

          // ===== SEÇÃO: VOZ =====
          _buildSecaoHeader('Síntese de Voz', Icons.record_voice_over),
          _buildCardVoz(ttsService),

          const SizedBox(height: 16),

          // ===== SEÇÃO: AÇÕES =====
          _buildSecaoHeader('Ações', Icons.settings),

          // Botão Trocar Perfil
          _buildBotaoAcao(
            icon: Icons.swap_horiz,
            titulo: 'Trocar Perfil',
            subtitulo: 'Selecionar outro perfil',
            cor: Colors.blue,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SelecaoPerfilPage()),
              );
            },
          ),

          const Divider(height: 1),

          // Botão Sair
          _buildBotaoAcao(
            icon: Icons.logout,
            titulo: 'Sair da Conta',
            subtitulo: 'Fazer logout do aplicativo',
            cor: Colors.red,
            onTap: () => _confirmarSair(context, authService),
          ),

          const SizedBox(height: 32),

          // ===== INFORMAÇÕES DO APP =====
          _buildInfoApp(),
        ],
      ),
    );
  }

  Widget _buildSecaoHeader(String titulo, IconData icone) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icone, size: 20, color: Colors.indigo[700]),
          const SizedBox(width: 8),
          Text(
            titulo.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardUsuario(String email, String? uid) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.indigo[100],
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.indigo[700],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (uid != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'ID: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      uid,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardPerfilAtivo(perfil, PerfilService perfilService) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: perfil.cor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: perfil.cor, width: 2),
              ),
              child: Icon(perfil.icone, size: 30, color: perfil.cor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perfil.nome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'EM USO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSemPerfil() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700], size: 40),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Nenhum perfil selecionado',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardVoz(TtsService ttsService) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Tipo de Voz
          SwitchListTile(
            secondary: Icon(
              ttsService.vozFeminina ? Icons.woman : Icons.man,
              color: ttsService.vozFeminina ? Colors.pink[400] : Colors.blue[400],
              size: 30,
            ),
            title: const Text(
              'Tipo de Voz',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              ttsService.vozFeminina ? 'Voz Feminina' : 'Voz Masculina',
              style: TextStyle(
                color: ttsService.vozFeminina ? Colors.pink[700] : Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            value: ttsService.vozFeminina,
            onChanged: (valor) {
              ttsService.alternarVoz();
            },
          ),

          const Divider(height: 1),

          // Velocidade da Fala
          ListTile(
            leading: const Icon(Icons.speed, color: Colors.indigo),
            title: const Text(
              'Velocidade',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Slider(
              value: ttsService.velocidadeFala,
              min: 0.3,
              max: 1.0,
              divisions: 7,
              label: '${(ttsService.velocidadeFala * 100).toInt()}%',
              onChanged: (valor) {
                ttsService.setVelocidade(valor);
              },
            ),
          ),

          const Divider(height: 1),

          // Tom de Voz
          ListTile(
            leading: const Icon(Icons.graphic_eq, color: Colors.indigo),
            title: const Text(
              'Tom',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Slider(
              value: ttsService.tomVoz,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: ttsService.tomVoz.toStringAsFixed(1),
              onChanged: (valor) {
                ttsService.setTom(valor);
              },
            ),
          ),

          const Divider(height: 1),

          // Botão Testar Voz
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ttsService.testarVoz();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Testar Voz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoAcao({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cor, size: 24),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildInfoApp() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.record_voice_over, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'FalaTEA',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Versão 1.0.0',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Comunicação Aumentativa e Alternativa',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmarSair(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red[700]),
              const SizedBox(width: 12),
              const Text('Sair da Conta'),
            ],
          ),
          content: const Text(
            'Deseja realmente sair da sua conta?\n\nVocê precisará fazer login novamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authService.logout();
                  Navigator.pop(context); // Fecha diálogo
                  // AuthCheck vai redirecionar automaticamente para LoginPage
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao fazer logout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}