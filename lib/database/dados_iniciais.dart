import 'package:sqflite/sqflite.dart';

import '../models/cartao.dart';
import '../models/categoria.dart';

class CartaoInicial {
  final String rotulo;
  final String frase;
  final String emoji;

  const CartaoInicial(this.rotulo, this.frase, this.emoji);
}

class CategoriaInicial {
  final String nome;
  final String cor;
  final List<CartaoInicial> cartoes;

  const CategoriaInicial(this.nome, this.cor, this.cartoes);
}

/// Vocabulário inicial gravado em cada novo perfil.
/// O cuidador pode ocultar, editar ou criar cartões com fotos reais (RF06).
class DadosIniciais {
  static const List<CategoriaInicial> categorias = [
    CategoriaInicial(Categoria.nomeAcessoRapido, '#E57373', [
      CartaoInicial('Banheiro', 'Preciso ir ao banheiro', '🚽'),
      CartaoInicial('Água', 'Quero beber água', '💧'),
      CartaoInicial('Dor', 'Estou com dor', '🤕'),
      CartaoInicial('Ajuda', 'Preciso de ajuda', '🆘'),
      CartaoInicial('Parar', 'Quero parar', '✋'),
    ]),
    CategoriaInicial('Necessidades', '#4DB6AC', [
      CartaoInicial('Xixi', 'Preciso fazer xixi', '🚽'),
      CartaoInicial('Cocô', 'Preciso fazer cocô', '💩'),
      CartaoInicial('Fome', 'Estou com fome', '🍽️'),
      CartaoInicial('Sede', 'Estou com sede', '🥤'),
      CartaoInicial('Sono', 'Estou com sono', '😴'),
      CartaoInicial('Banho', 'Quero tomar banho', '🛁'),
    ]),
    CategoriaInicial('Comida', '#FFB74D', [
      CartaoInicial('Fruta', 'Quero uma fruta', '🍎'),
      CartaoInicial('Pão', 'Quero pão', '🍞'),
      CartaoInicial('Arroz', 'Quero arroz', '🍚'),
      CartaoInicial('Leite', 'Quero leite', '🥛'),
      CartaoInicial('Suco', 'Quero suco', '🧃'),
      CartaoInicial('Bolacha', 'Quero bolacha', '🍪'),
    ]),
    CategoriaInicial('Sentimentos', '#BA68C8', [
      CartaoInicial('Feliz', 'Estou feliz', '😀'),
      CartaoInicial('Triste', 'Estou triste', '😢'),
      CartaoInicial('Bravo', 'Estou bravo', '😠'),
      CartaoInicial('Medo', 'Estou com medo', '😨'),
      CartaoInicial('Cansado', 'Estou cansado', '🥱'),
      CartaoInicial('Abraço', 'Quero um abraço', '🤗'),
    ]),
    CategoriaInicial('Atividades', '#64B5F6', [
      CartaoInicial('Brincar', 'Quero brincar', '🧸'),
      CartaoInicial('Jogar', 'Quero jogar', '🎮'),
      CartaoInicial('Televisão', 'Quero ver televisão', '📺'),
      CartaoInicial('Passear', 'Quero passear', '🚶'),
      CartaoInicial('Música', 'Quero ouvir música', '🎵'),
      CartaoInicial('Desenhar', 'Quero desenhar', '🖍️'),
    ]),
    CategoriaInicial('Respostas', '#81C784', [
      CartaoInicial('Sim', 'Sim', '✅'),
      CartaoInicial('Não', 'Não', '❌'),
      CartaoInicial('Mais', 'Quero mais', '➕'),
      CartaoInicial('Terminei', 'Terminei', '🏁'),
      CartaoInicial('Obrigado', 'Obrigado', '🙏'),
    ]),
  ];

  /// Grava categorias e cartões iniciais de um perfil.
  /// Receba a transação (txn) para que tudo seja salvo junto, ou nada.
  static Future<void> semear(DatabaseExecutor txn, int perfilId) async {
    var ordemCategoria = 0;
    for (final cat in categorias) {
      final categoriaId = await txn.insert('categorias', {
        'perfil_id': perfilId,
        'nome': cat.nome,
        'cor': cat.cor,
        'ordem': ordemCategoria++,
      });
      var ordemCartao = 0;
      for (final c in cat.cartoes) {
        await txn.insert('cartoes', {
          'categoria_id': categoriaId,
          'rotulo': c.rotulo,
          'frase_falada': c.frase,
          'imagem_path': '${Cartao.prefixoEmoji}${c.emoji}',
          'ordem': ordemCartao++,
          'visivel': 1,
        });
      }
    }
  }
}
