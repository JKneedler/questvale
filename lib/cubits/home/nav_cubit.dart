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

  // See NavState.combatRefreshRequestId's doc comment — pings a live combat
  // encounter (if one is in progress in the World tab's own Navigator, kept
  // alive by HomeView's IndexedStack) to reload its CombatCubit. A no-op if
  // no combat encounter is currently live; nothing listens for it then.
  void requestCombatRefresh() {
    emit(state.copyWith(
        combatRefreshRequestId: state.combatRefreshRequestId + 1));
  }
}
