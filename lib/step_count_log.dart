class StepCountLog {
  final int? id;
  final int date;
  final int step;

  StepCountLog({this.id, required this.date, required this.step});

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date, 'step': step};
  }

  @override
  String toString() {
    return 'StepCountLog{id: $id, date: $date, step: $step}';
  }
}
