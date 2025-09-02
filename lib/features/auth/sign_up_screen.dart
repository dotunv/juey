import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'widgets/auth_form_field.dart';
import 'widgets/auth_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords don’t match")));
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signup successful! Please verify your email."),
          ),
        );
        context.go('/sign-in');
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error occurred")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Juey",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  AuthFormField(
                    controller: _emailController,
                    labelText: "Email",
                    validator: (value) => value == null || value.isEmpty
                        ? "Enter your email"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  AuthFormField(
                    controller: _passwordController,
                    labelText: "Password",
                    obscureText: true,
                    validator: (value) => value == null || value.length < 6
                        ? "Password must be at least 6 chars"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  AuthFormField(
                    controller: _confirmPasswordController,
                    labelText: "Confirm Password",
                    obscureText: true,
                    validator: (value) => value == null || value.isEmpty
                        ? "Confirm your password"
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Signup Button
                  AuthButton(
                    label: "Join Juey 🚀",
                    onPressed: _signup,
                    loading: _loading,
                  ),
                  const SizedBox(height: 16),

                  // Go to Signin
                  TextButton(
                    onPressed: () {
                      context.go('/sign-in');
                    },
                    child: const Text("Already have an account? Sign in"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
