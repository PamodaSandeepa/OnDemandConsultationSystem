import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/edit_profile/settings.dart';
import 'package:firebaseapp/shared/loading.dart';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _loading = true;
  bool isImg = true;
  String retrievedfName = "";
  String retrievedsName = "";
  String retrieveddescription = "";
  String retrievedmobileNo = "";
  String retrievedcountryisoCode = "";
  String retrievedaccountNo = "";
  String retrievedfield = "";
  String previousfield = "";
  String previoussubField = "";
  String retrievedsubField = "";
  String retrievedaverageRating = "";
  bool retrievedverified = false;
  List _myActivities = [];
  List _previousActivities = [];
  String retrievedproPic = "";
  String url = "";
  var today;
  var fiftyDaysFromNow;

  final mainref = FirebaseDatabase.instance;
  final cloudRef = Firestore.instance;
  TextEditingController _controllerfName = new TextEditingController();
  TextEditingController _controllersName = new TextEditingController();
  TextEditingController _controllerdescription = new TextEditingController();
  TextEditingController _controlleraccountNo = new TextEditingController();
  TextEditingController _controllermobileNo = new TextEditingController();
  TextEditingController _controllerCategory = new TextEditingController();

  String value1 = "";
  String value2 = "";
  bool disabledropdown = false;
  bool isActive = true;
  String k;
  int v;

  final _formkey = GlobalKey<FormState>(); //help the validate

//--------------------Retrive user id from firebase
  FirebaseUser user;
  String id;
  Future<void> getUserID() async {
    final FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      id = userData.uid.toString();
      print(userData.uid);
    });
  }
//------------------------------------------------------

//----------------------------------Retrieve userData from firebase
  Future<void> getUserData() async {
    final ref = mainref.reference().child('Consultants').child('$id');
    await ref.child('proPic').once().then((DataSnapshot snapshot) {
      setState(() {
        isImg = false;
        retrievedproPic = snapshot.value;

        print(retrievedproPic);
      });
    });
    await ref.child('firstName').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedfName = snapshot.value;
        print(retrievedfName);
        _controllerfName.text = retrievedfName;
      });
    });
    await ref.child('secondName').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedsName = snapshot.value;
        print(retrievedsName);
        _controllersName.text = retrievedsName;
      });
    });
    await ref.child('description').once().then((DataSnapshot snapshot) {
      setState(() {
        retrieveddescription = snapshot.value;
        print(retrieveddescription);
        _controllerdescription.text = retrieveddescription;
      });
    });
    await ref.child('mobileNumber').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedmobileNo = snapshot.value;
        print(retrievedmobileNo);
        _controllermobileNo.text = retrievedmobileNo.substring(3, 13);
      });
    });
    await ref.child('country').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedcountryisoCode = snapshot.value;
        print(retrievedcountryisoCode);
      });
    });
    await ref.child('accountNo').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedaccountNo = snapshot.value;
        print(retrievedaccountNo);
        _controlleraccountNo.text = retrievedaccountNo;
      });
    });
    await ref.child('verified').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedverified = snapshot.value;
        print(retrievedverified);
      });
    });
    await ref.child('averageRating').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedaverageRating = snapshot.value;
        print(retrievedaverageRating);
      });
    });
    await ref.child('field').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedfield = snapshot.value;
        previousfield = snapshot.value;
        _controllerCategory.text = retrievedfield;
        print(retrievedfield);
      });
    });
    await ref.child('subField').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedsubField = snapshot.value;
        previoussubField = snapshot.value;
        print(retrievedsubField);
        if (retrievedfield == "Medical") {
          category = [];
          populateMedical();
          v = 1;
        } else if (retrievedfield == "Law") {
          category = [];
          populateLaw();
          v = 2;
        } else if (retrievedfield == "Education") {
          category = [];
          populateEducation();
          v = 3;
        } else if (retrievedfield == "Counseling") {
          category = [];
          populateCounseling();
          v = 4;
        } else if (retrievedfield == "Business") {
          category = [];
          populateBusiness();
          v = 5;
        }
      });
    });
    await ref.child('subFields').once().then((DataSnapshot snapshot) {
      setState(() {
        _myActivities = snapshot.value;
        _previousActivities = snapshot.value;
        print(_myActivities);
      });
    });
    if (retrievedproPic == "") {
      url =
          "https://inlandfutures.org/wp-content/uploads/2019/12/thumbpreview-grey-avatar-designer.jpg"; //anonymous profile picture
    } else {
      await downloadImage();
    }
    _loading = false;
  }

  //---------------------------------------------------------------------

