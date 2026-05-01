import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/task_provider.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final pending = tasks.where((t) => t.status == 'Pending').length;
    final inProgress = tasks.where((t) => t.status == 'InProgress').length;
    final complete = tasks.where((t) => t.status == 'Complete').length;
    final total = pending + inProgress + complete;

    return Scaffold(
      appBar: AppBar(title: const Text('Task Charts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: total == 0
            ? const Center(child: Text('No tasks to display in chart.'))
            : Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          if (pending > 0)
                            PieChartSectionData(
                              value: pending.toDouble(),
                              color: Colors.red,
                              title: '${((pending / total) * 100).round()}%\nPending',
                              radius: 80,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          if (inProgress > 0)
                            PieChartSectionData(
                              value: inProgress.toDouble(),
                              color: Colors.orange,
                              title: '${((inProgress / total) * 100).round()}%\nIn Progress',
                              radius: 80,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          if (complete > 0)
                            PieChartSectionData(
                              value: complete.toDouble(),
                              color: Colors.green,
                              title: '${((complete / total) * 100).round()}%\nComplete',
                              radius: 80,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _LegendItem(color: Colors.red, label: 'Pending', value: pending),
                      _LegendItem(color: Colors.orange, label: 'In Progress', value: inProgress),
                      _LegendItem(color: Colors.green, label: 'Complete', value: complete),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 14, height: 14, color: color),
      const SizedBox(width: 8),
      Text('$label ($value)'),
    ]);
  }
}

