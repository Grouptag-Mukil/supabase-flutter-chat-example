import 'dart:async';
import 'dart:ffi';

import 'package:chatsupabase/screens/friends.dart';
import 'package:flutter/material.dart';

import 'package:chatsupabase/models/message.model.dart';
import 'package:chatsupabase/const/helpers.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

import 'package:chatsupabase/extend/conversation.class.dart';
import 'package:flutter/services.dart';

Conversation? currentConversation;

bool isReplying = false;

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.conversationId, required this.name})
      : super(key: key);
  final int conversationId;
  final String name;

  static Route<void> route(
      {required int conversationId, required String name}) {
    return MaterialPageRoute(
      builder: (context) =>
          ChatPage(conversationId: conversationId, name: name),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  late final int _conversationId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _conversationId = widget.conversationId;
    currentConversation = Conversation(id: _conversationId, name: widget.name);
    logger.d("conversationId-log: $_conversationId");
    final currentUser = GetIt.instance<SupabaseClient>().auth.currentUser!.id;

    supabase
        .from('messages')
        .select()
        .eq('conversation_id', _conversationId)
        .then((value) => logger.d("test-log: $value"));

    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', _conversationId)
        .order('created_at')
        .map((maps) => maps
            .map((map) => Message.fromMap(map: map, currentUser: currentUser))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(FriendsScreen.route());
            },
          )),
      body: StreamBuilder<List<Message>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          logger.d("snapshot-log: $snapshot");
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            return Column(
              children: [
                Expanded(
                    child: messages.isEmpty
                        ? const Center(
                            child: Text('Start your conversation now :)'),
                          )
                        : SizedBox(
                            height: 200,
                            child: ListView.builder(
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];

                                /// I know it's not good to include code that is not related
                                /// to rendering the widget inside build method, but for
                                /// creating an app quick and dirty, it's fine.
                                //_loadProfileCache(message.profileId);

                                return _ChatBubble(
                                  message: message,
                                  //profile: _profileCache[message.profileId],
                                );
                              },
                            ),
                          )),
                _MessageBar(isReply: isReplying),
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  final bool isReply;

  const _MessageBar({
    Key? key,
    required this.isReply,
  }) : super(key: key);

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;
  final int _messageLength = 300;
  late bool isReply;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (widget.isReply)
                Expanded(
                  child: Text('Replying to ${currentConversation!.name}'),
                ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  maxLength: _messageLength,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(currentConversation!.id),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage(int conversationId) async {
    final text = _textController.text;
    final currentUser = GetIt.instance<SupabaseClient>().auth.currentUser!.id;
    final _conversationId = conversationId;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase.from('messages').insert({
        'conversation_id': _conversationId,
        'sender_id': currentUser,
        'content': text,
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    Key? key,
    required this.message,
    //required this.profile,
  }) : super(key: key);

  final Message message;

  //final Profile? profile;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine)
        // CircleAvatar(
        //   child: profile == null
        //       ? preloader
        //       : Text(profile!.username.substring(0, 2)),
        // ),
        const SizedBox(width: 12),
      Flexible(
        child: GestureDetector(
          onLongPress: () {
            logger.d("long press");
            openBottomContext(context,
                messageId: message.id, messageText: message.content);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: message.isMine
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(message.content),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}


class BottomContextBar extends StatelessWidget {
  final int messageId;
  final String messageText;

  const BottomContextBar({
    Key? key,
    required this.messageId,
    required this.messageText,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Message ID: $messageId'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {
                    isReplying = true;
                    Navigator.pop(context);
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: const Icon(
                    Icons.reply,
                    size: 35.0,
                  ),
                  padding: const EdgeInsets.all(15.0),
                  shape: const CircleBorder(),
                ),
                const SizedBox(width: 24),
                RawMaterialButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: messageText));
                    Navigator.pop(context);
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: const Icon(
                    Icons.copy,
                    size: 35.0,
                  ),
                  padding: const EdgeInsets.all(15.0),
                  shape: const CircleBorder(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

void openBottomContext(BuildContext context,
    {required int messageId, required String messageText}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return BottomContextBar(messageId: messageId, messageText: messageText);
    },
  );
}
