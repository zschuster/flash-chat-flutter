import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String routeName = 'chat_screen';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  String currentUserEmail;
  String message;
  TextEditingController messageController = TextEditingController();
  bool screenIsReady = false;

  // recursive
  void getCurrentUser() async {
    try {
      final FirebaseUser currentUser = await _auth.currentUser();
      if (currentUser != null) {
        currentUserEmail = currentUser.email;
      }
      print('got current user: $currentUserEmail');
    } catch (e) {
      getCurrentUser();
    }

    setState(() {
      screenIsReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            screenIsReady
                ? MessageStream(
                    firestore: _firestore,
                    user: currentUserEmail,
                  )
                : CircularProgressIndicator(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageController.clear();
                      _firestore.collection('messages').add({
                        'user': currentUserEmail,
                        'message': message,
                        'timestamp': DateTime.now().millisecondsSinceEpoch
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({
    Key key,
    @required Firestore firestore,
    @required this.user,
  })  : _firestore = firestore,
        super(key: key);

  final Firestore _firestore;
  final String user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final currentData = snapshot.data.documents;
          final List<MessageBubble> messageBubbles = [];
          for (var document in currentData) {
            String message = document.data['message'];
            String sender = document.data['user'];
            print('$sender, $user');
            messageBubbles.add(MessageBubble(
              message: message,
              sender: sender,
              isSender: sender == user,
            ));
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              children: messageBubbles,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key key,
    @required this.message,
    @required this.sender,
    @required this.isSender,
  }) : super(key: key);

  final String message;
  final String sender;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$sender',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Material(
            borderRadius: BorderRadius.circular(20),
            color: isSender ? Colors.teal : Colors.lightBlueAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Text(
                '$message',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
