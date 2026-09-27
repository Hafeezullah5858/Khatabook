import 'package:flutter/material.dart';
import '../models/car_ledger_entry.dart';
import '../services/car_ledger_service.dart';

class CarLedgerPage extends StatefulWidget {
  const CarLedgerPage({super.key});

  @override
  State<CarLedgerPage> createState() => _CarLedgerPageState();
}

class _CarLedgerPageState extends State<CarLedgerPage> {
  final CarLedgerService _service = CarLedgerService();
  List<CarLedgerEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _service.loadEntries();
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _addEntry() async {
    final result = await showDialog<CarLedgerEntry>(
      context: context,
      builder: (_) => const _EntryDialog(),
    );

    if (result == null) return;

    final updated = [..._entries, result];
    await _service.saveEntries(updated);
    if (mounted) setState(() => _entries = updated);
  }

  double get _income =>
      _entries.fold(0, (sum, e) => sum + e.totalIncome);

  double get _expense =>
      _entries.fold(0, (sum, e) => sum + e.totalExpense);

  @override
  Widget build(BuildContext context) {
    final saving = _income - _expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BEF-275 Car Ledger'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntry,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BEF-275',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Total Income: ${_income.toStringAsFixed(0)}'),
                  Text('Total Expense: ${_expense.toStringAsFixed(0)}'),
                  Text('Net Saving: ${saving.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._entries.reversed.map(
            (entry) => Card(
              child: ListTile(
                title: Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                ),
                subtitle: Text(
                  'InDrive: ${entry.inDrive} • '
                  'Yango: ${entry.yango} • '
                  'Offline: ${entry.offline}\n'
                  'Expense: ${entry.totalExpense}',
                ),
                trailing: Text(
                  entry.netSaving.toStringAsFixed(0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryDialog extends StatefulWidget {
  const _EntryDialog();

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  final inDrive = TextEditingController();
  final yango = TextEditingController();
  final offline = TextEditingController();
  final fuel = TextEditingController();
  final other = TextEditingController();

  double _value(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0;

  @override
  void dispose() {
    inDrive.dispose();
    yango.dispose();
    offline.dispose();
    fuel.dispose();
    other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily Entry — BEF-275'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _field(inDrive, 'InDrive'),
            _field(yango, 'Yango'),
            _field(offline, 'Offline'),
            _field(fuel, 'Fuel Expense'),
            _field(other, 'Other Expense'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              CarLedgerEntry(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                date: DateTime.now(),
                inDrive: _value(inDrive),
                yango: _value(yango),
                offline: _value(offline),
                fuel: _value(fuel),
                otherExpense: _value(other),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
