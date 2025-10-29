import 'package:flutter/material.dart';
import 'package:myapp/models/contact.dart';

class DetailScreen extends StatelessWidget {
  final Contact contact;
  const DetailScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.phone), const SizedBox(width: 8), Text(contact.phone)]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.email),
              const SizedBox(width: 8),
              Text(contact.email?.isNotEmpty == true ? contact.email! : 'No email'),
            ]),
          ],
        ),
      ),
    );
  }
}
