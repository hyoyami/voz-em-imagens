/// Um toque em um cartão. Cada toque válido gera um registro (RN01).
class EventoToque {
  final int? id;
  final int perfilId;
  final int cartaoId;
  final DateTime dataHora;

  const EventoToque({
    this.id,
    required this.perfilId,
    required this.cartaoId,
    required this.dataHora,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'perfil_id': perfilId,
        'cartao_id': cartaoId,
        'data_hora': dataHora.toIso8601String(),
      };
}
