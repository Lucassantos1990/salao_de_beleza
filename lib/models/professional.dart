class Professional {
  final String id;
  final String name;
  final String specialty;

  Professional({
    required this.id,
    required this.name,
    required this.specialty,
  });

  factory Professional.fromMap(Map<String, dynamic> data) {
    return Professional(
      id: data['id'],
      name: data['name'],
      specialty: data['specialty'] ?? '',
    );
  }
}