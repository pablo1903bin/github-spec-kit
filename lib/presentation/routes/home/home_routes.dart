import 'package:go_router/go_router.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/home/controllers/home_controller.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/home/controllers/state/home_state.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/home/views/home_view.dart';
import 'package:spec_kit_flutter_lab/presentation/routes/go_route_helper.dart';

import '../route_path.dart';

class HomeRoutes {
  static GoRoute get home {
    return GoRouteHelper.goRoute<HomeController>(
      RoutePath.home,
      () => const HomeView(),
      controller: () => HomeController(const HomeState()),
    );
  }
}
