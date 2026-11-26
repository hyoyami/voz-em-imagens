import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import 'login_view.dart';
import 'selecao_perfil_view.dart';


class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  final AuthController _auth = AuthController();

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final cuidador = await _auth.restaurarSessao();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            cuidador == null ? const LoginView() : const SelecaoPerfilView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
