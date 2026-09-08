import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

/// Estado observable de la pantalla principal — ver
/// PRESENTATION_ARCHITECTURE.md §7.
@freezed
class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({

    @Default(false) bool isLoading,

    
  }) = _HomeState;
}
