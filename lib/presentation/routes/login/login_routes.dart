import 'package:go_router/go_router.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/login/controllers/login_controller.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/login/controllers/state/login_state.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/login/views/login_view.dart';
import 'package:spec_kit_flutter_lab/presentation/routes/go_route_helper.dart';

import '../route_path.dart';

class LoginRoutes {
  static GoRoute get login {
    return GoRouteHelper.goRoute<LoginController>(
      RoutePath.login,
      () => const LoginView(),
      controller: () => LoginController(const LoginState()),
    );
  }
}
