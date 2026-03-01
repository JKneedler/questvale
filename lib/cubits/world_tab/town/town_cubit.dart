import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/town/town_state.dart';

class TownCubit extends Cubit<TownState> {
  TownCubit()
      : super(const TownState(currentLocation: TownLocation.townSquare));

  void setCurrentLocation(TownLocation location) {
    emit(state.copyWith(currentLocation: location));
  }
}
