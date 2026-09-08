import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spec_kit_flutter_lab/presentation/global/i18n_provider.dart';
import 'package:spec_kit_flutter_lab/presentation/routes/routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget with Routes {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // I18nProvider debe vivir por encima del router: GoRouteHelper envuelve
    // cada pantalla en un Consumer<I18nProvider> para reconstruir al cambiar
    // de idioma (ver go_route_helper.dart).
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<I18nProvider>(create: (_) => I18nProvider('es')),
      ],
      child: MaterialApp.router(
        title: 'spec_kit_flutter_lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        routerConfig: router,
      ),
    );
  }
}
