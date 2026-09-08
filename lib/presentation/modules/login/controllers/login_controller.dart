import 'package:spec_kit_flutter_lab/core/provider/state_notifier.dart';
import 'package:spec_kit_flutter_lab/presentation/modules/login/controllers/state/login_state.dart';

/// Coordina la pantalla de login — ver PRESENTATION_ARCHITECTURE.md §6.
class LoginController extends StateNotifier<LoginState> {
  LoginController(super.state);
}
