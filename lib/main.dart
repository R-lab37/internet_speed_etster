import 'package:flutter/material.dart';
import 'package:speed_test_dart/classes/classes.dart';
import 'package:speed_test_dart/speed_test_dart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SpeedTestDart tester = SpeedTestDart();
  List<Server> bestServersList = [];

  double downloadRate = 0;
  double uploadRate = 0;
  double _speedValue = 0;

  bool readyToTest = false;
  bool loadingDownload = false;
  bool loadingUpload = false;

  Future<void> setBestServers() async {
    final settings = await tester.getSettings();
    final servers = settings.servers;

    final _bestServersList = await tester.getBestServers(
      servers: servers,
    );

    setState(() {
      bestServersList = _bestServersList;
      readyToTest = true;
    });
  }

  Future<void> _testDownloadSpeed() async {
    setState(() {
      loadingDownload = true;
    });
    final _downloadRate =
        await tester.testDownloadSpeed(servers: bestServersList);
    setState(() {
      downloadRate = _downloadRate;
      _speedValue = downloadRate;
      loadingDownload = false;
    });
  }

  Future<void> _testUploadSpeed() async {
    setState(() {
      loadingUpload = true;
    });

    final _uploadRate = await tester.testUploadSpeed(servers: bestServersList);

    setState(() {
      uploadRate = _uploadRate;
      _speedValue = uploadRate;
      loadingUpload = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setBestServers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      title: 'Internet Speed Tester',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Speed Tester'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SfRadialGauge(
                    enableLoadingAnimation: true,
                    animationDuration: 4500,
                    axes: <RadialAxis>[
                      RadialAxis(minimum: 0, maximum: 60, ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0, endValue: 20, color: Colors.green),
                        GaugeRange(
                            startValue: 20, endValue: 40, color: Colors.orange),
                        GaugeRange(
                            startValue: 40, endValue: 60, color: Colors.red)
                      ], pointers: <GaugePointer>[
                        NeedlePointer(value: _speedValue)
                      ], annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Text(
                                    "${_speedValue.toStringAsFixed(2)} Mb/s",
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold))),
                            angle: 90,
                            positionFactor: 0.6)
                      ])
                    ]),
                const Text(
                  'Test Upload speed:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (loadingUpload)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Testing upload speed...'),
                    ],
                  )
                else
                  Text('Upload rate ${uploadRate.toStringAsFixed(2)} Mb/s'),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: loadingUpload
                      ? null
                      : () async {
                          if (!readyToTest || bestServersList.isEmpty) return;
                          await _testUploadSpeed();
                        },
                  child: const Text('Start'),
                ),
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  'Test Download Speed:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (loadingDownload)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Testing download speed...'),
                    ],
                  )
                else
                  Text('Download rate ${downloadRate.toStringAsFixed(2)} Mb/s'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: loadingDownload
                      ? null
                      : () async {
                          if (!readyToTest || bestServersList.isEmpty) return;
                          await _testDownloadSpeed();
                        },
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
