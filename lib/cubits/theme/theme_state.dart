import 'package:equatable/equatable.dart';
import 'package:questvale/helpers/constants.dart';

class ThemeState extends Equatable {
  final AppTheme theme;

  const ThemeState({required this.theme});

  @override
  List<Object?> get props => [theme.id];
}
