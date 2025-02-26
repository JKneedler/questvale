import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int tab;

  const HomeState({required this.tab});

  HomeState copyWith({
    int? tab,
  }) {
    return HomeState(
      tab: tab ?? this.tab,
    );
  }

  @override
  List<Object?> get props => [tab];
}
