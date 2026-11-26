import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/cuidador.dart';
import '../utils/seguranca.dart';
import 'sessao.dart';


class AuthController {
  static const String _chaveCuidador = 'cuidador_id';


  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String pin,
  }) async {
    final emailNorm = email.trim().toLowerCase();
    if (nome.trim().isEmpty) return 'Informe seu nome.';
    if (!emailNorm.contains('@') || !emailNorm.contains('.')) {
      return 'Informe um e-mail válido.';
    }
    if (senha.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return 'O PIN deve ter exatamente 4 números.';
    }

    try {
      final db = await AppDatabase.instancia.database;
      final cuidador = Cuidador(
        nome: nome.trim(),
        email: emailNorm,
        senhaHash: Seguranca.hashSenha(emailNorm, senha),
        pinHash: Seguranca.hashPin(emailNorm, pin),
      );
      await db.insert('cuidadores', cuidador.toMap());
      return null;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) return 'Este e-mail já está cadastrado.';
      return 'Não foi possível salvar o cadastro.';
    }
  }


  Future<Cuidador?> entrar(String email, String senha) async {
    final emailNorm = email.trim().toLowerCase();
    final db = await AppDatabase.instancia.database;
    final r = await db.query(
      'cuidadores',
      where: 'email = ? AND senha_hash = ?',
      whereArgs: [emailNorm, Seguranca.hashSenha(emailNorm, senha)],
      limit: 1,
    );
    if (r.isEmpty) return null;

    final cuidador = Cuidador.fromMap(r.first);
    Sessao.cuidador = cuidador;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveCuidador, cuidador.id!);
    return cuidador;
  }


  Future<Cuidador?> restaurarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_chaveCuidador);
    if (id == null) return null;

    final db = await AppDatabase.instancia.database;
    final r = await db.query(
      'cuidadores',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (r.isEmpty) {
      await prefs.remove(_chaveCuidador);
      return null;
    }
    Sessao.cuidador = Cuidador.fromMap(r.first);
    return Sessao.cuidador;
  }

  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveCuidador);
    Sessao.limpar();
  }


  Future<bool> validarPin(String pin) async {
    final cuidador = Sessao.cuidador;
    if (cuidador == null) return false;
    return Seguranca.hashPin(cuidador.email, pin) == cuidador.pinHash;
  }
}
