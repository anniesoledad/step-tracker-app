import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:step_tracker_app/daily_record.dart';
import 'package:step_tracker_app/db.dart';
import 'package:intl/intl.dart';

final db = StepTrackerDatabase();

Future<void> main() async {
  await db.openDb();
  // await db.insertRecord(DailyRecord(id: 3, date: DateTime.daysPerWeek, step: 2));
  runApp(const StepTrackerApp());
}

class StepTrackerApp extends StatefulWidget {
  const StepTrackerApp({super.key});

  @override
  State<StepTrackerApp> createState() => _StepTrackerAppState();
}

class _StepTrackerAppState extends State<StepTrackerApp> {
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late Stream<StepCount> _stepCountStream;

  String _status = '';
  String _steps = '';
  final DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  void onInitialize() {}

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCountChanged).onError(onStepCountError);
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onStepCountChanged(StepCount event) async {
    print(event);

    DailyRecord record = DailyRecord(
        id: 1, date: event.timeStamp.microsecondsSinceEpoch, step: event.steps);
    await db.insertRecord(record);

    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd().format(_date);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('STEP TRACKER APP'),
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text(
                  'Date:',
                  style: TextStyle(fontSize: 20.0),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 20.0),
                )
              ],
            ),
            Row(
              children: <Widget>[
                const Text(
                  'Status:',
                  style: TextStyle(fontSize: 20.0),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(_status, style: const TextStyle(fontSize: 20.0))
              ],
            ),
            Row(
              children: <Widget>[
                const Text(
                  'Steps Taken:',
                  style: TextStyle(fontSize: 20.0),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(_steps, style: const TextStyle(fontSize: 20.0))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
