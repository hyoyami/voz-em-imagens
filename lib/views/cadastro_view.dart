import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../widgets/widget_avisos.dart';
import '../widgets/widget_botao.dart';
import '../widgets/widget_campo_texto.dart';
import '../widgets/widget_texto.dart';
import 'selecao_perfil_view.dart';


class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _pin = TextEditingController();
  final AuthController _auth = AuthController();
  bool _carregando = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    setState(() => _carregando = true);
    final erro = await _auth.cadastrar(
      nome: _nome.text,
      email: _email.text,
      senha: _senha.text,
      pin: _pin.text,
    );
    if (!mounted) return;

    if (erro != null) {
      setState(() => _carregando = false);
      Avisos.mostrar(context, erro);
      return;
    }

    // Cadastro feito: já entra com a conta nova.
    await _auth.entrar(_email.text, _senha.text);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SelecaoPerfilView()),
      (rota) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CampoTexto(rotulo: 'Seu nome', controller: _nome),
            const SizedBox(height: 16),
            CampoTexto(
              rotulo: 'E-mail',
              controller: _email,
              teclado: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CampoTexto(
              rotulo: 'Senha (mínimo 6 caracteres)',
              controller: _senha,
              obscuro: true,
            ),
            const SizedBox(height: 16),
            CampoTexto(
              rotulo: 'PIN do modo cuidador (4 números)',
              controller: _pin,
              obscuro: true,
              teclado: TextInputType.number,
              maxLength: 4,
            ),
            const SizedBox(height: 8),
            const Textos(
              'O PIN protege as configurações e os relatórios: a criança só '
              'consegue sair do modo criança com ele.',
              tamanho: 13,
            ),
            const SizedBox(height: 24),
            Botoes(
              _carregando ? 'Salvando...' : 'Criar conta',
              icone: Icons.check,
              onPressed: _carregando ? null : _cadastrar,
            ),
          ],
        ),
      ),
    );
  }
}
