import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebaseapp/edit_profile/edit_profile.dart';
import 'package:firebaseapp/edit_profile/settings.dart';
import 'package:firebaseapp/edit_profile/uploadPDF/firstPage.dart';
import 'package:firebaseapp/home/busyDates.dart';
import 'package:firebaseapp/meeting/meeting.dart';
import 'package:firebaseapp/notification/notification.dart';
import 'package:firebaseapp/reviews/review.dart';
import 'package:firebaseapp/services/auth.dart';

import 'package:firebaseapp/view_profile/viewProfile.dart';
import 'package:firebaseapp/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebaseapp/shared/loading.dart';


class Home extends StatefulWidget {
  @override
  _ConsultantState createState() => _ConsultantState();
}

class _ConsultantState extends State<Home> {
  final AuthService _auth =
      AuthService(); //make a object of AuthService class in auth.dart file

  final mainref = FirebaseDatabase.instance;
  String retrievedproPic = "";
  String retrievedfName = "";
  String retrievedsName = "";
  String averageRating = "";
  String fullName = "";
  bool isValid = false;
  String url = "";
  bool isImg = true;
  bool _loading = true;
  bool disabled = false;

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

  //-----------------------------------get user data
  Future<void> getUserData() async {
    final ref = mainref.reference().child('Consultants').child('$id');
    await ref.child('proPic').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedproPic = snapshot.value;
      });
    });
    await ref.child('firstName').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedfName = snapshot.value;
      });
    });
    await ref.child('secondName').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedsName = snapshot.value;
      });
    });
    await ref.child('verified').once().then((DataSnapshot snapshot) {
      setState(() {
        isValid = snapshot.value;
      });
    });
    await ref.child('averageRating').once().then((DataSnapshot snapshot) {
      setState(() {
        averageRating = snapshot.value;
      });
    });
    await ref.child('disabled').once().then((DataSnapshot snapshot) {
      setState(() {
        disabled = snapshot.value;
      });
    });
    fullName = retrievedfName + " " + retrievedsName;
    if (retrievedproPic == "") {
      url =
          "https://inlandfutures.org/wp-content/uploads/2019/12/thumbpreview-grey-avatar-designer.jpg";
      isImg = false;
    } else {
      await downloadImage();
    }
    _loading = false;
  }

  //----------------------------------------------------------------------

  //-----------------------------------get profile picture from database
  Future downloadImage() async {
    StorageReference _reference =
        FirebaseStorage.instance.ref().child("$retrievedproPic");
    String downloadAddress = await _reference.getDownloadURL();
    setState(() {
      url = downloadAddress;
    });
  }

  //---------------------------------------------------------
  //-------------------------------------get meeting from database
  Query _ref;
  // DatabaseReference _ref;
  Future<void> getMeetings() async {
    _ref = FirebaseDatabase.instance
        .reference()
        .child('Consultants')
        .child('$id')
        .child('acceptedmeetings') //(acceptedmeetings)
        .orderByChild('date');
  }
  //----------------------------------------------------

  //-------------------check if there any user
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> checkAuthentication() async {
    auth.onAuthStateChanged.listen((user) async {
      if (user == null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Wrapper()));
      }
    });
  }

  //--------------------------------------------------
  Future<void> getData() async {
    await getUserID();
    await getUserData();
    await getMeetings();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  //----------------------------------User Interface
  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            drawer: Drawer(
              child: ListView(children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          colors: [
                            Colors.blue[600],
                            Colors.blue[400],
                            Colors.blue[200]
                          ]),
                      boxShadow: [
                        BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 10))
                      ],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28))),
                  //  color: Colors.blue[300],
                  child: Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(//Profile picture
                            children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(url), fit: BoxFit.cover),
                              border:
                                  Border.all(width: 6, color: Colors.blue[900]),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.2),
                                    offset: Offset(0, 10))
                              ],
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                              //verification batch
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 45,
                                width: 45,
                                /*   decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.white,
                                  ),
                                  color: Colors.red,
                                ), */
                                child: isValid
                                    ? Image.asset('assets/prize.png')
                                    : null,
                                /*    Icon(
                                  Icons.verified_outlined,
                                  color: Colors.white,
                                  size: 25.0,
                                ),  */
                              ))
                        ]),
                        SizedBox(
                          height: 12.0,
                        ),
                        Container(
                          decoration: BoxDecoration(),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ViewProfile()));
                            },
                            child: Text(
                              fullName,
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.w800,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  //Average Rating
                                  padding: EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            offset: Offset(0, 10))
                                      ],
                                      color: Colors.yellow[800],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.yellow)),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 2.0),
                                      Text(
                                        "$averageRating",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 2.0),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  //Verified or not
                                  padding: EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            offset: Offset(0, 6))
                                      ],
                                      color: Colors.yellow[800],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.yellow)),
                                  child: Center(
                                    child: isValid
                                        ? Text(
                                            "Verified Consultant",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            "Consultant",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                ListTile(
                  trailing: Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 18.0,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => EditProfilePage()));
                  },
                  leading: Icon(
                    Icons.edit,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Edit Profile"),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 18.0,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => FirstPage()));
                  },
                  tileColor: Colors.white30,
                  leading: Icon(
                    Icons.file_copy,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Add Certificate"),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 18.0,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => BusyDates()));
                  },
                  tileColor: Colors.white30,
                  leading: Icon(
                    Icons.calendar_today,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Add Busy Dates"),
                ),
                /*    ListTile(
                  trailing: Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 18.0,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => Server()));
                  },
                  tileColor: Colors.white30,
                  leading: Icon(
                    Icons.video_call,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Video Chat"),
                ), */
                ListTile(
                  trailing: Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 18.0,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => Review()));
                  },
                  leading: Icon(
                    Icons.rate_review,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Reviews"),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 18.0,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => SettingsPage()));
                  },
                  tileColor: Colors.white30,
                  leading: Icon(
                    Icons.settings,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Settings"),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 18.0,
                    color: Colors.blueAccent,
                  ),
                  onTap: () async {
                    await _auth.signOut();
                    await checkAuthentication();
                  },
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Sign Out"),
                ),
              ]),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => Notifications()));
                  },
                )
              ],
              elevation: 1,
              backgroundColor: Colors.blueAccent,
            ),
            body: disabled == true
                ? Container(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "Your account is currently Banned by Admin. You can not create meetings now.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueAccent),
                      ),
                    ),
                  )
                : Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Meeting Schedule",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueAccent),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Flexible(
                          child: FirebaseAnimatedList(
                            query: _ref,
                            itemBuilder: (BuildContext context,
                                DataSnapshot snapshot,
                                Animation<double> animation,
                                int index) {
                              Map Meetings = snapshot.value;
                              Meetings['key'] = snapshot.key;

                              var temp = DateTime.now();
                              var d1 =
                                  DateTime(temp.year, temp.month, temp.day);
                              //     print(d1);
                              var temp1 = DateTime.parse(Meetings['date']);
                              var d2 =
                                  DateTime(temp1.year, temp1.month, temp1.day);
                              //     print(d2);
                              var d3 = d2.add(Duration(days: 1));
                              //        print(d3);
                              //        print(d3.compareTo(d1) <= 0);
                              if (d3.compareTo(d1) <= 0) {
                                //day after scheduled day it will automatically removed (acceptedmeetings)
                                FirebaseDatabase.instance
                                    .reference()
                                    .child('Consultants')
                                    .child('$id')
                                    .child('acceptedmeetings')
                                    .child('${Meetings['key']}')
                                    .remove();
                              }

                              return Container(
                                padding:
                                    EdgeInsets.only(left: 15.0, right: 15.0),
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 10.0, left: 12.0, right: 12.0),
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  height: 140,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          colors: [
                                            Colors.white70,
                                            Colors.white54,
                                            Colors.white30
                                          ]),
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            offset: Offset(0, 10))
                                      ],
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(28),
                                          bottomRight: Radius.circular(28))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    "${Meetings['date']}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.w600),
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
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    "${Meetings['startTime']}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.w600),
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
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                "${Meetings['selectedduration']}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight:
                                                        FontWeight.w600),
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
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                "${Meetings['selectedtype']}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              RaisedButton(
                                                color: Colors.blueAccent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              MeetingProfile(
                                                                  meetingID:
                                                                      Meetings[
                                                                          'key'])));
                                                },
                                                child: Text("Meeting >>",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        letterSpacing: 1.6,
                                                        color: Colors.white)),
                                              ),
                                              SizedBox(
                                                width: 10.0,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              //////////////////////////////////////////////////////////
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          );
  }
}
