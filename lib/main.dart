import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

void main() => runApp(const StepTrackerApp());

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

  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onStepCount(StepCount event) {
    print(event);
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
                  'Total Steps Taken:',
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
