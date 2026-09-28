import 'package:equatable/equatable.dart';

class RouteStop extends Equatable {
  const RouteStop({
    required this.name,
    required this.kmIndex,
    required this.sequence,
  });

  final String name;
  final int kmIndex;
  final int sequence;

  @override
  List<Object?> get props => [name, kmIndex, sequence];
}
