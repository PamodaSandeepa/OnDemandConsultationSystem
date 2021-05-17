import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/chat/chats_page.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/videochat/pages/meeting.dart';
import 'package:flutter/material.dart';

class MeetingProfile extends StatefulWidget {
  String meetingID;
  MeetingProfile({this.meetingID});
  @override
  _MeetingProfileState createState() => _MeetingProfileState(meetingID);
}

class _MeetingProfileState extends State<MeetingProfile> {
  String meetingID;
  _MeetingProfileState(this.meetingID);

  //--------------------Retrive user id from firebase
  FirebaseUser user;
  String id;
  Future<void> getUserID() async {
    final FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      id = userData.uid.toString();
    });
  }
//------------------------------------------------------

//------------------------------Retrieve meeting data
  String clientID = "";
  String clientName = "";
  String date = "";
  String startTime = "";
  String selectedDuration = "";
  String selectedType = "";
  String amount = "";
  String payment = "";
  final mainref = FirebaseDatabase.instance;
  Future<void> meetingData() async {
    final ref = mainref
        .reference()
        .child('Consultants')
        .child('$id')
        .child('acceptedmeetings'); //(acceptedmeetings)

    DataSnapshot snapshot = await ref.child('$meetingID').once();
    Map Meeting = snapshot.value;
    clientID = Meeting['clientID'];
    date = Meeting['date'];
    startTime = Meeting['startTime'];
    selectedDuration = Meeting['selectedduration'];
    selectedType = Meeting['selectedtype'];
    amount = Meeting['amount'];
    payment = Meeting['pay'];
  }

  Future<void> getClientName() async {
    final ref1 = mainref.reference().child('general_user').child('$clientID');
    await ref1.child('name').once().then((DataSnapshot snapshot) {
      setState(() {
        clientName = snapshot.value;
      });
    });
  }

  Future<void> getData() async {
    await getUserID();
    await meetingData();
    await getClientName();
  }

  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
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
      ),
      body: Container(
        padding: EdgeInsets.all(15.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerRight,
                colors: [Colors.white60, Colors.white54, Colors.white70]),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 3,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(0, 10))
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    "Meeting Details",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        "Meeting ID        :   ",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        child: Text(
                          "$meetingID",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        "Client Name     :   ",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        child: Text(
                          "$clientName",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        "Date                   :   ",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        child: Text(
                          "$date",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        "Start Time        :   ",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        child: Text(
                          "$startTime",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        "Duration            :   ",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "$selectedDuration",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.red[900],
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        "Meeting Type   :   ",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "$selectedType",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        padding: EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 10.0, bottom: 10.0),
                        child: Column(
                          children: [
                            Text(
                              "Payment",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Container(
                              child: Text(
                                "Rs. $amount",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      payment == 'true'
                          ? ButtonTheme(
                              minWidth: 200.0,
                              height: 100.0,
                              child: selectedType == 'Video'
                                  ? RaisedButton(
                                      color: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        Server()));
                                      },
                                      child: Text("Create Meeting",
                                          style: TextStyle(
                                              fontSize: 18,
                                              letterSpacing: 1.6,
                                              color: Colors.white)),
                                    )
                                  : RaisedButton(
                                      color: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ChatsPage(
                                                          meetingId: meetingID,
                                                          receiverName:
                                                              clientName,
                                                          receiverId: clientID,
                                                          myId: id,
                                                        )));
                                      },
                                      child: Text("Join Meeting",
                                          style: TextStyle(
                                              fontSize: 18,
                                              letterSpacing: 1.6,
                                              color: Colors.white)),
                                    ),
                            )
                          : Container(
                              child: Text(
                                "Client still did not paid.",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
