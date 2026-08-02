class Module {
  const Module({required this.id, required this.code, required this.name});

  final String id;
  final String code;
  final String name;

  @override
  String toString() => '$code - $name';
}
