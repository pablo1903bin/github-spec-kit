import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/home/controllers/home_controller.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/navigation/widgets/app_bottom_nav_bar_widget.dart';

import '../widgets/home_list_item_widget.dart';

/// Vista principal del módulo home — ver PRESENTATION_ARCHITECTURE.md §8.
/// La lista larga es solo para ver el bottom nav (`AppNavigationShell`) en
/// acción con contenido real desplazándose detrás/encima — se reemplaza por
/// contenido real cuando exista.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _cantidadDemo = 30;

  @override
  Widget build(BuildContext context) {
    context.watch<HomeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: ListView.builder(
        // Bottom extra = alto de la cápsula flotante del bottom nav (ver
        // AppBottomNavBar.altura) — sin esto, el último ítem quedaría
        // parcialmente tapado por ella en vez de poder scrollear por
        // completo a la vista.
        padding: const EdgeInsets.fromLTRB(
          0,
          12,
          0,
          12 + AppBottomNavBar.altura,
        ),
        itemCount: _cantidadDemo,
        itemBuilder: (context, index) => HomeListItem(index: index),
      ),
    );
  }
}
