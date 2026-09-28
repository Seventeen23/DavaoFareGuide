enum PassengerCategory {
  regular('Regular'),
  student('Student'),
  senior('Senior'),
  pwd('PWD');

  const PassengerCategory(this.label);

  final String label;

  bool get isDiscounted => this != PassengerCategory.regular;

  static PassengerCategory fromLabel(String label) {
    return PassengerCategory.values.firstWhere(
      (category) => category.label.toLowerCase() == label.toLowerCase(),
      orElse: () => PassengerCategory.regular,
    );
  }
}
