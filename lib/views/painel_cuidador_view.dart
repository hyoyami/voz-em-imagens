import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import 'cartoes_view.dart';
import 'configuracoes_view.dart';
import 'login_view.dart';
import 'relatorios_view.dart';

/// MODO CUIDADOR: menu protegido por PIN (RF11, RF12).
class PainelCuidadorView extends StatelessWidget {
  const PainelCuidadorView({super.key});

  void _abrir(BuildContext context, Widget tela) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
  }

  Future<void> _sair(BuildContext context) async {
    await AuthController().sair();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (rota) => false,
    );
  }

  Widget _item(IconData icone, String titulo, String subtitulo, VoidCallback aoTocar) {
    return Card(
      child: ListTile(
        leading: Icon(icone, size: 30),
        title: Text(titulo, style: const TextStyle(fontSize: 18)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: aoTocar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo cuidador')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _item(Icons.bar_chart, 'Relatórios',
              'Semanal, mensal e anual', () => _abrir(context, const RelatoriosView())),
          _item(Icons.grid_view, 'Cartões',
              'Criar, editar e ocultar cartões', () => _abrir(context, const CartoesView())),
          _item(Icons.tune, 'Configurações',
              'Voz, colunas e modo frase', () => _abrir(context, const ConfiguracoesView())),
          _item(Icons.child_care, 'Voltar ao modo criança',
              'Fecha este painel', () => Navigator.pop(context)),
          _item(Icons.swap_horiz, 'Trocar perfil',
              'Escolher outra pessoa', () => Navigator.popUntil(context, (r) => r.isFirst)),
          _item(Icons.logout, 'Sair da conta',
              'Encerra a sessão do cuidador', () => _sair(context)),
        ],
      ),
    );
  }
}
