/*
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/home/service.dart';
import 'package:flutter/material.dart';

class BusyDates extends StatefulWidget {
  @override
  _BusyDatesState createState() => _BusyDatesState();
}

class _BusyDatesState extends State<BusyDates> {
  //Calendar module-buddika --------------------------------------------

  DateTime _pickedDate;
  TimeOfDay fromTime;
  TimeOfDay toTime;
  final mainref = FirebaseDatabase.instance;
  //-------------------------------get User id
  String id;
  FirebaseUser user;
  Future<void> getUserID() async {
    final FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      id = userData.uid.toString();
    });
  }

  //------------------------------------------
  @override
  void initState() {
    super.initState();
    getUserID();

    _pickedDate = DateTime.now();
    fromTime = TimeOfDay.now();
    toTime = TimeOfDay.now();
    __pickedDate =
        "${_pickedDate.year.toString()}-${_pickedDate.month.toString().padLeft(2, '0')}-${_pickedDate.day.toString().padLeft(2, '0')}";
    __fromTime =
        "${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}";
    __toTime =
        "${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}";

    Timer(Duration(seconds: 2), () {
      mainref
          .reference()
          .child('Consultants')
          .child('$id')
          .child('busyDate')
          .once()
          .then((DataSnapshot snap) {
        var data = snap.value;
        serviceList.clear();
        data.forEach((key, value) {
          Service s = new Service(
              key: value['key'],
              date: value['pickedDate'],
              startTime: value['fromTime'],
              endTime: value['toTime']);

          serviceList.add(s);
        });
      });
    });
  }

  String __pickedDate = "";
  String __fromTime = "";
  String __toTime = "";

  pickedDate() async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: _pickedDate,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));
    if (date != null) {
      setState(() {
        _pickedDate = date;
      });
    }
    __pickedDate =
        "${_pickedDate.year.toString()}-${_pickedDate.month.toString().padLeft(2, '0')}-${_pickedDate.day.toString().padLeft(2, '0')}";
  }

  pickedFromTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: fromTime);
    if (fromTime != null) {
      setState(() {
        fromTime = t;
      });
    } else {
      fromTime = TimeOfDay.now();
    }
    __fromTime =
        "${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}";
  }

  pickedToTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: toTime);
    if (toTime != null) {
      setState(() {
        toTime = t;
      });
    } else {
      toTime = TimeOfDay.now();
    }

    __toTime =
        "${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}";
  }

  String CreateCryptoRandomString([int length = 8]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  List<Service> serviceList = [
    // Service(key: '1', date: '2021-04-03', startTime: '13:45', endTime: '14:00')
  ];

  Future<void> sendtoDatabase() async {
    final mainReference = FirebaseDatabase.instance.reference();
    final reference = mainReference
        .child('Consultants')
        .child('$id')
        .child('busyDate')
        .child(CreateCryptoRandomString());
    reference.child('pickedDate').set(__pickedDate);
    reference.child('fromTime').set(__fromTime);
    reference.child('toTime').set(__toTime);
    print(_pickedDate);
    print(fromTime);
    print(toTime);
  }

  Future<void> retrievefromDatabase() async {
    Timer(Duration(seconds: 2), () {
      mainref
          .reference()
          .child('Consultants')
          .child('$id')
          .child('busyDate')
          .once()
          .then((DataSnapshot snap) {
        var data = snap.value;
        serviceList.clear();
        data.forEach((key, value) {
          Service s = new Service(
              key: value['key'],
              date: value['pickedDate'],
              startTime: value['fromTime'],
              endTime: value['toTime']);

          serviceList.add(s);
        });
      });
    });
  }

  Future<void> gt() async {
    await sendtoDatabase();
    await retrievefromDatabase();
  }

  //-----------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) => Home()));
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blueAccent,
            ),
          ),

          /*
          
          FlatButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        EditProfilePage())); //calling a Sign out method
              },
              icon: Icon(
                Icons.edit,
                size: 20.0,
                color: Colors.blueAccent,
              ),
              label: Text(
                "Edit Profile",
                style: TextStyle(color: Colors.blueAccent),
              )) */
        ),

        //Calendar module-buddika --------------------------------------------
        body: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Select Date and Time",
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                      ListTile(
                        leading: Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        title: Text(
                            '${_pickedDate.year}-${_pickedDate.month}-${_pickedDate.day}'),
                        subtitle: Text('Select your service date'),
                        trailing: IconButton(
                            icon: Icon(Icons.date_range),
                            onPressed: () => {pickedDate()}),
                      ),
                      ListTile(
                        leading: Text(
                          'From',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        title: Text("${fromTime.hour}:${fromTime.minute}"),
                        trailing: IconButton(
                            icon: Icon(Icons.watch_later_outlined),
                            onPressed: () => {pickedFromTime()}),
                      ),
                      ListTile(
                        leading: Text(
                          'To',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        title: Text("${toTime.hour}:${toTime.minute}"),
                        trailing: IconButton(
                            icon: Icon(Icons.watch_later_outlined),
                            onPressed: () => {pickedToTime()}),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            color: Colors.blue,
                            onPressed: () {
                              gt();
                            },
                            child: Text('Save'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                color: Colors.blue,
                height: 280.0,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: serviceList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(4, 6),
                                          blurRadius: 4)
                                    ]),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Date:${serviceList[index].date} ",
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.blue),
                                          ),
                                          Text(
                                              "Start Time:${serviceList[index].startTime} "),
                                          Text(
                                              "End Time:${serviceList[index].endTime} "),
                                        ],
                                      ),
                                      FlatButton(
                                          color: Colors.red,
                                          height: 20.0,
                                          minWidth: 50.0,
                                          hoverColor: Colors.white,
                                          onPressed: () => {},
                                          child: Text(
                                            'Delete',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ))
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      );
                    }),
              )
            ],
          ),
        ));
  }
}
*/

