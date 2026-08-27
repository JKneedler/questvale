import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/nav_state.dart';

class NavCubit extends Cubit<NavState> {
  NavCubit() : super(NavState(tab: 1));

  void changeTab(int tab) {
    emit(state.copyWith(tab: tab));
  }

  void setShowCombatNavBackground(bool show) {
    emit(state.copyWith(showCombatNavBackground: show));
  }
}
