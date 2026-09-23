import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onBack;

  const MessagePage({
    super.key,
    required this.title,
    required this.message,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: onBack == null
            ? null
            : IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
      ),
      body: Padding(padding: const EdgeInsets.all(24), child: Text(message)),
    );
  }
}
