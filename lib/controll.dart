import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ControlPage extends StatefulWidget {
  int i = 0;
  final BluetoothDevice device;

  ControlPage({required this.device});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  String receivedData = "";
  BluetoothCharacteristic? _characteristic;

  @override
  void initState() {
    super.initState();
    _findCharacteristic();
  }

  Future<void> _findCharacteristic() async {
    await widget.device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.connected) {
        print("the Device State ::::::::::::::; state == BluetoothConnectionState.CONNECTED ${state == BluetoothConnectionState.connected}");
      }else{
        await widget.device.connect();
        print("connected to the bluetooth");
      }

    });
      List<BluetoothService> services = await widget.device.discoverServices();
    print("I am inside the characteristic services :: $services");
    for (BluetoothService service in services) {
      print("the service uuid :::: ${service.serviceUuid}");
      if (service.serviceUuid.toString() == '0000ffe0-0000-1000-8000-00805f9b34fb'){
        print('the service characteristic ${service.characteristics}');
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.characteristicUuid.toString() == "0000ffe1-0000-1000-8000-00805f9b34fb"){
            _characteristic = characteristic;
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((value) async {
              setState(() {
                receivedData = String.fromCharCodes(value);
              });
            });
          }
        }
      }

      }


  }

  List<int> convertStringToASCII(String inputString) {
    List<int> asciiValues = [];

    for (int i = 0; i < inputString.length; i++) {
      asciiValues.add(inputString.codeUnitAt(i));
    }

    // Append ASCII values for carriage return (CR) and line feed (LF)
    asciiValues.add(13);
    asciiValues.add(10);

    return asciiValues;
  }

  Future<void> _sendCommand() async {
    await widget.device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.connected) {
      }else{
        await widget.device.connect();
      }});
    // print("I am tring to write :: ${convertStringToASCII('105/3')} ");
    while (true){
      setState(() {
        receivedData = "opened the red light";
      });
      await _characteristic?.write(convertStringToASCII('105/3'), withoutResponse: true);
      sleep(const Duration(seconds: 3));
      setState(() {
        receivedData = "opened the yellow light";
      });
      await _characteristic?.write(convertStringToASCII('105/4'), withoutResponse: true);
      sleep(const Duration(seconds: 3));
      setState(() {
        receivedData = "closed the lights";
      });
      await _characteristic?.write(convertStringToASCII('105/5'), withoutResponse: true);
      sleep(const Duration(seconds: 3));
      print("finish write");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Device'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              receivedData,
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _sendCommand();
              },
              child: const Text('Write'),
            ),
          ],
        ),
      ),
    );
  }
}
