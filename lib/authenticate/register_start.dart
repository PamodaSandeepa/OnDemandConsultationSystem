import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/Animation/animation.dart';
import 'package:flutter/material.dart';
import 'package:firebaseapp/services/auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:flutter/cupertino.dart';

class Register_Start extends StatefulWidget {
  final Function tv;

  //create constructor for the Register widget for toggling
  Register_Start({this.tv});

  @override
  _Register_StartState createState() => _Register_StartState();
}

class _Register_StartState extends State<Register_Start> {
  final mainRef = FirebaseDatabase.instance;
  final cloudRef = Firestore.instance;
  String id = "";

  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _emailcontroller = new TextEditingController();

  //-----------------------------------------------------------------------      ------verifying email process
  TextEditingController _otpController = new TextEditingController();
  bool verify = false;
  String isVerified = "";

  //Send otp message to given mail. you can get the validation key
  var res;
  void sendOTP() async {
    EmailAuth.sessionName = "On Demand Consultation";
    res = await EmailAuth.sendOtp(receiverMail: _emailcontroller.value.text);
    await vk();
  }

  Future<void> vk() async {
    if (res) {
      Fluttertoast.showToast(
          msg: "email verifcation key is send to your email.");
      await _displayTextInputDialog(
          context); //display the alert dialog to enter the key
    } else {
      await showError("Email is invalid. Please supply a correct valid one.");
    }
  }

  //after given the validation key check it will valid
  Future<void> validation(BuildContext context) async {
    var res1 =
        EmailAuth.validate(receiverMail: email, userOTP: _otpController.text);

    Timer(Duration(seconds: 1), () async {
      if (res1 == true) {
        //if given key is valid
        await sendDatabase();
        await uploadPic(context);
      } else {
        //if given key is invalid
        //   await _keyInvalid(context);
        _otpController.text = "";
        await showError("Email verifcation key is invalid. Try again");
      }
    });
  }

