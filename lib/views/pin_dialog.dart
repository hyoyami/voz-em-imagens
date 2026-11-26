import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/auth_controller.dart';

/// Pede o PIN do cuidador. Devolve true se o PIN estiver correto (RN02).
Future<bool> pedirPin(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _PinDialog(),
  );
  return ok ?? false;
}

class _PinDialog extends StatefulWidget {
  const _PinDialog();

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final TextEditingController _pin = TextEditingController();
  final AuthController _auth = AuthController();
  String? _erro;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _validar() async {
    final ok = await _auth.validarPin(_pin.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _erro = 'PIN incorreto.');
      _pin.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modo cuidador'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Digite o PIN de 4 números para continuar.'),
          const SizedBox(height: 12),
          TextField(
            controller: _pin,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'PIN',
              errorText: _erro,
              counterText: '',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _validar(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _validar, child: const Text('Entrar')),
      ],
    );
  }
}
