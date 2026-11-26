class Categoria {
  /// Categoria especial: seus cartões aparecem sempre na linha de acesso rápido (RF07).
  static const String nomeAcessoRapido = 'Acesso rápido';

  final int? id;
  final int perfilId;
  final String nome;
  final String? cor; // "#RRGGBB"
  final int ordem;

  const Categoria({
    this.id,
    required this.perfilId,
    required this.nome,
    this.cor,
    this.ordem = 0,
  });

  factory Categoria.fromMap(Map<String, Object?> m) => Categoria(
        id: m['id'] as int?,
        perfilId: m['perfil_id'] as int,
        nome: m['nome'] as String,
        cor: m['cor'] as String?,
        ordem: (m['ordem'] as int?) ?? 0,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'perfil_id': perfilId,
        'nome': nome,
        'cor': cor,
        'ordem': ordem,
      };
}
