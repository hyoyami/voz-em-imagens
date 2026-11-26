import 'dart:convert';

/// Preferências de cada perfil. É gravada como JSON na coluna perfis.voz_config.
class ConfigVoz {
  final double velocidade; // 0.2 a 1.0
  final int colunas; // 2 a 4
  final bool modoFrase; // true = toques montam uma frase na barra de frase

  const ConfigVoz({
    this.velocidade = 0.5,
    this.colunas = 2,
    this.modoFrase = false,
  });

  ConfigVoz copyWith({double? velocidade, int? colunas, bool? modoFrase}) =>
      ConfigVoz(
        velocidade: velocidade ?? this.velocidade,
        colunas: colunas ?? this.colunas,
        modoFrase: modoFrase ?? this.modoFrase,
      );

  String toJson() => jsonEncode({
        'velocidade': velocidade,
        'colunas': colunas,
        'modoFrase': modoFrase,
      });

  factory ConfigVoz.fromJson(String? texto) {
    if (texto == null || texto.isEmpty) return const ConfigVoz();
    try {
      final m = jsonDecode(texto) as Map<String, dynamic>;
      return ConfigVoz(
        velocidade: (m['velocidade'] as num?)?.toDouble() ?? 0.5,
        colunas: (m['colunas'] as num?)?.toInt() ?? 2,
        modoFrase: m['modoFrase'] as bool? ?? false,
      );
    } catch (_) {
      return const ConfigVoz();
    }
  }
}
