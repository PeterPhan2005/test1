import 'package:flutter/material.dart';
import 'package:myapp/models/contact.dart';
class FormScreen extends StatefulWidget {
  final Contact? contact;
  const FormScreen({super.key, this.contact});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.contact?.name ?? '');
    phoneCtrl = TextEditingController(text: widget.contact?.phone ?? '');
    emailCtrl = TextEditingController(text: widget.contact?.email ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  void save() {
    if (_formKey.currentState!.validate()) {
      final contact = Contact(
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        email: emailCtrl.text.isNotEmpty ? emailCtrl.text : null,
      );
      Navigator.pop(context, contact);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contact != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Contact' : 'Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Phone required';
                  if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: save,
                child: Text(isEdit ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
