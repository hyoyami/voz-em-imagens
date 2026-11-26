import 'package:flutter/material.dart';


class Avisos {
  static void mostrar(BuildContext context, String mensagem) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(mensagem)));
  }
}
