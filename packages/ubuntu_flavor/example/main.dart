import 'package:ubuntu_flavor/ubuntu_flavor.dart';

void main() {
  final flavor = UbuntuFlavor.detect();
  print(flavor);
}
