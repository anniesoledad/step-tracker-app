import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:step_tracker_app/step_count_log.dart';
import 'package:step_tracker_app/db_helper.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
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
  DateTime _date = DateTime.now();
  bool _initializing = false;

  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  void initPlatformState() {
    _initializing = true;

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCountChanged).onError(onStepCountError);

    _initializing = false;
  }

  Future<void> getRecords() async {
    var list = await DbHelper.instance.retrieveLogs();
    print(list);
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onStepCountChanged(StepCount event) async {
    print("changed:");
    print(event.steps);

    // if there has already recorded step count within the day, add changes to step count
    // else reset step count to zero

    /*  if (_initializing) {
      // set state of steps taken
    }*/

    /*await saveLog(event);
    getRecords();

    setState(() {
      _steps = event.steps.toString();
    });*/
  }

  Future<void> saveLog(StepCount event) async {
    StepCountLog log = StepCountLog(
        date: event.timeStamp.microsecondsSinceEpoch, step: event.steps);

    await DbHelper.instance.insertLog(log);
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
