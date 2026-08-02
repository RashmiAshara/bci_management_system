class Enrollment {
  const Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.enrolledOn,
  });

  final String id;
  final String studentId;
  final String courseId;
  final DateTime enrolledOn;
}
