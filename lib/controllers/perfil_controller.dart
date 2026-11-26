import '../database/app_database.dart';
import '../database/dados_iniciais.dart';
import '../models/config_voz.dart';
import '../models/perfil.dart';

/// Perfis de usuários comunicadores (RF03) e suas preferências (RF17).
class PerfilController {
  Future<List<Perfil>> listar(int cuidadorId) async {
    final db = await AppDatabase.instancia.database;
    final r = await db.query(
      'perfis',
      where: 'cuidador_id = ?',
      whereArgs: [cuidadorId],
      orderBy: 'nome COLLATE NOCASE',
    );
    return r.map(Perfil.fromMap).toList();
  }

  /// Cria o perfil e já grava o vocabulário inicial, tudo na mesma transação.
  Future<Perfil> criar({
    required int cuidadorId,
    required String nome,
    String? dataNascimento,
  }) async {
    final db = await AppDatabase.instancia.database;
    final novo = Perfil(
      cuidadorId: cuidadorId,
      nome: nome.trim(),
      dataNascimento: (dataNascimento == null || dataNascimento.trim().isEmpty)
          ? null
          : dataNascimento.trim(),
      config: const ConfigVoz(),
    );

    late int id;
    await db.transaction((txn) async {
      id = await txn.insert('perfis', novo.toMap());
      await DadosIniciais.semear(txn, id);
    });

    return Perfil(
      id: id,
      cuidadorId: novo.cuidadorId,
      nome: novo.nome,
      dataNascimento: novo.dataNascimento,
      config: novo.config,
    );
  }

  /// Apaga o perfil, e por cascata suas categorias, cartões e registros de toque.
  Future<void> excluir(int perfilId) async {
    final db = await AppDatabase.instancia.database;
    await db.delete('perfis', where: 'id = ?', whereArgs: [perfilId]);
  }

  Future<void> salvarConfig(Perfil perfil) async {
    final db = await AppDatabase.instancia.database;
    await db.update(
      'perfis',
      {'voz_config': perfil.config.toJson()},
      where: 'id = ?',
      whereArgs: [perfil.id],
    );
  }
}
