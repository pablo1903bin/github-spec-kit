import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/home/controllers/home_controller.dart';

/// Vista principal del módulo home — ver PRESENTATION_ARCHITECTURE.md §8.
/// Placeholder hasta que exista contenido real.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<HomeController>();

    return const Scaffold(
      body: Center(child: Text('Home')),
    );
  }
}
