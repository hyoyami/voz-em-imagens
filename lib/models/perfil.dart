import 'config_voz.dart';

/// Pessoa que usa o aplicativo para se comunicar (a criança, por exemplo).
class Perfil {
  final int? id;
  final int cuidadorId;
  final String nome;
  final String? dataNascimento;
  final ConfigVoz config;

  const Perfil({
    this.id,
    required this.cuidadorId,
    required this.nome,
    this.dataNascimento,
    this.config = const ConfigVoz(),
  });

  Perfil copyWith({ConfigVoz? config}) => Perfil(
        id: id,
        cuidadorId: cuidadorId,
        nome: nome,
        dataNascimento: dataNascimento,
        config: config ?? this.config,
      );

  factory Perfil.fromMap(Map<String, Object?> m) => Perfil(
        id: m['id'] as int?,
        cuidadorId: m['cuidador_id'] as int,
        nome: m['nome'] as String,
        dataNascimento: m['data_nascimento'] as String?,
        config: ConfigVoz.fromJson(m['voz_config'] as String?),
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'cuidador_id': cuidadorId,
        'nome': nome,
        'data_nascimento': dataNascimento,
        'voz_config': config.toJson(),
      };
}
