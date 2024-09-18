import 'package:flutter/material.dart';
import 'package:ubuntu_widgets/src/validated_form_field.dart';
import 'package:yaru/yaru.dart';

/// Presents successful form validation state.
///
/// See also:
///  * [ValidatedFormField]
class SuccessIcon extends StatelessWidget {
  /// Creates a success icon.
  const SuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.check_circle,
        color: Theme.of(context).colorScheme.success,);
  }
}

/// Presents unsuccessful form validation state.
///
/// See also:
///  * [ValidatedFormField]
class ErrorIcon extends StatelessWidget {
  /// Creates an error icon.
  const ErrorIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.error, color: Theme.of(context).colorScheme.error);
  }
}
