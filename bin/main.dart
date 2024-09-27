import 'dart:io';

import 'package:args/args.dart';
import 'package:queueing_simulator/simulator.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  // Configure the command-line argument parser.
  final parser = ArgParser()
    ..addOption('conf', abbr: 'c', help: 'Config file path')  // Specify the config file.
    ..addFlag('verbose', abbr: 'v', defaultsTo: false, negatable: false, help: 'Print verbose output');
  
  final results = parser.parse(args);

  // Display usage if the config file is not provided.
  if (!results.wasParsed('conf')) {
    print('Usage:');
    print(parser.usage);
    exit(0);
  }

  // Check if verbose mode is enabled.
  final verbose = results['verbose'];

  // Get and check if the config file path exists.
  final file = File(results['conf']);
  if (!file.existsSync()) {
    print('Config file not found: ${results['conf']}');
    exit(1);
  }

  // Load and parse the YAML configuration file.
  final yamlString = file.readAsStringSync();
  final yamlData = loadYaml(yamlString);

  // Create a simulator with the loaded configuration, run it, and print the report.
  final simulator = Simulator(yamlData, verbose: verbose);
  simulator.run();
  simulator.printReport();
}
