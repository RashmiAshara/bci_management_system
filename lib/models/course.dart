class Course {
  const Course({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    this.description = '',
  });

  final String id;
  final String code;
  final String name;
  final int credits;
  final String description;

  Course copyWith({
    String? code,
    String? name,
    int? credits,
    String? description,
  }) {
    return Course(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => '$code - $name';
}
