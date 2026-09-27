class CarLedgerEntry {
  final String id;
  final DateTime date;
  final double inDrive;
  final double yango;
  final double offline;
  final double fuel;
  final double otherExpense;
  final int trips;
  final double totalKm;
  final String notes;
  final bool verified;

  CarLedgerEntry({
    required this.id,
    required this.date,
    this.inDrive = 0,
    this.yango = 0,
    this.offline = 0,
    this.fuel = 0,
    this.otherExpense = 0,
    this.trips = 0,
    this.totalKm = 0,
    this.notes = '',
    this.verified = false,
  });

  double get totalIncome => inDrive + yango + offline;

  double get totalExpense => fuel + otherExpense;

  double get netSaving => totalIncome - totalExpense;
}
