import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/profile/controllers/profile_controller.dart';

/// Vista principal del módulo de perfil — ver
/// PRESENTATION_ARCHITECTURE.md §8. Placeholder hasta que exista contenido
/// real.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    
    context.watch<ProfileController>();

    return const Scaffold(
      body: Center(child: Text('Perfil')),
    );
  }
}
