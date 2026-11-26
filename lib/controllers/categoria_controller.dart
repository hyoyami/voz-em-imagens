import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/categoria.dart';

class CategoriaController {
  Future<List<Categoria>> listar(int perfilId) async {
    final db = await AppDatabase.instancia.database;
    final r = await db.query(
      'categorias',
      where: 'perfil_id = ?',
      whereArgs: [perfilId],
      orderBy: 'ordem, id',
    );
    return r.map(Categoria.fromMap).toList();
  }

  Future<int> criar(int perfilId, String nome) async {
    final db = await AppDatabase.instancia.database;
    final maior = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT MAX(ordem) FROM categorias WHERE perfil_id = ?',
          [perfilId],
        )) ??
        -1;
    return db.insert(
      'categorias',
      Categoria(
        perfilId: perfilId,
        nome: nome.trim(),
        cor: '#90A4AE',
        ordem: maior + 1,
      ).toMap(),
    );
  }
}
