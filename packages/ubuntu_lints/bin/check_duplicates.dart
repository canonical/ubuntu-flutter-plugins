import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

/// This utility checks whether there are any added rules that are already
/// active in the rule-set.
Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stdout.writeln(
      '''
Usage: dart check_duplicates.dart <analysis_options.yaml> <rule_set_url1> <rule_set_url2>

If no rule_set_url is provided, the following rule sets are used:
  - https://raw.githubusercontent.com/dart-lang/lints/main/lib/core.yaml
  - https://raw.githubusercontent.com/dart-lang/lints/main/lib/recommended.yaml
  - https://raw.githubusercontent.com/flutter/packages/main/packages/flutter_lints/lib/flutter.yaml
  
Do note that the rule sets are not recursively fetched, so if you want to
include rules from a rule set that is included in the rule set that is passed in
you need to add that rule set url as well.
''',
    );
    exit(1);
  }
  final analysisFile = File(arguments[0]).readAsStringSync();
  //final includedRuleSet = yamlToImportedRuleSet(analysisFile);
  final currentRules = yamlToOverrideRules(analysisFile);
  final enabledRules = {
    for (final rule in currentRules.entries)
      if (rule.value) rule.key
  };
  final disabledRules = {
    for (final rule in currentRules.entries)
      if (!rule.value) rule.key
  };

  const lintsCoreUrl =
      'https://raw.githubusercontent.com/dart-lang/lints/main/lib/core.yaml';
  const recommendedUrl =
      'https://raw.githubusercontent.com/dart-lang/lints/main/lib/recommended.yaml';
  const flutterLintsUrl =
      'https://raw.githubusercontent.com/flutter/packages/main/packages/flutter_lints/lib/flutter.yaml';
  final urls = arguments.length == 1
      ? [lintsCoreUrl, recommendedUrl, flutterLintsUrl]
      : arguments.sublist(1);
  final fetchedRules = await Future.wait(
    urls.map(fetchRules),
  );
  final allRules = fetchedRules.expand((list) => list).toSet();

  final duplicateRules = allRules.intersection(enabledRules);
  if (duplicateRules.isNotEmpty) {
    stdout.writeln(
      'The following enabled rules are already active:\n'
      '${formatRulesOutput(duplicateRules)}\n',
    );
  }

  final unnecessaryDisabledRules = disabledRules.difference(allRules);
  if (unnecessaryDisabledRules.isNotEmpty) {
    stdout.writeln(
      'The following disabled rules are not included before, '
      'so disabling them is unnecessary:\n'
      '${formatRulesOutput(unnecessaryDisabledRules)}\n',
    );
  }

  final uniqueRules = enabledRules.difference(allRules);
  if (uniqueRules.isNotEmpty) {
    stdout.writeln(
      'The following added rules are not included before:\n'
      '${formatRulesOutput(uniqueRules)}\n',
    );
  }

  if (duplicateRules.isNotEmpty || unnecessaryDisabledRules.isNotEmpty) {
    exit(1);
  }
  exit(0);
}

Future<List<String>> fetchRules(String url) async {
  final client = HttpClient();
  final content = await client
      .getUrl(Uri.parse(url))
      .then((request) => request.close())
      .then((response) => response.transform(utf8.decoder).join());
  return yamlToRules(content);
}

List<String> yamlToRules(String content) {
  final yaml = loadYaml(content) as YamlMap;
  return yaml['linter']['rules']
      .map<String>((rule) => rule.toString())
      .toList();
}

Map<String, bool> yamlToOverrideRules(String content) {
  final yaml = loadYaml(content) as YamlMap;
  return (yaml['linter']['rules'] as Map).map<String, bool>(
    // ignore: unnecessary_lambdas
    (key, value) => MapEntry(key, value),
  );
}

String yamlToImportedRuleSet(String content) {
  final yaml = loadYaml(content) as YamlMap;
  return yaml['include'];
}

String formatRulesOutput(Iterable<String> rules) {
  return (rules.toList()..sort()).join('\n');
}
