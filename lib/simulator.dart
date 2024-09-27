import 'dart:collection';

import 'package:yaml/yaml.dart';

import 'processes.dart';

/// Queueing system simulator.
class Simulator {
  final bool verbose;
  final List<Process> processes = [];
  final List<Event> eventQueue = [];
  List<Event> processedEvents = [];

  // Simulator is initialized with YAML configuration.
  Simulator(YamlMap yamlData, {this.verbose = false}) {
    // Parse each process defined in the YAML file and create it dynamically using the factory method.
    for (final name in yamlData.keys) {
      final YamlMap fields = yamlData[name];
      // Convert YamlMap to regular Dart Map<String, dynamic>
      Map<String, dynamic> fieldsMap = Map<String, dynamic>.from(fields);

      // Using the factory method to create the process
      Process process = Process.createProcess(name, fieldsMap);
      processes.add(process);
      eventQueue.addAll(process.generateEvents());
    }

    // Sort events by their arrival time.
    eventQueue.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
  }

  // Run the simulation by processing the events in order.
  void run() {
    int currentTime = 0;
    Queue<Event> simulationQueue = Queue<Event>();
    simulationQueue.addAll(eventQueue);

    // Process events one by one, calculating wait times.
    while (simulationQueue.isNotEmpty) {
      final event = simulationQueue.removeFirst();  // Get the next event.

      // Move time forward if the event arrives after the current time.
      currentTime = event.arrivalTime > currentTime ? event.arrivalTime : currentTime;

      // Calculate and store the wait time for the event.
      event.waitTime = currentTime - event.arrivalTime;

      // Print verbose output if enabled.
      if (verbose) {
        if (event.waitTime == 0) {
          print('t=$currentTime: ${event.processName}, duration ${event.duration} started (arrived @ ${event.arrivalTime}, no wait)');
        } else {
          print('t=$currentTime: ${event.processName}, duration ${event.duration} started (arrived @ ${event.arrivalTime}, waited ${event.waitTime})');
        }
      }

      // Update the current time after processing the event.
      currentTime += event.duration;

      // Add the processed event to the list for reporting.
      processedEvents.add(event);
    }
  }

  // Print the final report with statistics about the simulation.
  void printReport() {
    final processStats = <String, List<int>>{};  // [total wait time, total events]
    for (final process in processes) {
      processStats[process.name] = [0, 0];  // Initialize [total wait time, event count]
    }

    int totalWaitTime = 0;

    // Accumulate wait times and event counts for each process.
    for (final event in processedEvents) {
      processStats[event.processName]![0] += event.waitTime;
      processStats[event.processName]![1] += 1;
      totalWaitTime += event.waitTime;
    }

    // Output per-process statistics.
    print('--------------------------------------------------------------');
    print('# Per-process statistics');
    for (final process in processStats.keys) {
      final stats = processStats[process];
      print('$process:');
      print('  Events generated:  ${stats![1]}');
      print('  Total wait time:   ${stats[0]}');
      print('  Average wait time: ${stats[1] == 0 ? 0 : (stats[0] / stats[1]).toStringAsFixed(2)}');
      print('');
    }

    // Output summary statistics for the entire simulation.
    print('--------------------------------------------------------------');
    print('# Summary statistics');
    print('Total num events:  ${processedEvents.length}');
    print('Total wait time:   $totalWaitTime');
    print('Average wait time: ${processedEvents.isEmpty ? 0 : (totalWaitTime / processedEvents.length).toStringAsFixed(2)}');
  }
}
