class DailyRecord {
  final int id;
  final int date;
  final int step;

  DailyRecord({required this.id, required this.date, required this.step});

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date, 'step': step};
  }
}
