import 'package:flutter/material.dart';
import 'models/report.dart';
import 'models/cattle_store.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final store = CattleStore.instance;

  void _openAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddReportSheet(onSave: (r) {
          store.addReport(r);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ValueListenableBuilder(
        valueListenable: store.reportNotifier,
        builder: (context, List reports, _) {
          if (reports.isEmpty) return const Center(child: Text('No reports'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final r = reports[index] as Report;
              return Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Text(r.date.toLocal().toIso8601String().split('T').first),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddReportSheet extends StatefulWidget {
  final void Function(Report) onSave;
  const AddReportSheet({super.key, required this.onSave});

  @override
  State<AddReportSheet> createState() => _AddReportSheetState();
}

class _AddReportSheetState extends State<AddReportSheet> {
  final _title = TextEditingController();

  void _save() {
    final t = _title.text.trim();
    if (t.isEmpty) return;
    final r = Report(id: DateTime.now().millisecondsSinceEpoch.toString(), date: DateTime.now(), title: t);
    widget.onSave(r);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Report title')),
        const SizedBox(height: 8),
        Row(children: [const Spacer(), TextButton(onPressed: _save, child: const Text('Save'))])
      ]),
    );
  }
}
