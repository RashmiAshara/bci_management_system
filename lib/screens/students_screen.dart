import 'package:flutter/material.dart';

import '../controllers/course_controller.dart';
import '../controllers/enrollment_controller.dart';
import '../controllers/student_controller.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/form_entry_field.dart';
import '../widgets/management_list_header.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({
    super.key,
    required this.students,
    required this.courses,
    required this.enrollment,
  });

  final StudentController students;
  final CourseController courses;
  final EnrollmentController enrollment;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _query = '';

  static const List<String> _statusOptions = <String>[
    'Active',
    'Inactive',
    'Graduated',
    'Suspended',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Student> students = widget.students.students.where((Student student) {
      final String search = _query.toLowerCase();
      return student.id.toLowerCase().contains(search) ||
          student.name.toLowerCase().contains(search) ||
          student.program.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      body: Column(
        children: <Widget>[
          ManagementListHeader(
            title: 'Student Management',
            searchLabel: 'Search students',
            searchHint: 'Search by ID, name or programme',
            onSearchChanged: (String value) => setState(() => _query = value),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text('No students found.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final Student student = students[index];
                      final List<Course> enrolledCourses = widget.enrollment
                          .coursesForStudent(student.id, widget.courses.courseById);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    student.name.isEmpty
                                        ? '?'
                                        : student.name[0].toUpperCase(),
                                  ),
                                ),
                                title: Text(
                                  student.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${student.id} • ${student.status}\n${student.program}\n${student.email}',
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (String value) {
                                    if (value == 'edit') {
                                      _showStudentFormDialog(existing: student);
                                    } else if (value == 'enroll') {
                                      _showEnrollmentDialog(student);
                                    } else if (value == 'delete') {
                                      _confirmDelete(student);
                                    }
                                  },
                                  itemBuilder: (_) => const <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'enroll',
                                      child: Text('Manage Enrollment'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: <Widget>[
                                    Text(
                                      'Enrolled courses:',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (enrolledCourses.isEmpty)
                                      const Text(
                                        'None',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      )
                                    else
                                      ...enrolledCourses.map(
                                        (Course course) => Chip(
                                          label: Text(course.code),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                  ],
                                ),
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
        onPressed: () => _showStudentFormDialog(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Student'),
      ),
    );
  }

  Future<void> _confirmDelete(Student student) async {
    final bool confirmed = await confirmDelete(
      context,
      title: 'Delete student',
      message: 'Delete ${student.name} from the system?',
    );

    if (confirmed) {
      widget.students.removeStudent(student.id);
    }
  }

  Future<void> _showEnrollmentDialog(Student student) async {
    final List<Course> allCourses = widget.courses.courses;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('Enrol ${student.name}'),
            content: SizedBox(
              width: 480,
              child: allCourses.isEmpty
                  ? const Text('No courses available. Add a course first.')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: allCourses.map((Course course) {
                          final bool enrolled =
                              widget.enrollment.isEnrolled(student.id, course.id);
                          return CheckboxListTile(
                            value: enrolled,
                            title: Text(course.name),
                            subtitle: Text('${course.code} • ${course.credits} credit(s)'),
                            onChanged: (bool? value) {
                              if (value == true) {
                                widget.enrollment.enrollStudent(student.id, course.id);
                              } else {
                                widget.enrollment.unenrollStudent(student.id, course.id);
                              }
                              setDialogState(() {});
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
            ),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showStudentFormDialog({Student? existing}) async {
    final bool isEdit = existing != null;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController idController =
        TextEditingController(text: existing?.id ?? '');
    final TextEditingController nameController =
        TextEditingController(text: existing?.name ?? '');
    final TextEditingController emailController =
        TextEditingController(text: existing?.email ?? '');
    final TextEditingController programmeController =
        TextEditingController(text: existing?.program ?? '');
    final TextEditingController intakeController =
        TextEditingController(text: existing?.intake ?? '');
    String status = existing?.status ?? 'Active';

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Student' : 'Register Student'),
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
                        label: 'Student ID',
                        enabled: !isEdit,
                      ),
                      FormEntryField(controller: nameController, label: 'Full Name'),
                      FormEntryField(
                        controller: emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required.';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      FormEntryField(
                        controller: programmeController,
                        label: 'Programme',
                      ),
                      FormEntryField(controller: intakeController, label: 'Intake'),
                      if (isEdit) ...<Widget>[
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: _statusOptions
                              .map((String s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              setDialogState(() => status = value);
                            }
                          },
                        ),
                      ],
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
                    final Student student = Student(
                      id: idController.text.trim(),
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      program: programmeController.text.trim(),
                      intake: intakeController.text.trim(),
                      status: status,
                    );
                    if (isEdit) {
                      widget.students.updateStudent(student);
                    } else {
                      widget.students.addStudent(student);
                    }
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    idController.dispose();
    nameController.dispose();
    emailController.dispose();
    programmeController.dispose();
    intakeController.dispose();
  }
}
