/// Registro local. Não representa um protocolo oficial da Prefeitura.
class Occurrence {
  final String id, type, address, description;
  final DateTime createdAt;
  final String? photoPath;
  const Occurrence({
    required this.id,
    required this.type,
    required this.address,
    required this.description,
    required this.createdAt,
    this.photoPath,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'address': address,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'photoPath': photoPath,
  };
  factory Occurrence.fromJson(Map<String, dynamic> json) => Occurrence(
    id: json['id'] as String,
    type: json['type'] as String,
    address: json['address'] as String,
    description: json['description'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    photoPath: json['photoPath'] as String?,
  );
}
