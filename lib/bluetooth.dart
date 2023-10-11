
import 'dart:io' show Platform;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class Bluetooth extends GetxController{

  Future<List<BluetoothDevice>> getPairedDevices() async {
    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // wait bluetooth to be on & print states
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    await FlutterBluePlus.adapterState
        .map((s){print(s);return s;})
        .where((s) => s == BluetoothAdapterState.on)
        .first;
    print('Now we are listing the connected devices..');
    List<BluetoothDevice> connectedSystemDevices = await FlutterBluePlus.connectedSystemDevices;

    print("our connected devices::::: $connectedSystemDevices");
    return connectedSystemDevices;
  }



  Future scanDevice() async{
    // check adapter availability
    if (await FlutterBluePlus.isAvailable == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // wait bluetooth to be on & print states
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    await FlutterBluePlus.adapterState
        .map((s){print(s);return s;})
        .where((s) => s == BluetoothAdapterState.on)
        .first;
    List<BluetoothDevice> connectedSystemDevices = await FlutterBluePlus.connectedSystemDevices;

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    if (connectedSystemDevices.isNotEmpty){
      for (var d in connectedSystemDevices) {
        FlutterBluePlus.setLogLevel(LogLevel.verbose, color:true);
        await d.connect();
        await d.discoverServices();
        if(d.localName == 'HMSoft'){
          List<BluetoothService> services = await d.discoverServices();
          services.forEach((service) async {
            service.characteristics.forEach((characteristic) {
              print("our connected devices services::::: ${characteristic}");
              print("our connected devices services::::: ${characteristic.properties}");
            });

          });
        }
      }
    }
  }



  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;


  Future<bool> connectToDevice(BluetoothDevice device) async {
    print("Device info :: $device");
    bool connected = false;
    await device.connect();
   await device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.connected) {
       connected = true;
      }

    });
    return connected;

  }

}