//-------------------------------Retrieve pro pic from firebase storage
  Future downloadImage() async {
    StorageReference _reference =
        FirebaseStorage.instance.ref().child("$retrievedproPic");
    String downloadAddress = await _reference.getDownloadURL();
    setState(() {
      url = downloadAddress;

      print(url);
    });
  }

  //--------------------------------------------------------------------------

  //-------init function can not make as asynchronous function
  Future<void> getData() async {
    await getUserID();
    await getUserData();
  }
  //-----------------------------------------------

  void initState() {
    super.initState();
    getData();
  }

  /*   
    ref.once().then((DataSnapshot snapshot) async {
      await Map<dynamic, dynamic>.from(snapshot.value).forEach((key, values) {
        setState(() {
          retrievedfName = values["firstName"];
          retrievedsName = values["secondName"];
        });
      });
    });
    
    
   */

  //-------------------propic uploading

  File __image;
  String pathImg = "";

  Future getPic() async {
    isImg = true;
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      __image = image;
      print('Image Path $__image');
      pathImg = basename(__image.path);
    });
  }

  Future uploadPic(BuildContext context) async {
    String imageName = basename(__image.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(imageName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(__image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    url = await (taskSnapshot).ref.getDownloadURL();
    final mainRef = FirebaseDatabase.instance;
    final ref = mainRef.reference().child('Consultants').child('$id');
    ref.child("proPicURL").set(url);
    setState(() {
      print("Profile Picture uploaded");
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
    });
  }

//----------------------------------------------------

  //--------------------------------Consultant Category

  List<DropdownMenuItem<String>> category = List();

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
    for (String key in Medical.keys) {
      if (Medical[key] == "$retrievedsubField") {
        k = key;
      }
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
    for (String key in Law.keys) {
      if (Law[key] == "$retrievedsubField") {
        k = key;
      }
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
    for (String key in Education.keys) {
      if (Education[key] == "$retrievedsubField") {
        k = key;
      }
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
    for (String key in Counseling.keys) {
      if (Counseling[key] == "$retrievedsubField") {
        k = key;
      }
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
    for (String key in Business.keys) {
      if (Business[key] == "$retrievedsubField") {
        k = key;
      }
    }
    /*for (int v in Education.keys) {
      multiItem.add(MultiSelectDialogItem(v, Education[v]));
    } */
  }

  void selected(_value) {
    if (_value == "Medical") {
      category = [];
      populateMedical();
    } else if (_value == "Law") {
      category = [];
      populateLaw();
    } else if (_value == "Education") {
      category = [];
      populateEducation();
    } else if (_value == "Counseling") {
      category = [];
      populateCounseling();
    } else if (_value == "Business") {
      category = [];
      populateBusiness();
    }
    setState(() {
      isActive = false;
      retrievedfield = _value;
      retrievedsubField = "";
      disabledropdown = false;
    });
  }

  void secondselected(_value) {
    setState(() {
      retrievedsubField = _value;
      //    isActive = false;
    });
  }

  getSubCat() {
    switch (v) {
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

//--------------------------------------------------------

//--------------------------------- method to get initial sub category
  getCategory() {
    return "$retrievedfield";
  }
  //--------------------------------------------

  //---------------------snackBar to view changed data sucessessfully saved
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _showSnackBar() {
    final snackBar = new SnackBar(
        content: new Text(
          "Sucessfully Saved",
          textAlign: TextAlign.center,
        ),
        duration: new Duration(seconds: 3),
        backgroundColor: Colors.blueAccent);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  //-------------------------------------------------------

  //-------------------------User Interface
  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 1,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Home()));
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => SettingsPage()));
                  },
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.only(left: 16, top: 25, right: 16),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Form(
                  key: _formkey,
                  child: ListView(
                    children: [
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Stack(
                          //Profile picture
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: isImg
                                        ? FileImage(__image)
                                        : NetworkImage(url),
                                    fit: BoxFit.cover),
                                border: Border.all(
                                    width: 4,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(0, 10))
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
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 4,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    color: Colors.blue,
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      getPic();
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: TextFormField(
                              //First Name
                              readOnly: true,
                              controller: _controllerfName,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                labelStyle: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    fontFamily: 'AvenirLight'),
                                //       hintText: 'First Name',
                                fillColor: Colors.grey[300],
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey[300], width: 3.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2.0)),
                              ),
                              onChanged: (val) {
                                setState(() {});
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
                            width: 2,
                          ),
                          Expanded(
                            flex: 8,
                            child: TextFormField(
                              //Second Name
                              readOnly: true,
                              controller: _controllersName,
                              decoration: InputDecoration(
                                labelText: 'Second Name',
                                labelStyle: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    fontFamily: 'AvenirLight'),
                                //      hintText: 'Second Name',
                                fillColor: Colors.grey[300],
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey[300], width: 3.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2.0)),
                              ),
                              onChanged: (val) {
                                setState(() {});
                              },
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return "Enter second name";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        //Description
                        controller: _controllerdescription,
                        decoration: InputDecoration(
                          //   prefixIcon: Icon(Icons.note),
                          labelText: 'Description',
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontFamily: 'AvenirLight'),
                          //    hintText: 'Description',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 3.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.pinkAccent, width: 2.0)),
                        ),

                        //  validator: (val)=>val.isEmpty?'Enter an email':null,  //Empty or not
                        onChanged: (val) {
                          retrieveddescription = val;
                          //val means current value in form field
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter description";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        //Mobile Number
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: IntlPhoneField(
                          controller: _controllermobileNo,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            labelStyle: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontFamily: 'AvenirLight'),
                            //  prefixIcon:Icon(Icons.mobile_screen_share),
                            //    hintText: 'Mobile Number',
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white, width: 3.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.pinkAccent, width: 2.0)),
                          ),
                          initialCountryCode: retrievedcountryisoCode,
                          onChanged: (phone) {
                            setState(() {
                              retrievedmobileNo = phone.completeNumber;
                              retrievedcountryisoCode = phone.countryISOCode;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        //AccountNumber
                        controller: _controlleraccountNo,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(12),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontFamily: 'AvenirLight'),
                          //   prefixIcon: Icon(Icons.home),
                          //    hintText: 'Account Number',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 3.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.pinkAccent, width: 2.0)),
                        ),
                        onChanged: (val) {
                          retrieveddescription = val;
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
                        height: 20.0,
                      ),
                      TextFormField(
                        //Second Name
                        readOnly: true,
                        controller: _controllerCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontFamily: 'AvenirLight'),
                          //      hintText: 'Second Name',
                          fillColor: Colors.grey[300],
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey[300], width: 3.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.pinkAccent, width: 2.0)),
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Enter second name";
                          }
                          return null;
                        },
                      ),
                      /*   Container(
                        //category
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonFormField<String>(
                          value: getCategory(),
                          autofocus: false,
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
                          onChanged: (_value) => selected(_value),
                          validator: (value) => value == null
                              ? 'Please select your category'
                              : null,
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        //sub category
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButton<String>(
                          underline: Container(color: Colors.transparent),
                          hint: Text(
                            "Sub Category",
                            style: TextStyle(fontSize: 12.0),
                          ),
                          items: category,
                          onChanged:
                              //  disabledropdown? null:
                              (_value) => secondselected(_value),
                          //   validator: (value) => value == null? 'Please select your sub category': null,
                        ),
                      ),
                      Container(
                        margin: new EdgeInsets.only(
                            left: 16.0, bottom: 18.0, right: 16.0),
                        padding: EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1.0, color: Colors.grey),
                          ),
                        ),
                        child: Text(
                          "$retrievedsubField",
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
                        padding: EdgeInsets.only(left: 4.0, right: 4.0),
                        child: MultiSelect(
                            autovalidate: false,
                            titleTextColor: Colors.black,
                            titleText: "Sub Category",
                            validator: (value) {
                              if (value == null) {
                                return 'Please select one or more option(s)';
                              }
                            },
                            errorText: 'Please select one or more option(s)',
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
                      SizedBox(
                        height: 22.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => Home()));
                            },
                            child: Text("CANCEL",
                                style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 2.2,
                                    color: Colors.black)),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          RaisedButton(
                            onPressed: () {
                              final mainRef = FirebaseDatabase.instance;
                              final CollectionReference consultants =
                                  cloudRef.collection('Consultants');
                              final ref = mainRef
                                  .reference()
                                  .child('Consultants')
                                  .child('$id');
                              final cat =
                                  mainRef.reference().child('Categories');
                              for (int i = 0;
                                  i < _previousActivities.length;
                                  i++) {
                                cat
                                    .child(
                                        "$retrievedfield-${_previousActivities[i]}")
                                    .child('$id')
                                    .remove();
                              }
                              uploadPic(context);

                              if (_formkey.currentState.validate()) {
                                ref
                                    .child("description")
                                    .set(retrieveddescription);
                                ref
                                    .child("mobileNumber")
                                    .set(retrievedmobileNo);
                                ref
                                    .child("country")
                                    .set(retrievedcountryisoCode);
                                ref.child("accountNo").set(retrievedaccountNo);
                                ref.child("field").set(retrievedfield);
                                //    ref.child("subField").set(retrievedsubField);
                                ref
                                    .child("subFields")
                                    .set(_myActivities); //list

                                if (isImg == true) {
                                  ref.child("proPic").set(
                                      pathImg); //if profile picture changed
                                } else {
                                  ref.child("proPic").set(
                                      retrievedproPic); //if profile picture not change
                                }

                                //----------------------------tag for consultant category

                                for (int i = 0; i < _myActivities.length; i++) {
                                  cat
                                      .child(
                                          "$retrievedfield-${_myActivities[i]}")
                                      .child('$id')
                                      .child("firstName")
                                      .set(retrievedfName);
                                  cat
                                      .child(
                                          "$retrievedfield-${_myActivities[i]}")
                                      .child('$id')
                                      .child("secondName")
                                      .set(retrievedsName);
                                  cat
                                      .child(
                                          "$retrievedfield-${_myActivities[i]}")
                                      .child('$id')
                                      .child("proPicURL")
                                      .set(url);
                                  cat
                                      .child(
                                          "$retrievedfield-${_myActivities[i]}")
                                      .child('$id')
                                      .child("verified")
                                      .set(retrievedverified);
                                  cat
                                      .child(
                                          "$retrievedfield-${_myActivities[i]}")
                                      .child('$id')
                                      .child("averageRating")
                                      .set(retrievedaverageRating);
                                  cat
                                      .child(
                                          "$retrievedfield-${_myActivities[i]}")
                                      .child('$id')
                                      .child("uid")
                                      .set(id);
                                }

                                consultants
                                    .document(
                                        '$retrievedfield-$retrievedsubField')
                                    .collection('$id')
                                    .document()
                                    .setData({
                                  'id': id,
                                  'name': retrievedfName,
                                  'proPic': isImg ? pathImg : retrievedproPic
                                });
                                //-------------------------------------------------
                              }
                              _showSnackBar();
                            },
                            color: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              "SAVE",
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.2,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
