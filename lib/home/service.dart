import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Service {
  final String key;
  final String date;
  final String startTime;
  final String endTime;

  Service(
      {@required this.key,
      @required this.date,
      @required this.startTime,
      @required this.endTime});

  Service.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        date = snapshot.value['pickedDate'],
        startTime = snapshot.value['fromTime'],
        endTime = snapshot.value['toTime'];

  toJson() {
    return {
      "key": key,
      "pickedDate": date,
      "fromTime": startTime,
      "toTime": endTime,
    };
  }
}
