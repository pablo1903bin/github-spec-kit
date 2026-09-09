import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';
import 'package:spec_kit_flutter_lab/presentation/global/widgets/design/glass_container.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/home/controllers/home_controller.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/navigation/widgets/app_bottom_nav_bar_widget.dart';

import '../widgets/home_background_widget.dart';
import '../widgets/home_list_item_widget.dart';

/// Vista principal del módulo home — ver PRESENTATION_ARCHITECTURE.md §8.
/// La lista larga es solo para ver el bottom nav (`AppNavigationShell`) y el
/// header ambos de vidrio (`GlassContainer`, reutilizado sin cambios) con
/// contenido real desplazándose detrás — se reemplaza por contenido real
/// cuando exista.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _cantidadDemo = 30;

  @override
  Widget build(BuildContext context) {
    context.watch<HomeController>();

    // Alto real del AppBar (barra de estado + toolbar) — el body arranca
    // debajo (ver padding del ListView) para no tapar el primer ítem, pero
    // sigue extendiéndose detrás gracias a `extendBodyBehindAppBar`.
    final alturaAppBar = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      // Excepción puntual: esta pantalla queda clara sobre un tema por lo
      // demás oscuro (ver doc de AppColors.lightBackground).
      backgroundColor: AppColors.lightBackground,
      // El body pinta detrás del AppBar (que ahora es transparente, ver
      // `flexibleSpace`) — mismo motivo que `extendBody` en
      // `AppNavigationShell`: sin esto no hay contenido real detrás del
      // vidrio del header para desenfocar.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onLightSurface,
        elevation: 0,
        title: const Text('Inicio'),
        // Mismo `GlassContainer` que usa `AppBottomNavBar` — el Design
        // System es justo esto: un componente, reusado donde haga falta,
        // sin reimplementarlo. Sin radio (header pegado al borde superior,
        // a diferencia de la cápsula flotante del bottom nav) y sin borde
        // propio (una línea blanca de borde no se nota contra este fondo
        // claro y no aporta nada acá).
        flexibleSpace: GlassContainer(
          borderRadius: 0,
          fillColor: AppColors.lightSurface,
          fillOpacity: 0.35,
          blurSigma: 6,
          borderColor: Colors.transparent,
          shadowOpacity: 0.06,
          child: const SizedBox.expand(),
        ),
      ),
      body: Stack(
        children: [
          // Fondo fijo (no scrollea con la lista) — le da variación real de
          // color al vidrio de arriba/abajo para que su transparencia se
          // note (ver doc de HomeBackground).
          const Positioned.fill(child: HomeBackground()),
          ListView.builder(
            // Top = alto del AppBar (el primer ítem arranca justo debajo,
            // no tapado). Bottom = alto de la cápsula flotante del bottom
            // nav (ver AppBottomNavBar.altura) — sin esto, el último ítem
            // quedaría parcialmente tapado por ella en vez de poder
            // scrollear por completo a la vista.
            padding: EdgeInsets.fromLTRB(
              0,
              alturaAppBar + 12,
              0,
              12 + AppBottomNavBar.altura,
            ),
            itemCount: _cantidadDemo,
            itemBuilder: (context, index) => HomeListItem(index: index),
          ),
        ],
      ),
    );
  }
}
