import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone_map/timezone_map.dart';
import 'package:yaru/yaru.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final geodata = Geodata.asset(bundle: rootBundle);
  final service = GeoService(sources: [
    geodata,
    Geoname.ubuntu(geodata: geodata),
    GeoIP.ubuntu(geodata: geodata),
  ]);

  runApp(
    YaruTheme(
      builder: (context, yaru, child) => MaterialApp(
        theme: yaru.variant?.theme ?? yaruLight,
        darkTheme: yaru.variant?.darkTheme ?? yaruDark,
        home: TimezonePage(service: service),
      ),
    ),
  );
}

class TimezonePage extends StatefulWidget {
  const TimezonePage({Key? key, required this.service}) : super(key: key);

  final GeoService service;

  @override
  State<TimezonePage> createState() => _TimezonePageState();
}

class _TimezonePageState extends State<TimezonePage> {
  late final TimezoneController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimezoneController(service: widget.service);
    widget.service.lookupLocation().then(_controller.selectLocation);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      TimezoneMap.precacheAssets(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatLocation(GeoLocation? location) {
    return location?.toDisplayString() ?? '';
  }

  String formatTimezone(GeoLocation? location) {
    return location?.toTimezoneString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Timezone map'),
            ),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Autocomplete<GeoLocation>(
                          initialValue: TextEditingValue(
                            text: formatLocation(_controller.selectedLocation),
                          ),
                          fieldViewBuilder:
                              (context, controller, focusNode, onSubmitted) {
                            if (!focusNode.hasFocus) {
                              controller.text =
                                  formatLocation(_controller.selectedLocation);
                            }
                            return TextFormField(
                              focusNode: focusNode,
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                              ),
                              onFieldSubmitted: (value) => onSubmitted(),
                            );
                          },
                          displayStringForOption: formatLocation,
                          optionsBuilder: (value) {
                            return _controller.searchLocation(value.text);
                          },
                          onSelected: _controller.selectLocation,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Autocomplete<GeoLocation>(
                          initialValue: TextEditingValue(
                            text: formatTimezone(_controller.selectedLocation),
                          ),
                          fieldViewBuilder: (context, controller, focusNode,
                              onFieldSubmitted) {
                            if (!focusNode.hasFocus) {
                              controller.text =
                                  formatTimezone(_controller.selectedLocation);
                            }
                            return TextFormField(
                              focusNode: focusNode,
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Timezone',
                              ),
                              onFieldSubmitted: (value) => onFieldSubmitted(),
                            );
                          },
                          displayStringForOption: formatTimezone,
                          optionsBuilder: (value) {
                            return _controller.searchTimezone(value.text);
                          },
                          onSelected: _controller.selectTimezone,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TimezoneMap(
                    offset: _controller.selectedLocation?.offset,
                    marker: _controller.selectedLocation?.coordinates,
                    onPressed: (coordinates) => _controller
                        .searchCoordinates(coordinates)
                        .then((locations) =>
                            _controller.selectLocation(locations.firstOrNull)),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
