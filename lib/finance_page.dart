import 'package:flutter/material.dart';
import 'models/finance_entry.dart';
import 'models/cattle_store.dart';
// simple id generation without external package

class FinancePage extends StatefulWidget {
  final String initialType; // 'income' or 'expense'
  const FinancePage({super.key, this.initialType = 'income'});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> with SingleTickerProviderStateMixin {
  final CattleStore store = CattleStore.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialType == 'income' ? 0 : 1);
  }

  void _openAddSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddFinanceSheet(onSave: (entry) {
          store.addFinanceEntry(entry);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incomes / Expenses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Incomes'), Tab(text: 'Expenses')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList('income'),
          _buildList('expense'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(String type) {
    return ValueListenableBuilder(
      valueListenable: store.financeNotifier,
      builder: (context, List<FinanceEntry> list, _) {
        final entries = store.getEntriesByType(type);
        if (entries.isEmpty) return Center(child: Text('No ${type}s recorded'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final e = entries[index];
            return Card(
              child: ListTile(
                title: Text(e.title),
                subtitle: Text(e.date.toLocal().toIso8601String().split('T').first),
                trailing: Text('R ${e.amount.toStringAsFixed(2)}', style: TextStyle(color: type == 'income' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}

class AddFinanceSheet extends StatefulWidget {
  final void Function(FinanceEntry) onSave;
  const AddFinanceSheet({super.key, required this.onSave});

  @override
  State<AddFinanceSheet> createState() => _AddFinanceSheetState();
}

class _AddFinanceSheetState extends State<AddFinanceSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _type = 'income';

  void _save() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (title.isEmpty) return;
    final entry = FinanceEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      type: _type,
      amount: amount,
      title: title,
      notes: null,
    );
    widget.onSave(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title'))),
            ],
          ),
          Row(children: [Expanded(child: TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount')))]),
          const SizedBox(height: 8),
          Row(
            children: [
              DropdownButton<String>(value: _type, items: const [DropdownMenuItem(value: 'income', child: Text('Income')), DropdownMenuItem(value: 'expense', child: Text('Expense'))], onChanged: (v) { if (v!=null) setState(()=>_type=v); }),
              const Spacer(),
              TextButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ],
      ),
    );
  }
}