import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:flutter/material.dart';

class BusyDates extends StatefulWidget {
  @override
  _BusyDatesState createState() => _BusyDatesState();
}

class _BusyDatesState extends State<BusyDates> {
  DateTime _pickedDate;
  TimeOfDay fromTime;
  TimeOfDay toTime;
  final mainref = FirebaseDatabase.instance;
  bool _loading = true;

  //-------------------------------get User id
  String id;
  FirebaseUser user;
  Future<void> getUserID() async {
    final FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      id = userData.uid.toString();
    });
  }

  //------------------------------------------

  Query _ref;
  // DatabaseReference _ref;
  Future<void> getMeetings() async {
    _ref = FirebaseDatabase.instance
        .reference()
        .child('Consultants')
        .child('$id')
        .child('busyDate')
        .orderByChild('pickedDate');
  }

  Future<void> getData() async {
    await getUserID();
    await getMeetings();
    _loading = false;
  }

  @override
  void initState() {
    super.initState();
    getData();
    _pickedDate = DateTime.now();
    fromTime = TimeOfDay.now();
    toTime = TimeOfDay.now();
    __pickedDate =
        "${_pickedDate.year.toString()}-${_pickedDate.month.toString().padLeft(2, '0')}-${_pickedDate.day.toString().padLeft(2, '0')}";
    __fromTime =
        "${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}";
    __toTime =
        "${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}";
  }

  String __pickedDate = "";
  String __fromTime = "";
  String __toTime = "";

  pickedDate() async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: _pickedDate,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));
    if (date != null) {
      setState(() {
        _pickedDate = date;
      });
    }
    __pickedDate =
        "${_pickedDate.year.toString()}-${_pickedDate.month.toString().padLeft(2, '0')}-${_pickedDate.day.toString().padLeft(2, '0')}";
  }

  pickedFromTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: fromTime);
    if (fromTime != null) {
      setState(() {
        fromTime = t;
      });
    } else {
      fromTime = TimeOfDay.now();
    }
    __fromTime =
        "${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}";
  }

  pickedToTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: toTime);
    if (toTime != null) {
      setState(() {
        toTime = t;
      });
    } else {
      toTime = TimeOfDay.now();
    }

    __toTime =
        "${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}";
  }

  String CreateCryptoRandomString([int length = 8]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  Future<void> sendtoDatabase() async {
    final mainReference = FirebaseDatabase.instance.reference();
    final reference = mainReference
        .child('Consultants')
        .child('$id')
        .child('busyDate')
        .child(CreateCryptoRandomString());
    reference.child('pickedDate').set(__pickedDate);
    reference.child('fromTime').set(__fromTime);
    reference.child('toTime').set(__toTime);
    print(_pickedDate);
    print(fromTime);
    print(toTime);
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.blueAccent,
            appBar: AppBar(
              elevation: 1,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Home()));
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30))),
                    padding: const EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 15.0),
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Select Date and Time",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue),
                                ),
                              )
                            ],
                          ),
                          ListTile(
                            leading: Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            title: Text(
                                '${_pickedDate.year.toString()}-${_pickedDate.month.toString().padLeft(2, '0')}-${_pickedDate.day.toString().padLeft(2, '0')}'),
                            subtitle: Text('Select your service date'),
                            trailing: IconButton(
                                icon: Icon(Icons.date_range),
                                onPressed: () => {pickedDate()}),
                          ),
                          ListTile(
                            leading: Text(
                              'From',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            title: Text(
                                "${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}"),
                            trailing: IconButton(
                                icon: Icon(Icons.watch_later_outlined),
                                onPressed: () => {pickedFromTime()}),
                          ),
                          ListTile(
                            leading: Text(
                              'To',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            title: Text(
                                "${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}"),
                            trailing: IconButton(
                                icon: Icon(Icons.watch_later_outlined),
                                onPressed: () => {pickedToTime()}),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                color: Colors.blue,
                                onPressed: () {
                                  sendtoDatabase();
                                },
                                child: Text('Save'),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  //--------------------------------------------------------------

                  Flexible(
                      child: FirebaseAnimatedList(
                          query: _ref,
                          itemBuilder: (BuildContext context,
                              DataSnapshot snapshot,
                              Animation<double> animation,
                              int index) {
                            Map BusyDates = snapshot.value;
                            BusyDates['key'] = snapshot.key;
                            return Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15.0)),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(4, 6),
                                                  blurRadius: 4)
                                            ]),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Date:${BusyDates['pickedDate']} ",
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: Colors.blue),
                                                  ),
                                                  Text(
                                                      "Start Time:${BusyDates['fromTime']} "),
                                                  Text(
                                                      "End Time:${BusyDates['toTime']} "),
                                                ],
                                              ),
                                              FlatButton(
                                                  color: Colors.red,
                                                  height: 20.0,
                                                  minWidth: 50.0,
                                                  hoverColor: Colors.white,
                                                  onPressed: () {
                                                    FirebaseDatabase.instance
                                                        .reference()
                                                        .child('Consultants')
                                                        .child('$id')
                                                        .child('busyDate')
                                                        .child(
                                                            '${BusyDates['key']}') //remove from the meetings
                                                        .remove();
                                                  },
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ))
                                            ],
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            );
                          })),
                ],
              ),
            ));
  }
}
