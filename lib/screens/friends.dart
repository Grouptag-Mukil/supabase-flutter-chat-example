import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:supabase/supabase.dart' as supa;
import 'package:chatsupabase/models/conversation.model.dart';
import 'package:chatsupabase/screens/chat.dart';

var logger = Logger();

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const FriendsScreen(),
    );
  }

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: SizedBox(
        child: ListView.builder(
          itemCount: _conversations.length,
          itemBuilder: (context, index) {
            final conversation = _conversations[index];
            return ListTile(
              title: Text(conversation.name ?? "No name"),
              subtitle: Text("${conversation.id}"),
              onTap: () {
                // TODO: Navigate to conversation page
                Navigator.of(context).pushAndRemoveUntil(
                    ChatPage.route(
                        conversationId: conversation.id,
                        name: conversation.name ?? "No name"),
                    (route) => false);
              },
            );
          },
        ),
      ),
    );
  }

  void _fetchConversations() async {
    final currentUser =
        GetIt.instance<supa.SupabaseClient>().auth.currentUser!.id;

    logger.d("currentUser-log: $currentUser");

    List<dynamic>? response;

    try {
      response = await GetIt.instance<supa.SupabaseClient>()
          .rpc("get_conversations", params: {"user_id": currentUser});
    } catch (e) {
      logger.e("response-error: $e");
    }

    if (response == null) {
      // Handle error
      logger.e("response.error: ${response}");
      return;
    }

    if (response.isEmpty) {
      // text = "No error";
      logger.e("response.error: ${response}");
      return;
    }

    // if (response is! List<Map<String, dynamic>>) {
    //   logger.e("response has unexpected type: ${response.runtimeType}");
    //   return;
    // }

    _setConversations(response);
  }

  void _setConversations(List<dynamic> conversationsJson) {
    logger.d("conversationsJson: $conversationsJson");
    final conversations =
        conversationsJson.map((json) => Conversation.fromJson(json)).toList();
    logger.d("conversations: $conversations");
    logger.d("conversationsLength: ${conversations.length}");
    setState(() {
      _conversations = conversations;
    });
  }
}
