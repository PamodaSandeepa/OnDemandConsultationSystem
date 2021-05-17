import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Mod {
  final String key;
  final String name;
  final int rating;
  final String text;
  final String url;

  Mod(this.key, this.name, this.rating, this.text, this.url);

  Mod.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        rating = snapshot.value['rating'],
        text = snapshot.value['text'],
        url = snapshot.value['proPicURL'];
  toJson() {
    return {
      "key": key, //number
      "name": name,
      "rating": rating,
      "text": text,
      "url": url
    };
  }
}

class Review extends StatefulWidget {
  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final review = FirebaseDatabase.instance;
  DatabaseReference ref;
  bool _loading = true;

  //------------------------------Retrive user id from firebase
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

  //-----------------------------------------------------------------
  //-----------------------------------get user data
  String averageRating = "";
  final mainref = FirebaseDatabase.instance;
  Future<void> getUserData() async {
    final ref = mainref.reference().child('Consultants').child('$id');
    await ref.child('averageRating').once().then((DataSnapshot snapshot) {
      setState(() {
        averageRating = snapshot.value;
      });
    });
  }

//----------------------------------------------------------------------------------------------calculate ratings
  var entries = [];
  Future<void> getReviewNames() async {
    final response = FirebaseDatabase.instance.reference().child('Reviews');

    await response.child('$id').once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values == null) {
        return;
      }
      for (String key in values.keys) {
        entries.add(key);
      }
    });

    print(entries);
  }

  var ratings = [];
  Future<void> getRatingValues() async {
    final response =
        FirebaseDatabase.instance.reference().child('Reviews').child('$id');
    for (int i = 0; i < entries.length; i++) {
      await response
          .child('${entries[i]}')
          .child('rating')
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value == null) {
          return;
        }
        ratings.add(snapshot.value);
      });
    }

    print(ratings);
  }

  Future<void> reviewsData() async {
    //call from initState
    await getReviewNames();
    await getRatingValues();
    await getRatings();
  }

  int a = 0;
  int b = 0;
  int c = 0;
  int d = 0;
  int e = 0;
  double rating1;
  double rating2;
  double rating3;
  double rating4;
  double rating5;
  Future<void> getRatings() async {
    for (int i = 0; i < ratings.length; i++) {
      if (ratings[i] == 1) {
        a++;
      } else if (ratings[i] == 2) {
        b++;
      } else if (ratings[i] == 3) {
        c++;
      } else if (ratings[i] == 4) {
        d++;
      } else {
        e++;
      }
    }
    setState(() {
      if (ratings.length == 0) {
        rating1 = 0.0;
        rating2 = 0.0;
        rating3 = 0.0;
        rating4 = 0.0;
        rating5 = 0.0;
      } else {
        rating1 = double.parse((a / ratings.length).toStringAsFixed(1));
        rating2 = double.parse((b / ratings.length).toStringAsFixed(1));
        rating3 = double.parse((c / ratings.length).toStringAsFixed(1));
        rating4 = double.parse((d / ratings.length).toStringAsFixed(1));
        rating5 = double.parse((e / ratings.length).toStringAsFixed(1));
      }
      print(rating1);
      print(rating2);
      print(rating3);
      print(rating4);
      print(rating5);
    });
    _loading = false;
  }
  //--------------------------------------------------------------------------------------------------------

/*
  //------------------get review data from database
  List<Modal> itemList = List();
  Future<void> getUserData() async {
    review
        .reference()
        .child('Reviews')
        .child('$id')
        .once()
        .then((DataSnapshot snap) {
      //get data from firebase
      var data = snap.value;
      itemList.clear();
      data.forEach((key, value) {
        Modal m = new Modal(value['name'], value['rating'], value['text']);
        itemList.add(m);
      });
      setState(() {});
    });
  }

  //--------------------------------------------------------------------
*/

  List<Mod> reviews;
  Mod rev;

//-----------------------------------get data from database
  Future<void> getData() async {
    reviews = new List(); //empty list
    rev = Mod("", "", null, "", "");
    ref = review.reference().child('Reviews').child('$id');
    ref.onChildAdded.listen(_onEntryAdded); //
    ref.onChildChanged.listen(_onEntryChanged);
  }
  //------------------------------------------------

  _onEntryAdded(Event event) {
    setState(() {
      reviews.add(Mod.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = reviews.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      reviews[reviews.indexOf(old)] = Mod.fromSnapshot(event.snapshot);
    });
  }

  Future<void> getReviews() async {
    await getUserID();
    await getData();
    await getUserData();
    await reviewsData();
  }

  void initState() {
    super.initState();
    getReviews();
  }

  //---------------------------------User Interface
  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
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
            ),
            // resizeToAvoidBottomPadding: false,
            body: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ratings and Reviews",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueAccent),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.4),
                              offset: Offset(0, 10))
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5))),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Row(
                        children: [
                          Text(
                            "$averageRating",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueAccent),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Text(
                                          '5',
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 3.0,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200.0,
                                          lineHeight: 8.0,
                                          percent: rating5,
                                          progressColor: Colors.blue,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '4',
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 3.0,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200.0,
                                          lineHeight: 8.0,
                                          percent: rating4,
                                          progressColor: Colors.blue,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '3',
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 3.0,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200.0,
                                          lineHeight: 8.0,
                                          percent: rating3,
                                          progressColor: Colors.blue,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '2',
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 3.0,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200.0,
                                          lineHeight: 8.0,
                                          percent: rating2,
                                          progressColor: Colors.blue,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '1',
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 3.0,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200.0,
                                          lineHeight: 8.0,
                                          percent: rating1,
                                          progressColor: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Flexible(
                  child: FirebaseAnimatedList(
                    query: ref,
                    itemBuilder: (BuildContext context, DataSnapshot snapshot,
                        Animation<double> animation, int index) {
                      return Container(
                        padding: EdgeInsets.all(10.0),
                        child: new Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  colors: [
                                    Colors.blue[300],
                                    Colors.blue[200],
                                    Colors.blue[100]
                                  ]),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.4),
                                    offset: Offset(0, 10))
                              ],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                          //     color: Colors.blueAccent,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: '${reviews[index].url}' == ""
                                                ? AssetImage('assets/anon.png')
                                                : NetworkImage(
                                                    '${reviews[index].url}')),
                                        border: Border.all(
                                            width: 1,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor),
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              offset: Offset(0, 10))
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      '${reviews[index].name}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17.0),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: RatingBarIndicator(
                                    rating: reviews[index].rating.toDouble(),
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('${reviews[index].text}')),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  /*
  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
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
            ),
            resizeToAvoidBottomPadding: false,
            body: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ratings and Reviews",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueAccent),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: itemList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(10.0),
                        child: new Card(
                          color: Colors.white60,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image:
                                                AssetImage('assets/anon.png')),
                                        border: Border.all(
                                            width: 1,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor),
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              offset: Offset(0, 10))
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      '${itemList[index].name}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17.0),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: RatingBarIndicator(
                                    rating: itemList[index].rating.toDouble(),
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('${itemList[index].text}')),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  */
}
