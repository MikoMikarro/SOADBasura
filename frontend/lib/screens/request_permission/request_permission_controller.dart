// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

class RequestPermissionController {
  final _streamController = StreamController<PermissionStatus>.broadcast();

  Stream<PermissionStatus> get onStatusChanged => _streamController.stream;

  request() async{
    await [Permission.location].request();
    //_notify(status);
  }

  void dispose(){
    _streamController.close();
  }
}