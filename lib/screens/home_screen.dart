import 'package:flutter/material.dart';
import 'package:myapp/screens/DetailScreen.dart';
import 'package:myapp/screens/form.dart';
import 'package:myapp/models/contact.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> contacts = [];
  List<Contact> filtered = [];
  bool multiSelect = false;
  Set<int> selected = {};
  String query = '';

  @override
  void initState() {
    super.initState();
    filtered = contacts;
  }

  void filter(String q) {
    setState(() {
      query = q;
      filtered = contacts
          .where((c) =>
              c.name.toLowerCase().contains(q.toLowerCase()) ||
              c.phone.toLowerCase().contains(q.toLowerCase()) ||
              (c.email ?? '').toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  void deleteSelected() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${selected.length} selected contacts?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                contacts.removeWhere((_,) => selected.contains(contacts.indexOf(_)));
                filtered = contacts;
                selected.clear();
                multiSelect = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contacts deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: multiSelect
            ? Text('${selected.length} selected')
            : const Text('Contacts'),
        actions: [
          if (multiSelect)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteSelected,
            ),
          if (!multiSelect)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final q = await showSearch(
                  context: context,
                  delegate: ContactSearchDelegate(
                    contacts: contacts,
                    onSelected: (c) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(contact: c),
                        ),
                      );
                    },
                  ),
                );
                if (q != null) filter(q);
              },
            ),
        ],
      ),
      body: filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.contact_page, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No contacts found.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final newContact = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FormScreen()),
                      );
                      if (newContact != null) {
                        setState(() {
                          contacts.add(newContact);
                          filtered = contacts;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contact added')),
                        );
                      }
                    },
                    child: const Text('Add Contact'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = filtered[index];
                final selectedState = selected.contains(index);

                return ListTile(
                  leading: multiSelect
                      ? Checkbox(
                          value: selectedState,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selected.add(index);
                              } else {
                                selected.remove(index);
                              }
                            });
                          },
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(c.name),
                  subtitle: Text(c.phone),
                  onTap: () {
                    if (multiSelect) {
                      setState(() {
                        if (selected.contains(index)) {
                          selected.remove(index);
                        } else {
                          selected.add(index);
                        }
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailScreen(contact: c)),
                      );
                    }
                  },
                  onLongPress: () async {
                    final choice = await showMenu<String>(
                      context: context,
                      position: const RelativeRect.fromLTRB(200, 200, 0, 0),
                      items: const [
                        PopupMenuItem(value: 'open', child: Text('Open')),
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    );
                    if (choice == 'open') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailScreen(contact: c)),
                      );
                    } else if (choice == 'edit') {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormScreen(contact: c),
                        ),
                      );
                      if (updated != null) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contact updated')),
                        );
                      }
                    } else if (choice == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Contact?'),
                          content: Text('Delete ${c.name}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        setState(() {
                          contacts.remove(c);
                          filtered = contacts;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contact deleted')),
                        );
                      }
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newContact = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          );
          if (newContact != null) {
            setState(() {
              contacts.add(newContact);
              filtered = contacts;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact added')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ContactSearchDelegate extends SearchDelegate<String> {
  final List<Contact> contacts;
  final Function(Contact) onSelected;

  ContactSearchDelegate({
    required this.contacts,
    required this.onSelected,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = contacts.where((c) {
      final q = query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          (c.email ?? '').toLowerCase().contains(q);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final c = results[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(c.name),
          subtitle: Text(c.phone),
          onTap: () {
            onSelected(c);
            close(context, query);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = contacts.where((c) {
      final q = query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          (c.email ?? '').toLowerCase().contains(q);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final c = suggestions[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(c.name),
          subtitle: Text(c.phone),
          onTap: () {
            onSelected(c);
            close(context, query);
          },
        );
      },
    );
  }
}

