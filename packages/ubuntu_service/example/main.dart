import 'package:ubuntu_service/ubuntu_service.dart';

class MyService {}

void main() {
  registerService<MyService>(MyService.new);

  somewhereElse();
}

void somewhereElse() {
  final service = getService<MyService>();
  // ignore: avoid_print
  print(service);
}
