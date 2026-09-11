import 'package:flutter/material.dart';

/// The screen title + search field header shared by the management list
/// screens (students, employees, courses).
class ManagementListHeader extends StatelessWidget {
  const ManagementListHeader({
    super.key,
    required this.title,
    required this.searchLabel,
    required this.searchHint,
    required this.onSearchChanged,
  });

  final String title;
  final String searchLabel;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: InputDecoration(
              labelText: searchLabel,
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
        ],
      ),
    );
  }
}
