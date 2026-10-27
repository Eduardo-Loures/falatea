import 'package:flutter/material.dart';

// Padrão visual único para avisos, confirmações e resultados de jogos

enum TipoAviso { sucesso, erro, info }

// AVISO RÁPIDO (sempre embaixo, flutuante)
void mostrarAviso(
  BuildContext context,
  String mensagem, {
  TipoAviso tipo = TipoAviso.info,
}) {
  final (cor, icone) = switch (tipo) {
    TipoAviso.sucesso => (Colors.green[700]!, Icons.check_circle_rounded),
    TipoAviso.erro => (Colors.red[700]!, Icons.error_rounded),
    TipoAviso.info => (Colors.indigo[700]!, Icons.info_rounded),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: Duration(seconds: tipo == TipoAviso.erro ? 4 : 3),
        content: Row(
          children: [
            Icon(icone, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensagem,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

// CONFIRMAÇÃO (excluir, sair, limpar...)
Future<bool> confirmarAcao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String textoConfirmar,
  IconData icone = Icons.delete_outline_rounded,
  bool perigoso = true,
}) async {
  final cor = perigoso ? Colors.red[600]! : Colors.indigo;

  final confirmou = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return _DialogoPadrao(
        icone: icone,
        cor: cor,
        titulo: titulo,
        mensagem: mensagem,
        botoes: [
          Expanded(
            child: OutlinedButton(
              style: _estiloBotao(
                OutlinedButton.styleFrom(foregroundColor: Colors.grey[800]),
              ),
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              style: _estiloBotao(FilledButton.styleFrom(backgroundColor: cor)),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(textoConfirmar),
            ),
          ),
        ],
      );
    },
  );

  return confirmou ?? false;
}

// RESULTADO DOS JOGOS (acertou / errou)
Future<void> mostrarResultadoJogo(
  BuildContext context, {
  required bool acertou,
  String? mensagem,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _DialogoPadrao(
        icone: acertou ? Icons.star_rounded : Icons.refresh_rounded,
        cor: acertou ? Colors.amber[700]! : Colors.orange[700]!,
        titulo: acertou ? 'Muito bem!' : 'Quase lá!',
        mensagem: mensagem ?? (acertou ? 'Você acertou!' : 'Tente novamente.'),
        botoes: [
          Expanded(
            child: FilledButton(
              style: _estiloBotao(
                FilledButton.styleFrom(backgroundColor: Colors.indigo),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(acertou ? 'Continuar' : 'Tentar de novo'),
            ),
          ),
        ],
      );
    },
  );
}

ButtonStyle _estiloBotao(ButtonStyle base) {
  return base.copyWith(
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 14)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

class _DialogoPadrao extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String titulo;
  final String mensagem;
  final List<Widget> botoes;

  const _DialogoPadrao({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.mensagem,
    required this.botoes,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: cor.withValues(alpha: 0.12),
              child: Icon(icone, color: cor, size: 38),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            Row(children: botoes),
          ],
        ),
      ),
    );
  }
}
