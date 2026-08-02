import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../state/bci_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.store});

  final BciStore store;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bool success = widget.store.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() {
      _error = success ? null : 'Invalid email or password.';
    });
  }

  void _useDemoAccount(AppUser user) {
    _emailController.text = user.email;
    _passwordController.text = user.password;
    widget.store.login(user.email, user.password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool wide = constraints.maxWidth >= 680;
                    final Widget form = _buildForm(context);
                    final Widget demoList = _buildDemoAccountList(context);

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(child: form),
                          const SizedBox(width: 28),
                          SizedBox(width: 260, child: demoList),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        form,
                        const SizedBox(height: 24),
                        demoList,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'BCI Integrated Management System',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in to continue',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Password is required.';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Login'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoAccountList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Demo accounts',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'For classroom demonstration only.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        ...widget.store.demoAccounts.map(
          (AppUser user) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              title: Text(user.role.label, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(user.email),
              trailing: const Icon(Icons.login, size: 18),
              onTap: () => _useDemoAccount(user),
            ),
          ),
        ),
      ],
    );
  }
}
