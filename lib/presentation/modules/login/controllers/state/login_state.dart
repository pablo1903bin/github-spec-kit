import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

/// Estado observable de la pantalla de login — ver
/// PRESENTATION_ARCHITECTURE.md §7.
@freezed
class LoginState with _$LoginState {
  const LoginState._();

  const factory LoginState({
    @Default(false) bool isLoading,
  }) = _LoginState;
}
