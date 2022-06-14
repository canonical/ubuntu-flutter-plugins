import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Form layout consists columns with intrinsic widths and vertically center-
/// aligned labels.
///
/// ```dart
/// FormLayout(
///   rowSpacing: 24,
///   columnSpacing: 24,
///   rows: [
///     [
///       const Text('Name'),
///       TextField(...),
///     ],
///     [
///       const Text('Value'),
///       TextField(...),
///     ],
///   ],
/// )
/// ```
class FormLayout extends StatelessWidget {
  /// Creates a form layout with the given rows and spacings.
  const FormLayout({
    super.key,
    required this.rows,
    this.rowSpacing = 0,
    this.columnSpacing = 0,
  });

  /// Spacing between rows.
  final double rowSpacing;

  /// Spacing between colums.
  final double columnSpacing;

  /// The rows of the form layout.
  final List<List<Widget>> rows;

  @override
  Widget build(BuildContext context) {
    final columnCount = rows.firstOrNull?.length ?? 0;
    final columnSpacer = SizedBox(width: columnSpacing);
    final rowSpacer = TableRow(
      children: List.filled(columnCount * 2 - 1, SizedBox(height: rowSpacing)),
    );

    final children = rows
        .map((row) => TableRow(children: row.separated(columnSpacer).toList()))
        .separated(rowSpacer);

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: children.toList(),
    );
  }
}

extension _Separator<T> on Iterable<T> {
  Iterable<T> separated(T separator) {
    return expand((item) sync* {
      yield separator;
      yield item;
    }).skip(1);
  }
}
