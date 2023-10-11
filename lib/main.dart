import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import 'bluetooth.dart';
import 'controll.dart';


void main() => runApp( MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BluetoothPage(),
    );
  }
}

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key});

  void navigateToControlPage(BuildContext context, BluetoothDevice device) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ControlPage(device: device)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<Bluetooth>(
        init: Bluetooth(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.blue,
                  child: const Center(
                    child: Text(
                      "Bluetooth",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.scanDevice();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      maximumSize: const Size(350, 55),
                    ),
                    child: const Text(
                      'Scan',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];
                          return  GestureDetector(
                              onTap: () async {
                                final connected = await controller.connectToDevice(data.device);
                                print("the connected device situation::: $connected");
                                if (connected) {
                                  print(
                                    'Successfully connected to ${data.device.localName}',

                                  );
                                  navigateToControlPage(context, data.device);
                                } else {
                                  print(
                                    'Failed to connect to ${data.device.localName}',
                                  );
                                }
                              },
                              child: Card(
                                elevation: 2,
                                child: ListTile(
                                  title: Text(data.device.localName),
                                  subtitle: Text(data.device.remoteId.toString()),
                                ),
                              )
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text("No device found!!"),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

