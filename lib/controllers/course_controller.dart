import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../utils/collection_utils.dart';
import 'enrollment_controller.dart';

/// Controller for course records. Depends on [EnrollmentController] only
/// to cascade-delete a removed course's enrollments.
class CourseController extends ChangeNotifier {
  CourseController(this._enrollment);

  final EnrollmentController _enrollment;

  final List<Course> _courses = <Course>[
    const Course(
      id: 'CRS-1001',
      code: 'CS101',
      name: 'Introduction to Programming',
      credits: 3,
      description: 'Fundamentals of programming using a modern language.',
    ),
    const Course(
      id: 'CRS-1002',
      code: 'CS205',
      name: 'Database Systems',
      credits: 4,
      description: 'Relational database design, SQL and normalisation.',
    ),
    const Course(
      id: 'CRS-1003',
      code: 'SE210',
      name: 'Software Engineering Practices',
      credits: 3,
      description: 'Software development lifecycle, testing and teamwork.',
    ),
  ];

  List<Course> get courses => List<Course>.unmodifiable(_courses);

  Course? courseById(String id) => findById(_courses, id, (Course c) => c.id);

  void addCourse(Course course) {
    _courses.add(course);
    notifyListeners();
  }

  void updateCourse(Course course) {
    final int index = _courses.indexWhere((Course c) => c.id == course.id);
    if (index == -1) return;
    _courses[index] = course;
    notifyListeners();
  }

  void removeCourse(String courseId) {
    _courses.removeWhere((Course course) => course.id == courseId);
    _enrollment.removeAllForCourse(courseId);
    notifyListeners();
  }
}
