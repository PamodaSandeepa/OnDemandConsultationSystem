import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/videochat/pages/chatMessage.dart';
import 'package:firebaseapp/videochat/pages/index.dart';
import 'package:firebaseapp/videochat/pages/meeting.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:http/http.dart' as http;

import '../utils/settings.dart';

class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const CallPage({Key key, this.channelName, this.role}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState(channelName);
}

class _CallPageState extends State<CallPage> {
  String channelName;
  _CallPageState(this.channelName);

  final _users = <int>[];
  final _hosts = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;
  bool isOff = true;
  int _currentIndex = 0;
  Server s = new Server();

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    func();
  }

  //----------------------------------------------------------------------------RTM chat-Pamoda
  List<ChatMessage> _infoString = []; //insert to text messages
  final _channelMessageController = TextEditingController();
  AgoraRtmChannel _channel;
  AgoraRtmClient _client;

  Future<void> func() async {
    await getUserID();
    //  await getMeetingData();
    //await getRTMtoken(id, endTime, meetingDate);
    await createClient();
    await login();
    await joinChannel();
  }

  //----------------------get the current user id
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

  //-------------------------------------------------
  //------------------------get endTime and meetingDate
  String retrieveendTime = "";
  String retrievemeetingDate = "";
  final mainref = FirebaseDatabase.instance;
  Future<void> getMeetingData() async {
    final ref =
        mainref.reference().child('Meeting').child('$channelName').child('$id');
    await ref.child('rtmToken').once().then((DataSnapshot snapshot) {
      setState(() {
        mToken = snapshot.value;
        print(mToken);
      });
    });
  }
  //----------------------------------------------------

  Map rtmToken;
  var mToken =
      "00673f4c8bd376d43c5a083825c44db019fIADqlwg8VZ8b2HyzwS8C2KlYbzEggZFUSfZJ7hIl/OPHHmo54NAAAAAAIgDDV0tBSwikYAQAAQAMw6JgAgAMw6JgAwAMw6JgBAAMw6Jg";
  Map<String, String> headers = {'content-type': 'application/json'};
  Future<void> getRTMtoken(String uid, String eTime, String mDate) async {
    //method to get RTM token
    http.Response response = await http.post('http://10.0.2.2:3000/rtmToken',
        headers: headers,
        body: '{"user":"${uid}","eTime":"${eTime}","mDate":"${mDate}"}');
    rtmToken = json.decode(response.body);

    setState(() {
      mToken = rtmToken['key'];
    });
    print(mToken);
  }

  Future<void> createClient() async {
    _client = await AgoraRtmClient.createInstance(
        "778885f2d7b34ad7b2024d2711343cee"); //  //73f4c8bd376d43c5a083825c44db019f
  }

  Future<void> login() async {
    String userId = '$id';

    _client.login(
        //AgoraRTM client can login to chat by using their id and generated unique token(more secure)
        null,
        userId);
  }

  Future<void> joinChannel() async {
    String channelId = channelName; //channel is come from video chat

    _channel = await _createChannel(
        channelId); //AgoraRTM channel is created to that channel name
    await _channel.join();
  }

  void sendChannelMessage() async {
    //send a message
    String text = _channelMessageController.text;
    _channelMessageController.text = "";
    if (text.isEmpty) {
      return;
    }
    try {
      await _channel.sendMessage(
          AgoraRtmMessage.fromText(text)); //text is sent to the other person
      _send(text, true); //pass to _send method
    } catch (errorCode) {}
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);
    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      //get the received message
      _send(message.text, false); //pass to _send method
    };
    return channel;
  }

  void _send(String info, bool send) {
    print(info);
    setState(() {
      if (send == true) {
        //if send is true it means it is sending message
        _infoString.insert(0, ChatMessage(message: "$info", n: 1));
      } else {
        //if send is false it is received message
        _infoString.insert(0, ChatMessage(message: "$info", n: 0));
      }
    });
  }

  //-------------------------------------------------------------------------------------------------------------------------------

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(160, 160);
    // 1920, 1080
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(Token, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
  }

  Future<void> _closeVideo() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.disableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        // _users.add(uid);
        _hosts.add(uid);
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
        print(_users);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // RawMaterialButton(
          //   onPressed: _onToggleMute,
          //   child: Icon(
          //     muted ? Icons.mic_off : Icons.mic,
          //     color: muted ? Colors.white : Colors.blueAccent,
          //     size: 20.0,
          //   ),
          //   shape: CircleBorder(),
          //   elevation: 2.0,
          //   fillColor: muted ? Colors.blueAccent : Colors.white,
          //   padding: const EdgeInsets.all(12.0),
          // ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          // FloatingActionButton(
          //   onPressed: () {
          //     print(_users);
          //   },
          //   child: Icon(Icons.people_alt),
          // ),
          FloatingActionButton(
              child: Icon(Icons.screen_share),
              onPressed: () {
                _engine.muteAllRemoteVideoStreams(muted);
              })
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  //-------------------------------------------------------------------User Interface for rtm chat

  Widget _rtmChat() {
    return Scaffold(
      body: Container(
          child: Column(children: [
        Expanded(
          flex: 9,
          child: Container(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.only(left: 12, right: 12, top: 60, bottom: 3),
              //   itemExtent: 100,
              // shrinkWrap: true,
              //   scrollDirection: Axis.horizontal,
              itemCount: _infoString.length, //get the length of infoStrings
              itemBuilder: (context, i) {
                return Container(
                    child: _infoString[i].n == 1 //sender
                        ? ChatBubble(
                            clipper:
                                ChatBubbleClipper1(type: BubbleType.sendBubble),
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(top: 8, bottom: 8),
                            backGroundColor: Colors.blue,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: Text(
                                _infoString[i].message,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        : ChatBubble(
                            //reciever
                            clipper: ChatBubbleClipper1(
                                type: BubbleType.receiverBubble),
                            backGroundColor: Color(0xffE7E7ED),
                            margin: EdgeInsets.only(top: 8, bottom: 8),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: Text(
                                _infoString[i].message,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ));
              },
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Row(children: <Widget>[
              Expanded(
                  child: TextField(
                      controller: _channelMessageController,
                      decoration: InputDecoration(hintText: 'Type'))),
              FloatingActionButton(
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: sendChannelMessage,
              )
            ]),
          ),
        )
      ])),
    );
  }

  //-----------------------------------------------------------------------------------------------------

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onToggleCameraMute() {
    setState(() {
      this.isOff != isOff;
    });
    _engine.muteLocalVideoStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolbar(),
          ],
        ),
      ),
      /*   Center(
          child: Container(
        width: 150,
        height: 150.0,
        decoration: BoxDecoration(color: Colors.white),
        child: Text('$_hosts'),
      )),  */
      Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolbar(),
          ],
        ),
      ),
      Center(
          child: isOff
              ? Stack(
                  children: <Widget>[
                    _viewRows(),
                    _panel(),
                    _toolbar(),
                  ],
                )
              : Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(color: Colors.black),
                  child: Image.asset('images/Men-Profile-Image-715x657.png'),
                )),
      Center(
        child: Stack(
          children: <Widget>[_rtmChat()],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Conference',
            style: TextStyle(color: Colors.blueAccent)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blueAccent,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
              backgroundColor: Colors.blue),
          /*    BottomNavigationBarItem(
              icon: Icon(Icons.group),
              title: Text('Participant'),
              backgroundColor: Colors.blue), */
          BottomNavigationBarItem(
              icon: muted ? Icon(Icons.mic_off) : Icon(Icons.mic),
              title: Text('Voice'),
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon:
                  Icon(isOff ? Icons.camera_alt_rounded : Icons.tv_off_rounded),
              title: Text('Camera'),
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              title: Text('Chat'),
              backgroundColor: Colors.blue),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            print(_currentIndex);
            if (index == 1) {
              _onToggleMute();
            }
            if (index == 2) {
              if (isOff) {
                _closeVideo();
                isOff = false;
              } else {
                _initAgoraRtcEngine();
                isOff = true;
              }

              print(isOff);
            }
          });
        },
      ),
    );
  }
}
