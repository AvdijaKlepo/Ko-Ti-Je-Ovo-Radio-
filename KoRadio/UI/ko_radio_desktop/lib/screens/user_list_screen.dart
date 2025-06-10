import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/providers/user_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/user_details_screen.dart';
import 'package:ko_radio_desktop/screens/user_form_dialog.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserProvider provider;
  SearchResult<User>? result;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = context.read<UserProvider>();
      _loadUsers();
    });
  }

  Future<void> _loadUsers({String? firstName, String? lastName}) async {
    Map<String, dynamic> filter = {'isDeleted': false,'IsFreelancerIncluded':false};
    

    if ((firstName ?? '').trim().isNotEmpty) {
      filter['FirstNameGTE'] = firstName!.trim();
    }
    if ((lastName ?? '').trim().isNotEmpty) {
      filter['LastNameGTE'] = lastName!.trim();
    }
    if (filter.isNotEmpty) {
      filter['isNameIncluded'] = true;
    }

    final fetchedUsers = await provider.get(filter: filter.isEmpty ? null : filter);

    setState(() {
      result = fetchedUsers;
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _loadUsers(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

    Future<void> _openUserDialog({User? user}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
    if(result==true){
      await _loadUsers(firstName: _firstNameController.text, lastName: _lastNameController.text);
    }
    
  }
   Future<void> _openUserPromoteDialog({User? user}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => UserPromoteDialog(user: user),
    );
    if(result==true){
      await _loadUsers(firstName: _firstNameController.text, lastName: _lastNameController.text);
    }
    
  }

  Widget _buildHeaderCell(String text, {double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),

      child: Padding(

        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
        child: Text(
          
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Search and Add
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Worker'),
                onPressed: () {
                 
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Headers row
         // Header Row
// Header Row
// Header Row
Container(
  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  child: const Row(
    children: [
      Expanded(flex: 2, child: Text("Ime", style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(flex: 2, child: Text("Prezime", style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(flex: 3, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(flex: 3, child: Text("Lokacija", style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(flex: 3, child: Text("Adresa", style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(flex: 3, child: Text("Broj Telefona", style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(flex: 3, child: Text("Račun kreiran", style: TextStyle(fontWeight: FontWeight.bold))),
Expanded(
  flex: 3,
  child: Center(
    child: Text(
      "Slika",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
),

      Expanded(flex: 2, child: Center(child: Icon(Icons.edit, size: 18, color: Colors.black54))),
      Expanded(flex: 2, child: Center(child: Icon(Icons.work_rounded, size: 18, color: Colors.black54))),
    ],
  ),
),

const SizedBox(height: 4),

// List of users
Expanded(
  child: result == null
      ? const Center(child: CircularProgressIndicator())
      : result!.result.isEmpty
          ? const Center(child: Text('No users found.'))
          : ListView.separated(
              itemCount: result!.result.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = result!.result[index];
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(user.firstName)),
                        Expanded(flex: 2, child: Text(user.lastName)),
                        Expanded(flex: 3, child: Text(user.email)),
                        Expanded(flex: 3, child: Text(user.location?.locationName ?? '')),
                        Expanded(flex: 3, child: Text(user.address)),
                        Expanded(flex: 3, child: Text(user.phoneNumber)),
                        Expanded(flex: 3, child: Text(user.createdAt.toString().split(' ')[0])),
                       Expanded(
  flex: 3,
  child: Align(
    alignment: Alignment.center,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 40,
        maxWidth: 40,
      ),
      child: ClipOval(
        child: user.image != null
            ? imageFromString(user.image!)
            : const Image(
                image: AssetImage('assets/images/Sample_User_Icon.png'),
                fit: BoxFit.cover,
              ),
      ),
    ),
  ),
),


                        Expanded(
                          flex: 2,
                          child: Center(
                            child: IconButton(
                              tooltip: 'Uredi',
                              onPressed: () {
                                _openUserDialog(user: user);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: IconButton(
                              tooltip: 'Promoviši',
                              onPressed: () {
                                _openUserPromoteDialog(user: user);
                              },
                              icon: const Icon(Icons.work_rounded),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
              
              },
            ),
),


        ],
      ),
    );
  }
}
