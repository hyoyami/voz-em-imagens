class Cartao {
  /// Os cartões iniciais usam emojis em vez de arquivos de imagem.
  /// Guardamos no campo imagem_path o valor "emoji:🚽". Se for outro valor,
  /// ele é o caminho de uma foto salva no aparelho.
  static const String prefixoEmoji = 'emoji:';

  final int? id;
  final int categoriaId;
  final String rotulo; // "Xixi"
  final String fraseFalada; // "Preciso fazer xixi"
  final String imagemPath;
  final String? audioPath;
  final int ordem;
  final bool visivel;

  const Cartao({
    this.id,
    required this.categoriaId,
    required this.rotulo,
    required this.fraseFalada,
    required this.imagemPath,
    this.audioPath,
    this.ordem = 0,
    this.visivel = true,
  });

  bool get ehEmoji => imagemPath.startsWith(prefixoEmoji);

  String get emoji => ehEmoji ? imagemPath.substring(prefixoEmoji.length) : '';

  String get rotuloComIcone => ehEmoji ? '$emoji $rotulo' : rotulo;

  Cartao copyWith({int? ordem, bool? visivel}) => Cartao(
        id: id,
        categoriaId: categoriaId,
        rotulo: rotulo,
        fraseFalada: fraseFalada,
        imagemPath: imagemPath,
        audioPath: audioPath,
        ordem: ordem ?? this.ordem,
        visivel: visivel ?? this.visivel,
      );

  factory Cartao.fromMap(Map<String, Object?> m) => Cartao(
        id: m['id'] as int?,
        categoriaId: m['categoria_id'] as int,
        rotulo: m['rotulo'] as String,
        fraseFalada: m['frase_falada'] as String,
        imagemPath: m['imagem_path'] as String,
        audioPath: m['audio_path'] as String?,
        ordem: (m['ordem'] as int?) ?? 0,
        visivel: ((m['visivel'] as int?) ?? 1) == 1,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'categoria_id': categoriaId,
        'rotulo': rotulo,
        'frase_falada': fraseFalada,
        'imagem_path': imagemPath,
        'audio_path': audioPath,
        'ordem': ordem,
        'visivel': visivel ? 1 : 0,
      };
}
