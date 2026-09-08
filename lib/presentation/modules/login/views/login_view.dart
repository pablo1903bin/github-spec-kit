import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/login/controllers/login_controller.dart';

/// Vista principal del módulo de login — ver
/// PRESENTATION_ARCHITECTURE.md §8. Placeholder hasta que exista el flujo
/// real de autenticación.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LoginController>();

    return const Scaffold(
      body: Center(child: Text('Login')),
    );
  }
}
