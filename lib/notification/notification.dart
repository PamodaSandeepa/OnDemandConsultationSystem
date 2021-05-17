import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
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
  final mainref = FirebaseDatabase.instance;
  bool _loading = true; //for query!=null is not true
  //-------------------------------------get meeting from database
  Query _ref;
  // DatabaseReference _ref;
  Future<void> getMeetings() async {
    _ref = FirebaseDatabase.instance
        .reference()
        .child('Consultants')
        .child('$id')
        .child('meetings')
        .orderByChild('date');
  }

  //----------------------------------------------------
  Future<void> getData() async {
    await getUserID();
    await getMeetings();
    _loading = false;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 1,
              backgroundColor: Colors.blueAccent,
            ),
            body: Container(
              //    padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Meeting requests",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Flexible(
                    child: FirebaseAnimatedList(
                      query: _ref,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Map Meetings = snapshot.value;
                        Meetings['key'] = snapshot.key;

                        var temp = DateTime.now();
                        var d1 = DateTime(temp.year, temp.month, temp.day);
                        //     print(d1);
                        var temp1 = DateTime.parse(Meetings['date']);
                        var d2 = DateTime(temp1.year, temp1.month, temp1.day);
                        //     print(d2);
                        var d3 = d2.add(Duration(days: 1));
                        //      print(d3);
                        //  print(d3.compareTo(d1) <= 0);
                        if (d3.compareTo(d1) <= 0) {
                          //day after scheduled day it will automatically removed  (meetings)
                          FirebaseDatabase.instance
                              .reference()
                              .child('Consultants')
                              .child('$id')
                              .child('meetings')
                              .child('${Meetings['key']}')
                              .remove();
                        }

                        return //d3.compareTo(d1) == 0? null:
                            Container(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                )),
                            padding: EdgeInsets.only(
                                top: 5.0, left: 12.0, right: 12.0),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            height: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Date :",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              "${Meetings['date']}",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue[800],
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Start Time :",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              "${Meetings['startTime']}",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue[800],
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Meeting Duration :",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Text(
                                          "${Meetings['selectedduration']}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[800],
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Meeting Type :",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Text(
                                          "${Meetings['selectedtype']}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[800],
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Payment :",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Text(
                                          "${Meetings['amount']}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[800],
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        RaisedButton(
                                          color: Colors.grey[300],
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          onPressed: () {
                                            mainref
                                                .reference()
                                                .child('general_user')
                                                .child(
                                                    '${Meetings['clientID']}')
                                                .child('booking')
                                                .child('${Meetings['key']}')
                                                .child('accepeted')
                                                .set(false);
                                          },
                                          child: Text("Decline",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  letterSpacing: 1.6,
                                                  color: Colors.black)),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        RaisedButton(
                                          color: Colors.blueAccent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          onPressed: () {
                                            var data = {
                                              "amount": Meetings['amount'],
                                              "clientID": Meetings['clientID'],
                                              "date": Meetings['date'],
                                              "selectedduration":
                                                  Meetings['selectedduration'],
                                              "selectedtype":
                                                  Meetings['selectedtype'],
                                              "startTime": Meetings['startTime']
                                            };
                                            mainref
                                                .reference()
                                                .child('Consultants')
                                                .child('$id')
                                                .child('acceptedmeetings')
                                                .child('${Meetings['key']}')
                                                .set(data)
                                                .then((v) {
                                              print(
                                                  "Store Successfully"); //if you accept it goes accepted meetings
                                            });

                                            FirebaseDatabase.instance
                                                .reference()
                                                .child('Consultants')
                                                .child('$id')
                                                .child('meetings')
                                                .child(
                                                    '${Meetings['key']}') //remove from the meetings
                                                .remove();
                                            mainref
                                                .reference()
                                                .child('general_user')
                                                .child(
                                                    '${Meetings['clientID']}')
                                                .child('booking')
                                                .child('${Meetings['key']}')
                                                .child('accepeted')
                                                .set(true);
                                          },
                                          child: Text("Accept",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  letterSpacing: 1.6,
                                                  color: Colors.white)),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
