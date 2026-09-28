import 'package:equatable/equatable.dart';

class Money extends Equatable implements Comparable<Money> {
  const Money(this.centavos);

  static const Money zero = Money(0);

  final int centavos;

  static Money fromPesos(num pesos) => Money((pesos * 100).round());

  double get pesos => centavos / 100;

  bool get isZero => centavos == 0;
  bool get isNotZero => centavos != 0;

  Money operator +(Money other) => Money(centavos + other.centavos);
  Money operator -(Money other) => Money(centavos - other.centavos);
  Money operator *(int factor) => Money(centavos * factor);

  // Some weird arithmetic to avoid floating point errors. This is a hacky solution but it works for now.
  Money percentFrom(int percent) => Money((centavos * (100 - percent)) ~/ 100);
  Money percentOff(int percent) => Money((centavos * percent ~/ 100));

  @override
  int compareTo(Money other) => centavos.compareTo(other.centavos);

  @override
  List<Object?> get props => [centavos];

  @override
  String toString() => 'PHP ${pesos.toStringAsFixed(2)}';
}
