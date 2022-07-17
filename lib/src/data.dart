import 'package:collection/collection.dart';

class XdgIconData {
  const XdgIconData({
    required this.baseScale,
    required this.baseSize,
    required this.fileName,
    required this.isSymbolic,
    this.data,
  });

  final int baseScale;
  final int baseSize;
  final String fileName;
  final bool isSymbolic;
  final List<int>? data;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'baseScale': baseScale,
      'baseSize': baseSize,
      'fileName': fileName,
      'isSymbolic': isSymbolic,
      'data': data,
    };
  }

  factory XdgIconData.fromJson(Map<String, dynamic> json) {
    return XdgIconData(
      baseScale: json['baseScale'] as int,
      baseSize: json['baseSize'] as int,
      fileName: json['fileName'] as String,
      isSymbolic: json['isSymbolic'] as bool,
      data: (json['data'] as List?)?.cast<int>(),
    );
  }

  @override
  String toString() {
    return 'GtkIconInfo(baseScale: $baseScale, baseSize: $baseSize, fileName: $fileName, isSymbolic: $isSymbolic, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const ListEquality<int>().equals;
    return other is XdgIconData &&
        other.baseScale == baseScale &&
        other.baseSize == baseSize &&
        other.fileName == fileName &&
        other.isSymbolic == isSymbolic &&
        listEquals(other.data, data);
  }

  @override
  int get hashCode {
    final listHash = const ListEquality<int>().hash;
    return Object.hash(
      baseScale,
      baseSize,
      fileName,
      isSymbolic,
      listHash(data),
    );
  }
}
