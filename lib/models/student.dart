class Student {
  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.program,
    required this.intake,
    required this.status,
  });

  final String id;
  final String name;
  final String email;
  final String program;
  final String intake;
  final String status;

  Student copyWith({
    String? name,
    String? email,
    String? program,
    String? intake,
    String? status,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      program: program ?? this.program,
      intake: intake ?? this.intake,
      status: status ?? this.status,
    );
  }
}
