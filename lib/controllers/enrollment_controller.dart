import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/student.dart';

/// Controller for the student-course enrollment relationship.
///
/// Deliberately has no reference to [StudentController]/[CourseController]
/// so that they can each depend on this controller (for cascade-delete)
/// without creating a dependency cycle. Views that need enrolled *objects*
/// (rather than ids) pass the relevant `xById` lookup in, e.g.
/// `enrollment.coursesForStudent(id, courses.courseById)`.
class EnrollmentController extends ChangeNotifier {
  final List<Enrollment> _enrollments = <Enrollment>[
    Enrollment(
      id: 'ENR-0001',
      studentId: 'BCI-2026-001',
      courseId: 'CRS-1001',
      enrolledOn: DateTime(2026, 2, 3),
    ),
    Enrollment(
      id: 'ENR-0002',
      studentId: 'BCI-2026-001',
      courseId: 'CRS-1002',
      enrolledOn: DateTime(2026, 2, 3),
    ),
    Enrollment(
      id: 'ENR-0003',
      studentId: 'BCI-2026-002',
      courseId: 'CRS-1001',
      enrolledOn: DateTime(2026, 2, 4),
    ),
  ];

  List<Enrollment> get enrollments => List<Enrollment>.unmodifiable(_enrollments);

  List<String> courseIdsForStudent(String studentId) => _enrollments
      .where((Enrollment e) => e.studentId == studentId)
      .map((Enrollment e) => e.courseId)
      .toList();

  List<String> studentIdsForCourse(String courseId) => _enrollments
      .where((Enrollment e) => e.courseId == courseId)
      .map((Enrollment e) => e.studentId)
      .toList();

  /// Resolves a student's enrolled courses via [courseById] (typically
  /// `CourseController.courseById`).
  List<Course> coursesForStudent(String studentId, Course? Function(String id) courseById) {
    return courseIdsForStudent(studentId).map(courseById).whereType<Course>().toList();
  }

  /// Resolves a course's enrolled students via [studentById] (typically
  /// `StudentController.studentById`).
  List<Student> studentsForCourse(String courseId, Student? Function(String id) studentById) {
    return studentIdsForCourse(courseId).map(studentById).whereType<Student>().toList();
  }

  bool isEnrolled(String studentId, String courseId) {
    return _enrollments.any(
      (Enrollment e) => e.studentId == studentId && e.courseId == courseId,
    );
  }

  void enrollStudent(String studentId, String courseId) {
    if (isEnrolled(studentId, courseId)) return;
    _enrollments.add(Enrollment(
      id: 'ENR-${DateTime.now().microsecondsSinceEpoch}',
      studentId: studentId,
      courseId: courseId,
      enrolledOn: DateTime.now(),
    ));
    notifyListeners();
  }

  void unenrollStudent(String studentId, String courseId) {
    _enrollments.removeWhere(
      (Enrollment e) => e.studentId == studentId && e.courseId == courseId,
    );
    notifyListeners();
  }

  /// Removes every enrollment for [studentId]. Called by
  /// `StudentController.removeStudent` when a student is deleted.
  void removeAllForStudent(String studentId) {
    _enrollments.removeWhere((Enrollment e) => e.studentId == studentId);
    notifyListeners();
  }

  /// Removes every enrollment for [courseId]. Called by
  /// `CourseController.removeCourse` when a course is deleted.
  void removeAllForCourse(String courseId) {
    _enrollments.removeWhere((Enrollment e) => e.courseId == courseId);
    notifyListeners();
  }
}
