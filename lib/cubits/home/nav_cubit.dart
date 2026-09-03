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

  // See NavState.combatRefreshRequestId's doc comment — pings a live
  // CombatPage (if one is mounted in the World tab's own Navigator, kept
  // alive by HomeView's IndexedStack) to reload its CombatCubit. A no-op if
  // no CombatPage happens to be mounted; nothing listens for it then.
  void requestCombatRefresh() {
    emit(state.copyWith(
        combatRefreshRequestId: state.combatRefreshRequestId + 1));
  }
}
