import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Proteção simples das credenciais locais (RNF06).
/// Senha e PIN nunca são gravados em texto simples: guardamos apenas o hash SHA-256
/// combinado com o e-mail do cuidador (que funciona como "sal").
class Seguranca {
  static String hashSenha(String email, String senha) =>
      _hash('senha:${email.trim().toLowerCase()}:$senha');

  static String hashPin(String email, String pin) =>
      _hash('pin:${email.trim().toLowerCase()}:$pin');

  static String _hash(String texto) =>
      sha256.convert(utf8.encode(texto)).toString();
}
