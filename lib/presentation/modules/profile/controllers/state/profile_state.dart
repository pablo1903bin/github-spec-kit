import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

/// Estado observable de la pantalla de perfil — ver
/// PRESENTATION_ARCHITECTURE.md §7.
@freezed
class ProfileState with _$ProfileState {
  const ProfileState._();

  const factory ProfileState({
    @Default(false) bool isLoading,
  }) = _ProfileState;
}
