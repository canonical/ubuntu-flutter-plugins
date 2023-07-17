class WizardException implements Exception {
  const WizardException(this.message);

  final String message;

  @override
  String toString() => message;
}
