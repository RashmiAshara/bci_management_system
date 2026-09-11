import 'package:flutter/material.dart';

import '../controllers/course_controller.dart';
import '../controllers/enrollment_controller.dart';
import '../models/course.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/form_entry_field.dart';
import '../widgets/management_list_header.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key, required this.courses, required this.enrollment});

  final CourseController courses;
  final EnrollmentController enrollment;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<Course> courses = widget.courses.courses.where((Course course) {
      final String search = _query.toLowerCase();
      return course.id.toLowerCase().contains(search) ||
          course.code.toLowerCase().contains(search) ||
          course.name.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      body: Column(
        children: <Widget>[
          ManagementListHeader(
            title: 'Course Management',
            searchLabel: 'Search courses',
            searchHint: 'Search by ID, code or name',
            onSearchChanged: (String value) => setState(() => _query = value),
          ),
          Expanded(
            child: courses.isEmpty
                ? const Center(child: Text('No courses found.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final Course course = courses[index];
                      final int enrolledCount =
                          widget.enrollment.studentIdsForCourse(course.id).length;
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.menu_book_outlined),
                          ),
                          title: Text(
                            course.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${course.code} • ${course.credits} credit(s)\n'
                            '$enrolledCount student(s) enrolled'
                            '${course.description.isEmpty ? '' : '\n${course.description}'}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (String value) {
                              if (value == 'edit') {
                                _showCourseFormDialog(existing: course);
                              } else if (value == 'delete') {
                                _confirmDelete(course);
                              }
                            },
                            itemBuilder: (_) => const <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourseFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }

  Future<void> _confirmDelete(Course course) async {
    final bool confirmed = await confirmDelete(
      context,
      title: 'Delete course',
      message:
          'Delete ${course.name}? Students currently enrolled in this course will be unenrolled.',
    );

    if (confirmed) {
      widget.courses.removeCourse(course.id);
    }
  }

  Future<void> _showCourseFormDialog({Course? existing}) async {
    final bool isEdit = existing != null;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController idController =
        TextEditingController(text: existing?.id ?? '');
    final TextEditingController codeController =
        TextEditingController(text: existing?.code ?? '');
    final TextEditingController nameController =
        TextEditingController(text: existing?.name ?? '');
    final TextEditingController creditsController =
        TextEditingController(text: existing?.credits.toString() ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: existing?.description ?? '');

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Edit Course' : 'Add Course'),
        content: SizedBox(
          width: 480,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FormEntryField(
                    controller: idController,
                    label: 'Course ID',
                    enabled: !isEdit,
                  ),
                  FormEntryField(controller: codeController, label: 'Course Code'),
                  FormEntryField(controller: nameController, label: 'Course Name'),
                  FormEntryField(
                    controller: creditsController,
                    label: 'Credits',
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Credits is required.';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Enter a whole number.';
                      }
                      return null;
                    },
                  ),
                  FormEntryField(
                    controller: descriptionController,
                    label: 'Description (optional)',
                    maxLines: 3,
                    required: false,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final Course course = Course(
                  id: idController.text.trim(),
                  code: codeController.text.trim(),
                  name: nameController.text.trim(),
                  credits: int.tryParse(creditsController.text.trim()) ?? 0,
                  description: descriptionController.text.trim(),
                );
                if (isEdit) {
                  widget.courses.updateCourse(course);
                } else {
                  widget.courses.addCourse(course);
                }
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    idController.dispose();
    codeController.dispose();
    nameController.dispose();
    creditsController.dispose();
    descriptionController.dispose();
  }
}
