import 'package:ubuntu_flavor/ubuntu_flavor.dart';

void main() async {
  final flavor = await UbuntuFlavor.detect();
  print(flavor);
}
