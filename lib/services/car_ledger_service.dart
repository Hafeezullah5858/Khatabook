import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_ledger_entry.dart';

class CarLedgerService {
  static const String _storageKey = 'bef_275_car_ledger';

  Future<List<CarLedgerEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];

    return raw.map((item) {
      final json = jsonDecode(item) as Map<String, dynamic>;
      return CarLedgerEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        inDrive: (json['inDrive'] as num?)?.toDouble() ?? 0,
        yango: (json['yango'] as num?)?.toDouble() ?? 0,
        offline: (json['offline'] as num?)?.toDouble() ?? 0,
        fuel: (json['fuel'] as num?)?.toDouble() ?? 0,
        otherExpense: (json['otherExpense'] as num?)?.toDouble() ?? 0,
        trips: (json['trips'] as num?)?.toInt() ?? 0,
        totalKm: (json['totalKm'] as num?)?.toDouble() ?? 0,
        notes: json['notes'] as String? ?? '',
        verified: json['verified'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> saveEntries(List<CarLedgerEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = entries.map((entry) {
      return jsonEncode({
        'id': entry.id,
        'date': entry.date.toIso8601String(),
        'inDrive': entry.inDrive,
        'yango': entry.yango,
        'offline': entry.offline,
        'fuel': entry.fuel,
        'otherExpense': entry.otherExpense,
        'trips': entry.trips,
        'totalKm': entry.totalKm,
        'notes': entry.notes,
        'verified': entry.verified,
      });
    }).toList();

    await prefs.setStringList(_storageKey, raw);
  }
}
