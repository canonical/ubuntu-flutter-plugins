// ignore_for_file: deprecated_member_use

import 'package:platform_linux/platform.dart';
import 'package:ubuntu_flavor/src/ubuntu_flavor.dart';

UbuntuFlavor detectUbuntuFlavor([Platform platform = const LocalPlatform()]) =>
    UbuntuFlavor.unknown;
