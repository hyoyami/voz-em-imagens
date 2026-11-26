class Cuidador {
  final int? id;
  final String nome;
  final String email;
  final String senhaHash;
  final String pinHash;

  const Cuidador({
    this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
    required this.pinHash,
  });

  factory Cuidador.fromMap(Map<String, Object?> m) => Cuidador(
        id: m['id'] as int?,
        nome: m['nome'] as String,
        email: m['email'] as String,
        senhaHash: m['senha_hash'] as String,
        pinHash: m['pin_hash'] as String,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'nome': nome,
        'email': email,
        'senha_hash': senhaHash,
        'pin_hash': pinHash,
      };
}
