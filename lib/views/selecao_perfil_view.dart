import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/perfil_controller.dart';
import '../controllers/sessao.dart';
import '../models/perfil.dart';
import '../services/voz_service.dart';
import '../widgets/widget_avisos.dart';
import '../widgets/widget_botao.dart';
import '../widgets/widget_campo_texto.dart';
import '../widgets/widget_texto.dart';
import 'comunicacao_view.dart';
import 'login_view.dart';

/// Lista os perfis do cuidador, cria novos e abre o modo criança (RF03).
class SelecaoPerfilView extends StatefulWidget {
  const SelecaoPerfilView({super.key});

  @override
  State<SelecaoPerfilView> createState() => _SelecaoPerfilViewState();
}

class _SelecaoPerfilViewState extends State<SelecaoPerfilView> {
  final PerfilController _ctrl = PerfilController();
  final AuthController _auth = AuthController();
  List<Perfil> _perfis = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final cuidador = Sessao.cuidador;
    if (cuidador == null) return;
    final lista = await _ctrl.listar(cuidador.id!);
    if (!mounted) return;
    setState(() {
      _perfis = lista;
      _carregando = false;
    });
  }

  Future<void> _novoPerfil() async {
    final nome = TextEditingController();
    final nascimento = TextEditingController();

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CampoTexto(rotulo: 'Nome', controller: nome),
              const SizedBox(height: 12),
              CampoTexto(
                rotulo: 'Data de nascimento (opcional)',
                controller: nascimento,
                dica: 'dd/mm/aaaa',
                teclado: TextInputType.datetime,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;
    if (nome.text.trim().isEmpty) {
      Avisos.mostrar(context, 'Informe o nome do perfil.');
      return;
    }

    await _ctrl.criar(
      cuidadorId: Sessao.cuidador!.id!,
      nome: nome.text,
      dataNascimento: nascimento.text,
    );
    await _carregar();
  }

  Future<void> _confirmarExclusao(Perfil perfil) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir ${perfil.nome}?'),
        content: const Text(
          'Isto apaga o perfil, todos os cartões e todo o histórico de uso. '
          'Não é possível desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;
    await _ctrl.excluir(perfil.id!);
    await _carregar();
  }

  Future<void> _abrirPerfil(Perfil perfil) async {
    Sessao.perfil = perfil;
    await VozService.instancia.definirVelocidade(perfil.config.velocidade);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComunicacaoView()),
    );
  }

  Future<void> _sair() async {
    await _auth.sair();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (rota) => false,
    );
  }

  Widget _lista() {
    if (_perfis.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Textos(
            'Nenhum perfil ainda.\nToque em "Novo perfil" para cadastrar a '
            'primeira pessoa que vai usar o aplicativo.',
            alinhamento: TextAlign.center,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final p in _perfis)
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 26,
                child: Text(
                  p.nome.isEmpty ? '?' : p.nome[0].toUpperCase(),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              title: Text(p.nome, style: const TextStyle(fontSize: 20)),
              subtitle: const Text('Toque para abrir o modo criança'),
              trailing: IconButton(
                tooltip: 'Excluir perfil',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmarExclusao(p),
              ),
              onTap: () => _abrirPerfil(p),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cuidador = Sessao.cuidador;
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${cuidador?.nome ?? ''}'),
        actions: [
          IconButton(
            tooltip: 'Sair da conta',
            icon: const Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _lista(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Botoes(
                'Novo perfil',
                icone: Icons.person_add_alt_1,
                onPressed: _novoPerfil,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
