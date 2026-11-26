import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/relatorio.dart';

/// Gera os relatórios semanal, mensal e anual (RF09, RF10, RF15).
/// Tudo é calculado com consultas na tabela eventos_toque.
class RelatorioController {
  Future<Relatorio> gerar({
    required int perfilId,
    required PeriodoRelatorio periodo,
    DateTime? agora,
  }) async {
    final db = await AppDatabase.instancia.database;
    final inicio = periodo.inicio(agora ?? DateTime.now());
    // As datas são gravadas em ISO 8601, que pode ser comparado como texto.
    final desde = inicio.toIso8601String();

    final total = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM eventos_toque WHERE perfil_id = ? AND data_hora >= ?',
          [perfilId, desde],
        )) ??
        0;

    // Cartões mais usados (top 10).
    final linhasRanking = await db.rawQuery('''
      SELECT c.id AS id, c.rotulo AS rotulo, c.imagem_path AS imagem_path,
             COUNT(*) AS total
      FROM eventos_toque e
      JOIN cartoes c ON c.id = e.cartao_id
      WHERE e.perfil_id = ? AND e.data_hora >= ?
      GROUP BY c.id
      ORDER BY total DESC, c.rotulo
      LIMIT 10
    ''', [perfilId, desde]);

    // Uso por categoria.
    final linhasCategoria = await db.rawQuery('''
      SELECT g.nome AS nome, COUNT(*) AS total
      FROM eventos_toque e
      JOIN cartoes c ON c.id = e.cartao_id
      JOIN categorias g ON g.id = c.categoria_id
      WHERE e.perfil_id = ? AND e.data_hora >= ?
      GROUP BY g.id
      ORDER BY total DESC
    ''', [perfilId, desde]);

    // Horários de pico: a hora são os caracteres 12 e 13 do texto ISO ("2026-11-08T14:32:10").
    final linhasHora = await db.rawQuery('''
      SELECT CAST(substr(data_hora, 12, 2) AS INTEGER) AS hora, COUNT(*) AS total
      FROM eventos_toque
      WHERE perfil_id = ? AND data_hora >= ?
      GROUP BY hora
    ''', [perfilId, desde]);

    final porHora = List<int>.filled(24, 0);
    for (final l in linhasHora) {
      final hora = l['hora'] as int;
      if (hora >= 0 && hora < 24) {
        porHora[hora] = l['total'] as int;
      }
    }

    return Relatorio(
      periodo: periodo,
      inicio: inicio,
      totalToques: total,
      ranking: [
        for (final l in linhasRanking)
          ItemRanking(
            cartaoId: l['id'] as int,
            rotulo: l['rotulo'] as String,
            imagemPath: l['imagem_path'] as String,
            total: l['total'] as int,
          )
      ],
      porCategoria: [
        for (final l in linhasCategoria)
          ItemCategoria(nome: l['nome'] as String, total: l['total'] as int)
      ],
      porHora: porHora,
    );
  }
}