  //Alert dialog for validation
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Validation Key'),
            content: TextField(
              controller: _otpController,
              decoration: InputDecoration(hintText: "Validation Key"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() async {
                    validation(context);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  //Alert dialog for invalid key
  Future<void> _keyInvalid(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Validation Key is Invalid. Try Again'),
            actions: <Widget>[
              FlatButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text('OK'),
                  onPressed: () {
                    setState(() async {
                      Navigator.pop(context);
                    });
                  })
            ],
          );
        });
  }

  //----------------------------------------------------------------------------------------------------------
  signUp() async {
    if (_formkey.currentState.validate()) {
      dynamic result;
      try {
        result = await _auth.registerWithEmailAndPassword(email, password);
        id = result.uid.toString();
        print(id);
      } catch (e) {
        await showError("Already have a account on this email. Try again.");
        print(e);
      } //Get the user id from firebase
    }
  }

  Future<void> sendDatabase() async {
    /*  if (_formkey.currentState.validate()) {
      //valid or not
      result = await _auth.registerWithEmailAndPassword(email, password);
      id = result.uid.toString(); //Get the user id from firebase

    }  */
    await signUp();
    final ref = mainRef
        .reference()
        .child('Consultants')
        .child('$id'); //make a route in database.
    final cat = mainRef.reference().child('Categories');
    final CollectionReference consultants = cloudRef.collection('Consultants');

    if (_formkey.currentState.validate()) {
      /*  if (result == null) {
        setState(() => error =
            'please supply a valid correct email'); //registerWithEmailAndPassowd not success.email is not valid
      } else {  */
      ref.child("firstName").set(fName);
      ref.child("secondName").set(sName);
      ref.child("email").set(email);
      ref.child("description").set(description);
      ref.child("mobileNumber").set(mobileNumber);
      ref.child("countryCode").set(counrtyCode);
      ref.child("country").set(isoCode);
      ref.child("accountNo").set(accountNo);
      ref.child("field").set(value1);
      //  ref.child("subField").set(value2);
      ref.child("subFields").set(_myActivities); //list
      ref.child("proPic").set(pathImg);
      ref.child("verified").set(verified);
      ref.child("averageRating").set("0.0");
      ref.child("uid").set(id);
      //----------------------------name change
      today = DateTime.now();
      fiftyDaysFromNow = today.add(const Duration(days: 50)).toString();
      ref.child("nameChange").set(fiftyDaysFromNow);
      //--------------------------------------------

      //----------------------------tag for consultant category
      for (int i = 0; i < _myActivities.length; i++) {
        cat
            .child("$value1-${_myActivities[i]}")
            .child('$id')
            .child("firstName")
            .set(fName);
        cat
            .child("$value1-${_myActivities[i]}")
            .child('$id')
            .child("secondName")
            .set(sName);
        cat
            .child("$value1-${_myActivities[i]}")
            .child('$id')
            .child("proPicURL")
            .set(proPicURL);
        cat
            .child("$value1-${_myActivities[i]}")
            .child('$id')
            .child("verified")
            .set(verified);
        cat
            .child("$value1-${_myActivities[i]}")
            .child('$id')
            .child("averageRating")
            .set("0.0");
        cat
            .child("$value1-${_myActivities[i]}")
            .child('$id')
            .child("uid")
            .set(id);
      }

      consultants
          .document('$value1-$_myActivities[i]')
          .collection('$id')
          .document()
          .setData({
        'id': id,
        'name': fName,
      });
      //-------------------------------------------------
      //  }
    }
  }

  /*
  BuildContext dialogContext;
  //-------alert box
  showAlertDialog(BuildContext context) async {
    // set up the button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () async {
          if (verifyOTP() == true) {
            await sendDatabase();
            await uploadPic(context);
          }
          await Navigator.of(dialogContext).pop();
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Enter Validation Key"),
      content: TextFormField(
        controller: _otpController,
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }
  */
  //----------------------------------------------------------------

  //----------------profile picture uploading

  File __image;
  String pathImg = "";
  String proPicURL = "";
  String url = "";

  Future getPic() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource
            .gallery); //pick the image from gallery and save to image varibale

    setState(() {
      __image = image;
      print('Image Path $__image');
      pathImg = path.basename(__image.path);
      print("Profile Picture uploaded");
      _showSnackBar();
    });
  }

  Future uploadPic(BuildContext context) async {
    String imageName = path.basename(__image.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(imageName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(__image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    url = await (taskSnapshot).ref.getDownloadURL();
    final ref = mainRef.reference().child('Consultants').child('$id');
    ref.child("proPicURL").set(url);
    setState(() {});
  }

//----------------------------------------------

//-------------------Consultant Category

  String value1 = "";
  String value2 = "";
  bool isA = false;
  String sub;
  List<DropdownMenuItem<String>> category = List();
  bool disabledropdown = true;
  int cat = 0;
  List<Map<String, String>> subcat = [];

  final Medical = {
    "1": "Allergists",
    "2": "Dermatologist",
    "3": "Dental",
    "4": "Psychiatrist",
    "5": "Veterinary",
  };

  List<Map<String, String>> subcatMedical = [
    {
      "display": "Allergists",
      "value": "Allergists",
    },
    {
      "display": "Dermtologist",
      "value": "Dermatologist",
    },
    {
      "display": "Dental",
      "value": "Dental",
    },
    {
      "display": "Psychiatrist",
      "value": "Psychiatrist",
    },
    {
      "display": "Veterinary",
      "value": "Veterinary",
    },
  ];

  final Law = {
    "1": "Bankruptcy",
    "2": "Business",
    "3": "Civil",
    "4": "Criminal",
    "5": "Family",
    "6": "Personal Injury"
  };

  List<Map<String, String>> subcatLaw = [
    {
      "display": "Bankruptcy",
      "value": "Bankruptcy",
    },
    {
      "display": "Business",
      "value": "Business",
    },
    {
      "display": "Civil",
      "value": "Civil",
    },
    {
      "display": "Criminal",
      "value": "Criminal",
    },
    {
      "display": "Family",
      "value": "Family",
    },
    {
      "display": "Personal Injury",
      "value": "Personal Injury",
    },
  ];

  final Education = {
    "1": "Primary Education",
    "2": "Secondary Education",
    "3": "Higher Education",
    "4": "Special Education",
    "5": "Aesthetic Education"
  };

  List<Map<String, String>> subcatEducation = [
    {
      "display": "Primary Education",
      "value": "Primary Education",
    },
    {
      "display": "Secondary Education",
      "value": "Secondary Education",
    },
    {
      "display": "Higher Education",
      "value": "Higher Education",
    },
    {
      "display": "Special Education",
      "value": "Special Education",
    },
    {
      "display": "Aesthetic Education",
      "value": "Aesthetic Education",
    },
  ];

  final Counseling = {
    "1": "Educational",
    "2": "Guidance and Career",
    "3": "Marriage and family",
    "4": "Mental health",
    "5": "Substance abuse",
    "6": "Rehabiliation",
  };

  List<Map<String, String>> subcatCounseling = [
    {
      "display": "Educational",
      "value": "Educational",
    },
    {
      "display": "Guidance and Career",
      "value": "Guidance and Career",
    },
    {
      "display": "Marriage and family",
      "value": "Marriage and family",
    },
    {
      "display": "Mental health",
      "value": "Mental health",
    },
    {
      "display": "Substance abuse",
      "value": "Substance abuse",
    },
    {
      "display": "Rehabiliation",
      "value": "Rehabiliation",
    },
  ];

  final Business = {
    "1": "Accountacy",
    "2": "Business Administration",
    "3": "Entrepreneurship",
    "4": "Finance",
    "5": "Marketing"
  };

  List<Map<String, String>> subcatBusiness = [
    {
      "display": "Accountacy",
      "value": "Accountacy",
    },
    {
      "display": "Business Administration",
      "value": "Business Administration",
    },
    {
      "display": "Entrepreneurship",
      "value": "Entrepreneurship",
    },
    {
      "display": "Finance",
      "value": "Finance",
    },
    {
      "display": "Marketing",
      "value": "Marketing",
    },
  ];

  void populateMedical() {
    for (String key in Medical.keys) {
      category.add(DropdownMenuItem<String>(
        child: Center(
          child: Text(Medical[key]),
        ),
        value: Medical[key],
      ));
    }

    /* for (int v in Medical.keys) {
      multiItem.add(MultiSelectDialogItem(v, Medical[v]));
    } */
  }

  void populateLaw() {
    for (String key in Law.keys) {
      category.add(DropdownMenuItem<String>(
        child: Center(
          child: Text(Law[key]),
        ),
        value: Law[key],
      ));
    }
    /*for (int v in Law.keys) {
      multiItem.add(MultiSelectDialogItem(v, Law[v]));
    } */
  }

  void populateEducation() {
    for (String key in Education.keys) {
      category.add(DropdownMenuItem<String>(
        child: Center(
          child: Text(Education[key]),
        ),
        value: Education[key],
      ));
    }
    /*for (int v in Education.keys) {
      multiItem.add(MultiSelectDialogItem(v, Education[v]));
    } */
  }

  void populateCounseling() {
    for (String key in Counseling.keys) {
      category.add(DropdownMenuItem<String>(
        child: Center(
          child: Text(Counseling[key]),
        ),
        value: Counseling[key],
      ));
    }
    /*for (int v in Education.keys) {
      multiItem.add(MultiSelectDialogItem(v, Education[v]));
    } */
  }

  void populateBusiness() {
    for (String key in Business.keys) {
      category.add(DropdownMenuItem<String>(
        child: Center(
          child: Text(Business[key]),
        ),
        value: Business[key],
      ));
    }
    /*for (int v in Education.keys) {
      multiItem.add(MultiSelectDialogItem(v, Education[v]));
    } */
  }

  //selected value of first dropdownform field ,populate the values of second dropdownbutton
  void selected(_value) {
    if (_value == "Medical") {
      cat = 1;
      category = [];
      _myActivities = [];
      populateMedical();
    } else if (_value == "Law") {
      cat = 2;
      category = [];
      _myActivities = [];
      populateLaw();
    } else if (_value == "Education") {
      cat = 3;
      category = [];
      _myActivities = [];
      populateEducation();
    } else if (_value == "Counseling") {
      cat = 4;
      category = [];
      _myActivities = [];
      populateCounseling();
    } else if (_value == "Business") {
      cat = 5;
      category = [];
      _myActivities = [];
      populateBusiness();
    }

    setState(() {
      value1 = _value;
      disabledropdown = false; //second dropdownbutton
      value2 = "";
    });
  }

  void secondselected(_value) {
    setState(() {
      value2 = _value;
      isA = true;
    });
  }

  List _myActivities = [];

  getSubCat() {
    switch (cat) {
      case 0:
        return subcat;
        break;
      case 1:
        return subcatMedical;
        break;
      case 2:
        return subcatLaw;
        break;
      case 3:
        return subcatEducation;
        break;
      case 4:
        return subcatCounseling;
        break;
      case 5:
        return subcatBusiness;
        break;
    }
  }

//------------------------------------------------

  //---------------------snackBar to know profile picture uploaded
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<void> _showSnackBar() async {
    final snackBar = new SnackBar(
        content: new Text(
          "Profile Picture Uploaded",
          textAlign: TextAlign.center,
        ),
        duration: new Duration(seconds: 3),
        backgroundColor: Colors.blueAccent);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  //-------------------------------------------
  //---------------If there is no account for provieded email and password show error message
  Future<void> showError(String errormessage) async {
    showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(errormessage),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        },
        context: context);
  }

  //---------------------------------

  final AuthService _auth = AuthService();

  final _formkey = GlobalKey<FormState>(); //help the validate

  //text field state
  String email = '';
  String password = '';
  String error = '';
  String fName = "";
  String sName = "";
  String description = "";
  String mobileNumber = "";
  String isoCode = "";
  String counrtyCode = "";
  String accountNo = "";
  bool verified = false;
  var today;
  var fiftyDaysFromNow;
  bool _loading = false;

//-----------------------User Interface

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.blue[100],
            body: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        colors: [
                      Colors.blue[900],
                      Colors.blue[600],
                      Colors.blue[400]
                    ])),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FadeAnimation(
                                1,
                                Text(
                                  "Register",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 50),
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            FadeAnimation(
                                1.3,
                                Text(
                                  "Let's Start by  creating your account",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(17),
                                  topRight: Radius.circular(17))),
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              FadeAnimation(
                                1.4,
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 17.0),
                                    child: Form(
                                      key: _formkey,
                                      child: Column(
                                        children: <Widget>[
                                          Row(children: <Widget>[
                                            SizedBox(
                                              width: 99.0,
                                            ),
                                            // Profile Picture
                                            Center(
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width: 130,
                                                    height: 130,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: (__image !=
                                                                  null)
                                                              ? FileImage(
                                                                  __image)
                                                              : AssetImage(
                                                                  'assets/anon.png') //Anonymous profile picture
                                                          ),
                                                      border: Border.all(
                                                          width: 4,
                                                          color: Theme.of(
                                                                  context)
                                                              .scaffoldBackgroundColor),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            spreadRadius: 2,
                                                            blurRadius: 10,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1),
                                                            offset:
                                                                Offset(0, 10))
                                                      ],
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: Container(
                                                        height: 46,
                                                        width: 46,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            width: 4,
                                                            color: Theme.of(
                                                                    context)
                                                                .scaffoldBackgroundColor,
                                                          ),
                                                          color: Colors.blue,
                                                        ),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            getPic();
                                                          },
                                                          icon: Icon(
                                                            Icons.camera_alt,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                            /*    Align(
                                      alignment: Alignment.center,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 50.0,
                                        child: ClipOval(
                                            child: SizedBox(
                                                width: 180.0,
                                                height: 180.0,
                                                child: (__image != null)
                                                    ? Image.file(
                                                        __image,
                                                        fit: BoxFit.fill,
                                                      )
                                                    : Image.asset(
                                                        'assets/anon.png'))),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 60.0, right: 40.0),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.camera_alt,
                                          size: 25.0,
                                        ),
                                        onPressed: () {
                                          getPic();
                                        },
                                      ),
                                    ) */
                                          ]),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          Row(children: <Widget>[
                                            Expanded(
                                              flex: 7,
                                              child: TextFormField(
                                                //First Name
                                                decoration: InputDecoration(
                                                  prefixIcon:
                                                      Icon(Icons.person),
                                                  labelText: 'First Name',
                                                  labelStyle: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 15,
                                                      fontFamily:
                                                          'AvenirLight'),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 3.0)),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .pinkAccent,
                                                              width: 2.0)),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    fName = val;
                                                  });
                                                },
                                                validator: (String value) {
                                                  if (value.isEmpty) {
                                                    return "Enter first name";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 0.5,
                                            ),
                                            Expanded(
                                              flex: 8,
                                              child: TextFormField(
                                                //Second Name
                                                decoration: InputDecoration(
                                                  prefixIcon:
                                                      Icon(Icons.person),
                                                  labelText: 'Second Name',
                                                  labelStyle: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 15,
                                                      fontFamily:
                                                          'AvenirLight'),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 3.0)),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .pinkAccent,
                                                              width: 2.0)),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    sName = val;
                                                  });
                                                },
                                                validator: (String value) {
                                                  if (value.isEmpty) {
                                                    return "Enter second name";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ]),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          TextFormField(
                                            //Description
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.note),
                                              labelText: 'Description',
                                              labelStyle: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 15,
                                                  fontFamily: 'AvenirLight'),
                                              fillColor: Colors.white,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 3.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.pinkAccent,
                                                      width: 2.0)),
                                            ),

                                            onChanged: (val) {
                                              //val means current value in form field
                                              setState(() => description = val);
                                            },
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return "Please enter description";
                                              }
                                              /*    if (value.length < 20) {
                                                return "Please enter valid Account number";
                                              }  */
                                              return null;
                                            },
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          TextFormField(
                                            controller: _emailcontroller,
                                            //E-Mail
                                            decoration: InputDecoration(
                                              labelText: 'E-Mail',
                                              labelStyle: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 15,
                                                  fontFamily: 'AvenirLight'),
                                              prefixIcon: Icon(Icons.email),
                                              fillColor: Colors.white,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 3.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.pinkAccent,
                                                      width: 2.0)),
                                            ),

                                            validator: (val) => val.isEmpty
                                                ? 'Enter an email'
                                                : null, //Empty or not
                                            onChanged: (val) {
                                              //val means current value in form field
                                              setState(() => email = val);
                                            },
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          Container(
                                            //Mobile Number
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: IntlPhoneField(
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                    10),
                                              ],
                                              decoration: InputDecoration(
                                                labelText: 'Mobile Number',
                                                labelStyle: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 15,
                                                    fontFamily: 'AvenirLight'),
                                                //  prefixIcon:Icon(Icons.mobile_screen_share),

                                                fillColor: Colors.white,
                                                filled: true,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.white,
                                                            width: 3.0)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .pinkAccent,
                                                            width: 2.0)),
                                              ),
                                              initialCountryCode: 'LK',
                                              onChanged: (phone) {
                                                setState(() {
                                                  mobileNumber =
                                                      phone.completeNumber;
                                                  isoCode =
                                                      phone.countryISOCode;
                                                  counrtyCode =
                                                      phone.countryCode;
                                                });
                                              },
                                              /*validator: (PhoneNumber) {
                    if (PhoneNumber.isEmpty) {
                      return "Please enter phone";
                    }
                    if (PhoneNumber.length < 10) {
                      return "Please enter valid phone";
                    }
                  }, */
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          TextFormField(
                                            //Password
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              labelStyle: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 15,
                                                  fontFamily: 'AvenirLight'),
                                              prefixIcon: Icon(Icons.lock),
                                              fillColor: Colors.white,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 3.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.pinkAccent,
                                                      width: 2.0)),
                                            ),
                                            controller: _passwordController,
                                            validator: (val) => val.length < 6
                                                ? 'Invalid Format. Password should 6+ chars long'
                                                : null,
                                            obscureText: true, //don't see text
                                            onChanged: (val) {
                                              setState(() => password = val);
                                            },
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          TextFormField(
                                            //cofirm password
                                            decoration: InputDecoration(
                                              labelText: 'Confirm Password',
                                              labelStyle: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 15,
                                                  fontFamily: 'AvenirLight'),
                                              prefixIcon: Icon(Icons.lock),
                                              fillColor: Colors.white,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 3.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.pinkAccent,
                                                      width: 2.0)),
                                            ),
                                            obscureText: true,
                                            validator: (value) {
                                              if (value.isEmpty ||
                                                  value !=
                                                      _passwordController
                                                          .text) {
                                                return 'Password does not match!.';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {},
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          TextFormField(
                                            //Account Number
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  12),
                                            ],
                                            decoration: InputDecoration(
                                              labelText: 'Account Number',
                                              labelStyle: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 15,
                                                  fontFamily: 'AvenirLight'),
                                              prefixIcon: Icon(Icons.home),
                                              fillColor: Colors.white,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 3.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.pinkAccent,
                                                      width: 2.0)),
                                            ),
                                            onChanged: (val) {
                                              setState(() => accountNo = val);
                                            },
                                            validator: (String val) {
                                              if (val.isEmpty) {
                                                return "Please enter Account number";
                                              }
                                              if (val.length < 12) {
                                                return "Please enter valid Account number";
                                              }
                                            },
                                          ),
                                          SizedBox(
                                            height: 30.0,
                                          ),
                                          Container(
                                            //Categoty
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child:
                                                DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                labelText: 'Category',
                                                labelStyle: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 15,
                                                    fontFamily: 'AvenirLight'),
                                              ),
                                              items: [
                                                DropdownMenuItem<String>(
                                                  value: "Medical",
                                                  child: Center(
                                                    child: Text("Medical"),
                                                  ),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: "Law",
                                                  child: Center(
                                                    child: Text("Law"),
                                                  ),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: "Education",
                                                  child: Center(
                                                    child: Text("Education"),
                                                  ),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: "Counseling",
                                                  child: Center(
                                                    child: Text("Counseling"),
                                                  ),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: "Business",
                                                  child: Center(
                                                    child: Text("Business"),
                                                  ),
                                                ),
                                              ],
                                              onChanged: (_value) =>
                                                  selected(_value),
                                              validator: (value) => value ==
                                                      null
                                                  ? 'Please select your category'
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          /* Container(
                                    //Sub Category
                                    width: 340,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: DropdownButton<String>(
                                      hint: Text(
                                        "Sub Category",
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                      underline:
                                          Container(color: Colors.transparent),
                                      items: category,
                                      onChanged: disabledropdown
                                          ? null
                                          : (_value) => secondselected(_value),
                                      //  validator: (value) => value == null? 'Please select your sub category': null,
                                    ),
                                  ),  
                                  Container(
                                    padding: EdgeInsets.only(bottom: 15.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 1.0, color: Colors.grey),
                                      ),
                                    ),
                                    width: 295,
                                    child: Text(
                                      "$value2",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),  */
                                          SizedBox(
                                            height: 22.0,
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: MultiSelect(
                                                enabledBorderColor:
                                                    Colors.white,
                                                selectIcon: Icons
                                                    .keyboard_arrow_down_sharp,
                                                selectIconColor: Colors.black,
                                                autovalidate: false,
                                                titleTextColor: Colors.black87,
                                                titleText: "Sub Category",
                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Please select one or more option(s)';
                                                  }
                                                },
                                                errorText:
                                                    'Please select one or more option(s)',
                                                dataSource: getSubCat(),
                                                textField: 'display',
                                                valueField: 'value',
                                                filterable: true,
                                                //     required: true,
                                                initialValue: _myActivities,
                                                value: null,
                                                change: (values) {
                                                  _myActivities = values;
                                                },
                                                onSaved: (value) {
                                                  setState(() {});
                                                }),
                                          ),
                                          Container(
                                            padding:
                                                EdgeInsets.only(bottom: 15.0),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                            width: 295,
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              FadeAnimation(
                                1.7,
                                Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ButtonTheme(
                                          height: 50,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            onPressed: () {
                                              if (_formkey.currentState
                                                  .validate()) {
                                                sendOTP(); // if all form valid send validation key to your email

                                              }
                                            },
                                            color: Colors.blue,
                                            child: Text(
                                              'Continue',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: ButtonTheme(
                                          height: 50.0,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            onPressed: () {
                                              print(_myActivities);
                                              widget.tv();
                                            },
                                            color: Colors.blue,
                                            child: Text(
                                              'Log In',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                error,
                                style: TextStyle(
                                    color: Colors.red, fontSize: 20.0),
                              )
                            ],
                          )),
                        ),
                      ),
                    ])));
  }
}
