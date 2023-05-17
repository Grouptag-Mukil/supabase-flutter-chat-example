// import 'dart:async';
//
// import 'package:chatsupabase/screens/friends.dart';
// import 'package:flutter/material.dart';
//
// import 'package:chatsupabase/models/message.model.dart';
// import 'package:chatsupabase/const/helpers.dart';
// import 'package:get_it/get_it.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:timeago/timeago.dart';
//
// /// Page to chat with someone.
// ///
// /// Displays chat bubbles as a ListView and TextField to enter new chat.
// class ChatPage extends StatefulWidget {
//   const ChatPage({Key? key, this.conversationId}) : super(key: key);
//   final int? conversationId;
//
//   static Route<void> route() {
//     return MaterialPageRoute(
//       builder: (context) => const ChatPage(),
//     );
//   }
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   late final Stream<List<Message>> _messagesStream;
//   late final int? _conversationId;
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     _conversationId = ModalRoute.of(context)!.settings.arguments as int?;
//     final currentUser = GetIt.instance<SupabaseClient>().auth.currentUser!.id;
//     logger.d("conversationId-log: $_conversationId");
//     _messagesStream = supabase
//         .from('messages')
//         .stream(primaryKey: ['id'])
//         .eq('conversation_id', _conversationId)
//         .order('created_at')
//         .map((maps) => maps
//         .map((map) => Message.fromMap(map: map, myUserId: currentUser))
//         .toList());
//     logger.d("messageStream-log: $_messagesStream");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chat')),
//       body: StreamBuilder<List<Message>>(
//         stream: _messagesStream,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final messages = snapshot.data!;
//             return Column(
//               children: [
//                 Expanded(
//                   child: messages.isEmpty
//                       ? const Center(
//                     child: Text('Start your conversation now :)'),
//                   )
//                       : ListView.builder(
//                     reverse: true,
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final message = messages[index];
//
//                       /// I know it's not good to include code that is not related
//                       /// to rendering the widget inside build method, but for
//                       /// creating an app quick and dirty, it's fine 😂
//                       //_loadProfileCache(message.profileId);
//
//                       return _ChatBubble(
//                         message: message,
//                         //profile: _profileCache[message.profileId],
//                       );
//                     },
//                   ),
//                 ),
//                 const _MessageBar(),
//               ],
//             );
//           } else {
//             return preloader;
//           }
//         },
//       ),
//     );
//   }
// }
//
// /// Set of widget that contains TextField and Button to submit message
// class _MessageBar extends StatefulWidget {
//   const _MessageBar({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<_MessageBar> createState() => _MessageBarState();
// }
//
// class _MessageBarState extends State<_MessageBar> {
//   late final TextEditingController _textController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.grey[200],
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   keyboardType: TextInputType.text,
//                   maxLines: null,
//                   autofocus: true,
//                   controller: _textController,
//                   decoration: const InputDecoration(
//                     hintText: 'Type a message',
//                     border: InputBorder.none,
//                     focusedBorder: InputBorder.none,
//                     contentPadding: EdgeInsets.all(8),
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => _submitMessage(),
//                 child: const Text('Send'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     _textController = TextEditingController();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }
//
//   void _submitMessage() async {
//     final text = _textController.text;
//     final currentUser = GetIt.instance<SupabaseClient>().auth.currentUser!.id;
//     if (text.isEmpty) {
//       return;
//     }
//     _textController.clear();
//     try {
//       await supabase.from('messages').insert({
//         'profile_id': currentUser,
//         'content': text,
//       });
//     } on PostgrestException catch (error) {
//       context.showErrorSnackBar(message: error.message);
//     } catch (_) {
//       context.showErrorSnackBar(message: unexpectedErrorMessage);
//     }
//   }
// }
//
// class _ChatBubble extends StatelessWidget {
//   const _ChatBubble({
//     Key? key,
//     required this.message,
//     //required this.profile,
//   }) : super(key: key);
//
//   final Message message;
//
//   //final Profile? profile;
//
//   @override
//   Widget build(BuildContext context) {
//     List<Widget> chatContents = [
//       if (!message.isMine)
//       // CircleAvatar(
//       //   child: profile == null
//       //       ? preloader
//       //       : Text(profile!.username.substring(0, 2)),
//       // ),
//         const SizedBox(width: 12),
//       Flexible(
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//             vertical: 8,
//             horizontal: 12,
//           ),
//           decoration: BoxDecoration(
//             color: message.isMine
//                 ? Theme.of(context).primaryColor
//                 : Colors.grey[300],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(message.content),
//         ),
//       ),
//       const SizedBox(width: 12),
//       Text(format(message.createdAt, locale: 'en_short')),
//       const SizedBox(width: 60),
//     ];
//     if (message.isMine) {
//       chatContents = chatContents.reversed.toList();
//     }
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
//       child: Row(
//         mainAxisAlignment:
//         message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: chatContents,
//       ),
//     );
//   }
// }
