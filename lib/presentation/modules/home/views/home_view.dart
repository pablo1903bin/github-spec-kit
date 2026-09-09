import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spec_kit_flutter_lab/core/theme/app_colors.dart';
import 'package:spec_kit_flutter_lab/presentation/global/widgets/design/glass_container.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/home/controllers/home_controller.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/navigation/widgets/app_bottom_nav_bar_widget.dart';

import '../widgets/home_background_widget.dart';
import '../widgets/home_banner_widget.dart';
import '../widgets/home_category_grid_widget.dart';
import '../widgets/home_greeting_widget.dart';
import '../widgets/home_highlights_widget.dart';
import '../widgets/home_list_item_widget.dart';
import '../widgets/home_quick_actions_widget.dart';
import '../widgets/home_section_title_widget.dart';
import '../widgets/home_stats_row_widget.dart';
import '../widgets/home_stories_widget.dart';

/// Vista principal del módulo home — ver PRESENTATION_ARCHITECTURE.md §8.
/// Header (saludo + accesos rápidos) y lista comparten un único
/// `CustomScrollView` — un `Stack` no ordena widgets uno debajo del otro
/// como una columna, así que un header "antes de la lista" necesita un
/// scroll real, no widgets sueltos apilados encima. El bottom nav y el
/// header ambos de vidrio (`GlassContainer`, reutilizado sin cambios) con
/// contenido real desplazándose detrás — se reemplaza por contenido real
/// cuando exista.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _cantidadDemo = 13;

  @override
  Widget build(BuildContext context) {
    context.watch<HomeController>();

    // Alto real del AppBar (barra de estado + toolbar) — el contenido
    // arranca debajo (ver padding del header), pero sigue extendiéndose
    // detrás gracias a `extendBodyBehindAppBar`.
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
          // Fondo fijo (no scrollea con el contenido) — le da variación
          // real de color al vidrio de arriba/abajo para que su
          // transparencia se note (ver doc de HomeBackground).
          const Positioned.fill(child: HomeBackground()),
          CustomScrollView(
            slivers: [
              // Header: saludo + accesos rápidos, ambos widgets propios de
              // Home (§4 PRESENTATION_ARCHITECTURE.md — un módulo agrega
              // Widgets nuevos en su propia carpeta `widgets/`, no inline
              // en la Page). Va en un único `SliverToBoxAdapter` porque
              // scrollea como bloque junto con la lista de abajo.
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, alturaAppBar + 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      HomeGreeting(),
                      SizedBox(height: 20),
                      HomeQuickActions(),
                      SizedBox(height: 24),
                      HomeSectionTitle('Historias'),
                      SizedBox(height: 12),
                      HomeStories(),
                      SizedBox(height: 24),
                      HomeBanner(),
                      SizedBox(height: 24),
                      HomeSectionTitle('Tu actividad'),
                      SizedBox(height: 12),
                      HomeStatsRow(),
                      SizedBox(height: 24),
                      HomeSectionTitle('Categorías'),
                      SizedBox(height: 12),
                      HomeCategoryGrid(),
                      SizedBox(height: 24),
                      HomeSectionTitle('Destacados'),
                      SizedBox(height: 12),
                      // Tarjetas sólidas (no vidrio) a propósito — ver doc
                      // de HomeHighlights: le dan al bottom nav otro tipo
                      // de contenido real por detrás, no solo tarjetas de
                      // vidrio repetidas.
                      HomeHighlights(),
                      SizedBox(height: 24),
                      HomeSectionTitle('Todo'),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                sliver: SliverList.builder(
                  itemCount: _cantidadDemo,
                  itemBuilder: (context, index) => HomeListItem(index: index),
                ),
              ),
              // Espacio final = alto de la cápsula flotante del bottom nav
              // (ver AppBottomNavBar.altura) — sin esto, el último ítem
              // quedaría parcialmente tapado por ella en vez de poder
              // scrollear por completo a la vista.
              SliverPadding(
                padding: EdgeInsets.only(bottom: AppBottomNavBar.altura),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
