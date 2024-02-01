import 'package:ubuntu_flavor/ubuntu_flavor.dart';

void main() {
  final flavor = UbuntuFlavor.detect();
  // ignore: avoid_print
  print(flavor);
}
