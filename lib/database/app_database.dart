import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Abre o banco SQLite local e cria as tabelas (aula 14 - SqLite).
/// As tabelas seguem o DER da documentação (seção 5.2).
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instancia = AppDatabase._();

  static const String _nomeBanco = 'voz_em_imagens.db';
  static const int _versao = 1;

  Future<Database>? _abrindo;

  /// Devolve sempre o mesmo banco; abre (ou cria) na primeira chamada.
  Future<Database> get database => _abrindo ??= _abrir();

  Future<Database> _abrir() async {
    final caminho = join(await getDatabasesPath(), _nomeBanco);
    return openDatabase(
      caminho,
      version: _versao,
      onConfigure: (db) async {
        // Sem isto o SQLite ignora as chaves estrangeiras e o ON DELETE CASCADE.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _criarTabelas,
    );
  }

  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE cuidadores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha_hash TEXT NOT NULL,
        pin_hash TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE perfis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cuidador_id INTEGER NOT NULL
          REFERENCES cuidadores(id) ON DELETE CASCADE,
        nome TEXT NOT NULL,
        data_nascimento TEXT,
        voz_config TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        perfil_id INTEGER NOT NULL
          REFERENCES perfis(id) ON DELETE CASCADE,
        nome TEXT NOT NULL,
        cor TEXT,
        ordem INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE cartoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoria_id INTEGER NOT NULL
          REFERENCES categorias(id) ON DELETE CASCADE,
        rotulo TEXT NOT NULL,
        frase_falada TEXT NOT NULL,
        imagem_path TEXT NOT NULL,
        audio_path TEXT,
        ordem INTEGER NOT NULL DEFAULT 0,
        visivel INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE eventos_toque (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        perfil_id INTEGER NOT NULL
          REFERENCES perfis(id) ON DELETE CASCADE,
        cartao_id INTEGER NOT NULL
          REFERENCES cartoes(id),
        data_hora TEXT NOT NULL
      )
    ''');

    // Acelera os relatórios (consultas por perfil e período).
    await db.execute(
      'CREATE INDEX idx_toque_perfil_data ON eventos_toque (perfil_id, data_hora)',
    );
    await db.execute(
      'CREATE INDEX idx_toque_cartao ON eventos_toque (cartao_id)',
    );
  }
}
