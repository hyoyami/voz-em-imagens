import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../widgets/widget_avisos.dart';
import '../widgets/widget_botao.dart';
import '../widgets/widget_campo_texto.dart';
import '../widgets/widget_texto.dart';
import 'cadastro_view.dart';
import 'selecao_perfil_view.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final AuthController _auth = AuthController();
  bool _carregando = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() => _carregando = true);
    final cuidador = await _auth.entrar(_email.text, _senha.text);
    if (!mounted) return;
    setState(() => _carregando = false);

    if (cuidador == null) {
      Avisos.mostrar(context, 'E-mail ou senha inválidos.');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SelecaoPerfilView()),
    );
  }

  void _abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.record_voice_over,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Textos(
              'Voz em Imagens',
              tamanho: 28,
              negrito: true,
              alinhamento: TextAlign.center,
            ),
            const Textos(
              'Comunicação por imagens',
              alinhamento: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CampoTexto(
              rotulo: 'E-mail do cuidador',
              controller: _email,
              teclado: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CampoTexto(rotulo: 'Senha', controller: _senha, obscuro: true),
            const SizedBox(height: 24),
            Botoes(
              _carregando ? 'Entrando...' : 'Entrar',
              icone: Icons.login,
              onPressed: _carregando ? null : _entrar,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _abrirCadastro,
              child: const Text('Criar conta de cuidador'),
            ),
          ],
        ),
      ),
    );
  }
}
