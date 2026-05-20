class CigaretteLog {
  final int? id;
  final DateTime smokedAt;
  final String? context;

  const CigaretteLog({
    this.id,
    required this.smokedAt,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'smokedAt': smokedAt.toIso8601String(),
        'context': context,
      };

  factory CigaretteLog.fromJson(Map<String, dynamic> json) => CigaretteLog(
        id: json['id'] as int?,
        smokedAt: DateTime.parse(json['smokedAt'] as String),
        context: json['context'] as String?,
      );
}
