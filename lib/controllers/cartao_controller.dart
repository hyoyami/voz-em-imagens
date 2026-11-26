import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/cartao.dart';

/// Criar, editar, ocultar e excluir cartões (RF06).
class CartaoController {
  /// Todos os cartões do perfil, na ordem das categorias.
  Future<List<Cartao>> listarPorPerfil(
    int perfilId, {
    bool apenasVisiveis = false,
  }) async {
    final db = await AppDatabase.instancia.database;
    final filtro = apenasVisiveis ? 'AND c.visivel = 1' : '';
    final r = await db.rawQuery('''
      SELECT c.*
      FROM cartoes c
      JOIN categorias g ON g.id = c.categoria_id
      WHERE g.perfil_id = ? $filtro
      ORDER BY g.ordem, c.ordem, c.id
    ''', [perfilId]);
    return r.map(Cartao.fromMap).toList();
  }

  /// Insere (id == null) ou atualiza o cartão. Devolve o id.
  Future<int> salvar(Cartao cartao) async {
    final db = await AppDatabase.instancia.database;
    if (cartao.id == null) {
      final maior = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT MAX(ordem) FROM cartoes WHERE categoria_id = ?',
            [cartao.categoriaId],
          )) ??
          -1;
      return db.insert('cartoes', cartao.copyWith(ordem: maior + 1).toMap());
    }
    await db.update(
      'cartoes',
      cartao.toMap(),
      where: 'id = ?',
      whereArgs: [cartao.id],
    );
    return cartao.id!;
  }

  Future<void> definirVisivel(Cartao cartao, bool visivel) async {
    final db = await AppDatabase.instancia.database;
    await db.update(
      'cartoes',
      {'visivel': visivel ? 1 : 0},
      where: 'id = ?',
      whereArgs: [cartao.id],
    );
  }

  /// RN04: cartão que já tem toques registrados NÃO é apagado, só ocultado,
  /// para preservar o histórico dos relatórios.
  /// Devolve true se foi excluído e false se apenas foi ocultado.
  Future<bool> excluirOuOcultar(Cartao cartao) async {
    final db = await AppDatabase.instancia.database;
    final usos = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM eventos_toque WHERE cartao_id = ?',
          [cartao.id],
        )) ??
        0;

    if (usos > 0) {
      await definirVisivel(cartao, false);
      return false;
    }
    await db.delete('cartoes', where: 'id = ?', whereArgs: [cartao.id]);
    return true;
  }

  /// Copia a foto escolhida para a pasta do app (a foto da galeria pode ser
  /// apagada ou movida pelo usuário) e devolve o novo caminho.
  Future<String> copiarImagem(String origem) async {
    final dir = await getApplicationDocumentsDirectory();
    final pasta = Directory(p.join(dir.path, 'cartoes'));
    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }
    final nome = '${DateTime.now().millisecondsSinceEpoch}${p.extension(origem)}';
    final destino = p.join(pasta.path, nome);
    await File(origem).copy(destino);
    return destino;
  }
}
