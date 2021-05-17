import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:flutter/material.dart';

class ViewProfile extends StatefulWidget {
  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  final mainref = FirebaseDatabase.instance;
  String retrievedproPic = "";
  String retrievedfName = "";
  String retrievedsName = "";
  String retrievedfield = "";
  String retrievedemail = "";
  String fullName = "";
  bool isValid = false;
  String url = "";
  bool isImg = true;
  bool _loading = true;

  //-----------------------get user id
  String id;
  FirebaseUser user;
  Future<void> getUserID() async {
    final FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      id = userData.uid.toString();
    });
  }
  //---------------------------------------------

  //-------------------------------get user data from database
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
    await ref.child('field').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedfield = snapshot.value;
      });
    });
    await ref.child('email').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedemail = snapshot.value;
      });
    });

    fullName = retrievedfName + " " + retrievedsName;
    if (retrievedproPic == "") {
      url = "https://www.hilokal.com/images/profile_pictures/profile_stock.png";
      isImg = false;
    } else {
      await downloadImage();
    }
  }

  //---------------------------------------------------------------------

  //-------------------------------------------get image from firebase storage
  Future downloadImage() async {
    StorageReference _reference =
        FirebaseStorage.instance.ref().child("$retrievedproPic");
    String downloadAddress = await _reference.getDownloadURL();
    setState(() {
      url = downloadAddress;
    });
  }
  //-------------------------------------------------------------

  Future<void> getData() async {
    await getUserID();
    await getUserData();
    _loading = false;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  //-----------------------------------User interface
  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300.0,
                  child: Stack(
                    children: <Widget>[
                      Container(),
                      ClipPath(
                        clipper: MyCustomClipper(),
                        child: Container(
                          height: 300.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSY51cMFchBH8n5NQhgH2xEHqaxMaPfDivQdzTKsE_RvDtTUvInh_2_bDgqOkdVJ5Zxn9E&usqp=CAU"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(0, 1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(url),
                                    fit: BoxFit.cover),
                                border:
                                    Border.all(width: 4, color: Colors.white60),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              "$fullName",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            isValid
                                ? Text(
                                    "Verified Consultant",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey[800],
                                    ),
                                  )
                                : Text(
                                    "Non-Verified Consultant",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => Home()));
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 21.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.category_rounded,
                                  size: 40.0,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 24.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "Category",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    "$retrievedfield",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 21.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.category_rounded,
                                  size: 40.0,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 24.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    "$retrievedemail",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ));
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 180);
    path.lineTo(-70, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
