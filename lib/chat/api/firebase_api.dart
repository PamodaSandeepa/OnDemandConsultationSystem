
import 'package:firebaseapp/chat/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  static Future uploadMessage(String idUser, String message,String myId) async {
    final refMessages =
        Firestore.instance.collection('chats/$idUser/messages');

    final newMessage = Message(
      idUser: myId, //my id
      message: message,
      createdAt: DateTime.now(),
    );
    await refMessages.add(newMessage.toJson());

    /* final refUsers = FirebaseFirestore.instance.collection('users');
    await refUsers
        .doc(idUser)
        .update({UserField.lastMessageTime: DateTime.now()});  */
  }

  static Stream<List<Message>> getMessages(String idUser) =>
      Firestore.instance
          .collection('chats/$idUser/messages')
          .orderBy(MessageField.createdAt, descending: true)
          .snapshots()
          .transform(Utils.transformer(Message.fromJson));
}
