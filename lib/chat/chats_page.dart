import 'package:firebaseapp/chat/widget/messages_widget.dart';
import 'package:firebaseapp/chat/widget/new_message_widget.dart';
import 'package:firebaseapp/chat/widget/profile_header_widget.dart';
import 'package:flutter/material.dart';

class ChatsPage extends StatefulWidget {
  final String meetingId;
  final String receiverName;
  final String receiverId;
  final String myId;
  const ChatsPage({
    @required this.meetingId,
    @required this.receiverName,
    @required this.receiverId,
    @required this.myId,
    Key key,
  }) : super(key: key);
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    //   var messagesWidget = MessagesWidget;
    var newMessageWidget = NewMessageWidget;
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.blue,
        body: SafeArea(
          child: Column(
            children: [
              ProfileHeaderWidget(
                name: widget.receiverName,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: MessagesWidget(
                    idUser: widget.meetingId,
                    myId: widget.myId,
                  ), //meeting id
                ),
              ),
              NewMessageWidget(
                idUser: widget.meetingId, //meeting id
                myId: widget.myId,
              )
            ],
          ),
        ));
  }
}
