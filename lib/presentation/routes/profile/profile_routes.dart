import 'package:go_router/go_router.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/profile/controllers/profile_controller.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/profile/controllers/state/profile_state.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/profile/views/profile_view.dart';
import 'package:spec_kit_flutter_lab/presentation/routes/go_route_helper.dart';

import '../route_path.dart';

class ProfileRoutes {
  static GoRoute get profile {
    return GoRouteHelper.goRoute<ProfileController>(
      RoutePath.profile,
      () => const ProfileView(),
      controller: () => ProfileController(const ProfileState()),
    );
  }
}
