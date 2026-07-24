import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/gear_up_state.dart';

class GearUpCubit extends Cubit<GearUpState> {
  GearUpCubit() : super(const GearUpState());

  void onGearTabIndexSelected(int gearTabIndex) {
    emit(state.copyWith(gearTabIndex: gearTabIndex));
  }
}
