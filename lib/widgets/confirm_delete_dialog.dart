import 'package:flutter/material.dart';

/// Shows a standard Cancel/Delete confirmation dialog and returns `true`
/// if the user confirmed the deletion, `false` otherwise (including if the
/// dialog was dismissed).
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
