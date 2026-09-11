import 'package:flutter/material.dart';

/// A labelled [TextFormField] with the standard spacing/border and a
/// default "required" validator, used across the record entry forms
/// (students, employees, courses).
///
/// Pass [validator] to override the default required-field check with
/// field-specific validation (e.g. an email or numeric-amount check).
/// Pass `required: false` for an optional field with no default validator.
class FormEntryField extends StatelessWidget {
  const FormEntryField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.required = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool enabled;
  final int maxLines;
  final bool required;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? (required ? _requiredValidator : null),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }
}
