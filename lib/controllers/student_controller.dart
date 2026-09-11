import 'package:flutter/foundation.dart';

import '../models/student.dart';
import '../utils/collection_utils.dart';
import 'enrollment_controller.dart';

/// Controller for student records. Depends on [EnrollmentController] only
/// to cascade-delete a removed student's enrollments.
class StudentController extends ChangeNotifier {
  StudentController(this._enrollment);

  final EnrollmentController _enrollment;

  final List<Student> _students = <Student>[
    const Student(
      id: 'BCI-2026-001',
      name: 'Ayesha Perera',
      email: 'ayesha@students.bci.lk',
      program: 'BSc Software Engineering',
      intake: 'February 2026',
      status: 'Active',
    ),
    const Student(
      id: 'BCI-2026-002',
      name: 'Nimal Fernando',
      email: 'nimal@students.bci.lk',
      program: 'BSc Information Technology',
      intake: 'February 2026',
      status: 'Active',
    ),
    const Student(
      id: 'BCI-2025-118',
      name: 'Tharushi Silva',
      email: 'tharushi@students.bci.lk',
      program: 'BSc Computer Science',
      intake: 'September 2025',
      status: 'Active',
    ),
  ];

  List<Student> get students => List<Student>.unmodifiable(_students);

  Student? studentById(String id) => findById(_students, id, (Student s) => s.id);

  int get activeStudentCount =>
      _students.where((Student student) => student.status == 'Active').length;

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void updateStudent(Student student) {
    final int index = _students.indexWhere((Student s) => s.id == student.id);
    if (index == -1) return;
    _students[index] = student;
    notifyListeners();
  }

  void removeStudent(String studentId) {
    _students.removeWhere((Student student) => student.id == studentId);
    _enrollment.removeAllForStudent(studentId);
    notifyListeners();
  }
}
