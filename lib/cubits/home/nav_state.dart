import 'package:equatable/equatable.dart';

class NavState extends Equatable {
  final int tab;

  const NavState({required this.tab});

  NavState copyWith({
    int? tab,
  }) {
    return NavState(
      tab: tab ?? this.tab,
    );
  }

  @override
  List<Object?> get props => [tab];
}
