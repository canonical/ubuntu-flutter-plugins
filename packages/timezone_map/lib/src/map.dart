import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:timezone_map/src/latlng.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// The size of the timezone map.
enum TimezoneMapSize {
  /// Fixed PNG (960x480)
  medium,

  /// Scalable SVG (default)
  scalable,
}

/// A widget that displays a map of the world.
class TimezoneMap extends StatelessWidget {
  /// Creates a map.
  const TimezoneMap({
    super.key,
    this.marker,
    this.offset,
    this.onPressed,
    this.size = TimezoneMapSize.scalable,
  });

  /// Coordinates of a map marker.
  final LatLng? marker;

  /// UTC-offset of the highlighted timezone.
  final double? offset;

  /// Called when the map is pressed at coordinates.
  final void Function(LatLng coordinates)? onPressed;

  /// The size of the map.
  final TimezoneMapSize size;

  /// Requests all timezone map SVG assets to be pre-cached.
  static Future<void> precacheAssets(BuildContext context) async {
    final bundle = DefaultAssetBundle.of(context);
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);

    bool filterAsset(String asset) {
      return p.isWithin('packages/timezone_map', asset) &&
          p.extension(asset) == '.png';
    }

    Future<void> precacheAsset(String assetName) async {
      final asset = AssetImage(
        p.relative(assetName, from: 'packages/timezone_map'),
        bundle: bundle,
        package: 'timezone_map',
      );
      return precacheImage(asset, context);
    }

    await Future.wait(
      manifest.listAssets().where(filterAsset).map(precacheAsset),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && onPressed != null) {
          onPressed!(toLatLng(details.localPosition, box.size));
        }
      },
      child: MouseRegion(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(
                  child: _buildImage(context, 'map'),
                ),
                if (offset != null)
                  Positioned.fill(
                    child: _buildImage(
                      context,
                      'tz_${_formatTimezoneOffset(offset!)}',
                    ),
                  ),
                if (marker != null)
                  Positioned(
                    left: lng2x(marker!.longitude, constraints.maxWidth) - 12,
                    top: lat2y(marker!.latitude, constraints.maxHeight) - 24,
                    child: const Icon(Icons.place, color: Colors.red, size: 24),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String assetName) {
    switch (size) {
      case TimezoneMapSize.scalable:
        return SvgPicture(
          AssetBytesLoader(
            'assets/scalable/$assetName.svg.vec',
            packageName: 'timezone_map',
          ),
          fit: BoxFit.fill,
        );
      default:
        return Image.asset(
          'assets/${size.name}/$assetName.png',
          package: 'timezone_map',
          fit: BoxFit.fill,
        );
    }
  }
}

// Shortest double (%g) representation: 0, 1, 5.5, 5.75, ...
String _formatTimezoneOffset(double offset) {
  final format = NumberFormat(null, 'en_US'); // decimal separator = "."
  format.minimumFractionDigits = 0;
  format.maximumFractionDigits = 2;
  return format.format(offset);
}
