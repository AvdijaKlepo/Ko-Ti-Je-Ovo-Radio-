import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/user_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/user_form_dialog.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserProvider provider;
  late PaginatedFetcher<User> usersPagination;
  late ScrollController _scrollController;
  SearchResult<User>? result;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool showDeleted = false;
  bool _isInitialized = false;
  bool isLoading = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    usersPagination = PaginatedFetcher<User>(
    pageSize: 0,
    initialFilter: {},
    fetcher: ({
      required int page,
      required int pageSize,
      Map<String, dynamic>? filter,
    }) async {
      return PaginatedResult(result: [], count: 0);
    },
  );
    
   
      _scrollController = ScrollController();
  _scrollController.addListener(() {
    if (!_isInitialized) return; 

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        usersPagination.hasNextPage &&
        !usersPagination.isLoading) {
      usersPagination.loadMore();
    }
  });
  provider = context.read<UserProvider>();
  usersPagination = PaginatedFetcher<User>(
        pageSize: 20,
        initialFilter: {
        },
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
          
        }) async {
          final result = await provider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));

      

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      await usersPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
      'IsFreelancerIncluded': true,
      });

      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
     
    
    });
  }
  Future<void> _refreshWithFilter() async {
    setState(() => isLoading = true);

    final filter = <String, dynamic>{
      'isDeleted': showDeleted,
      'IsFreelancerIncluded': true,
    };

    if (_firstNameController.text.trim().isNotEmpty) {
      filter['FirstNameGTE'] = _firstNameController.text.trim();
    }
    if (_lastNameController.text.trim().isNotEmpty) {
      filter['LastNameGTE'] = _lastNameController.text.trim();
    }
    if (filter.isNotEmpty) {
      filter['isNameIncluded'] = true;
    }

    await usersPagination.refresh(newFilter: filter);
    setState(() => isLoading = false);
  }

  Future<void> _loadUsers({String? firstName, String? lastName}) async {
    Map<String, dynamic> filter = {
      'isDeleted': showDeleted,
      'IsFreelancerIncluded': false,
    };

    if ((firstName ?? '').trim().isNotEmpty) {
      filter['FirstNameGTE'] = firstName!.trim();
    }
    if ((lastName ?? '').trim().isNotEmpty) {
      filter['LastNameGTE'] = lastName!.trim();
    }
    if (filter.isNotEmpty) {
      filter['isNameIncluded'] = true;
    }

    try {
  final fetchedUsers =
      await provider.get(filter: filter.isEmpty ? null : filter);
  
  setState(() {
    result = fetchedUsers;
  });
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Greška: ${e.toString()}")),
  );
}
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _refreshWithFilter();
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
    if (result == true) {
      await _loadUsers(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    var filterOutLoggedInUser = usersPagination.items.where((element) => element.userId != AuthProvider.user?.userId).toList();
   if(!_isInitialized) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ime',
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
                    labelText: 'Prezime',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Text("Prikaži izbrisane"),
                  Switch(
                    value: showDeleted,
                    onChanged: (val) {
                      setState(() => showDeleted = val);
                      _onSearchChanged();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                const Expanded(
                    flex: 2,
                    child: Text("Ime",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    flex: 2,
                    child: Text("Prezime",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    flex: 3,
                    child: Text("Email",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    flex: 3,
                    child: Text("Lokacija",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    flex: 3,
                    child: Text("Adresa",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    flex: 3,
                    child: Text("Broj Telefona",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    flex: 3,
                    child: Text("Račun kreiran",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      "Slika",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                showDeleted
                    ? const SizedBox.shrink()
                    : const Expanded(
                        flex: 2,
                        child: Center(
                            child: Icon(Icons.edit,
                                size: 18, color: Colors.black54))),
                showDeleted
                    ? const Expanded(
                        flex: 2,
                        child: Center(
                            child: Icon(Icons.restore_outlined,
                                size: 18, color: Colors.black54)))
                    : const Expanded(
                        flex: 2,
                        child: Center(
                            child: Icon(Icons.delete,
                                size: 18, color: Colors.black54))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
  child: usersPagination.isLoading && usersPagination.items.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : usersPagination.items.isEmpty
          ? const Center(child: Text('Korisnici nisu pronađeni.'))
          : ListView.separated(
              controller: _scrollController,
              itemCount: filterOutLoggedInUser.length + 
                  (usersPagination.hasNextPage ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
              
                if (index >= filterOutLoggedInUser.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = filterOutLoggedInUser[index];
                

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(user.firstName ?? '')),
                      Expanded(flex: 2, child: Text(user.lastName ?? '')),
                      Expanded(flex: 3, child: Text(user.email ?? '')),
                      Expanded(
                          flex: 3,
                          child: Text(user.location?.locationName ?? '')),
                      Expanded(flex: 3, child: Text(user.address ?? '')),
                      Expanded(flex: 3, child: Text(user.phoneNumber ?? '')),
                      Expanded(
                        flex: 3,
                        child: Text(DateFormat('dd-MM-yyyy')
                            .format(user.createdAt!)),
                      ),
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
                                      image: AssetImage(
                                          'assets/images/Sample_User_Icon.png'),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      showDeleted
                          ? const SizedBox.shrink()
                          : Expanded(
                              flex: 2,
                              child: Center(
                                child: IconButton(
                                  color: user.userId!= AuthProvider.user?.userId
                                ? Colors.black
                                : Colors.grey,
                                  tooltip: 'Uredi',
                                  onPressed: () async {
                                  if(user.userId!=AuthProvider.user?.userId)
                                  {
                                    await _openUserDialog(user: user);
                                    await usersPagination.refresh(newFilter: {
                                      'isDeleted': showDeleted,
      'IsFreelancerIncluded': true,
                                    });
                                  }
                                
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                              ),
                            ),
                      showDeleted
                          ? Expanded(
                              flex: 2,
                              child: Center(
                                child: IconButton(
                                  tooltip: 'Vrati',
                                  onPressed: () {
                                    _openUserRestoreDialog(user: user);
                                  },
                                  icon: const Icon(Icons.restore_outlined),
                                ),
                              ),
                            )
                          : Expanded(
                              flex: 2,
                              child: Center(
                                child: IconButton(
                                  color: user.userId!= AuthProvider.user?.userId
                                ? Colors.black
                                : Colors.grey,
                                  tooltip: 'Izbriši',
                                  onPressed: () {
                                      if(user.userId!=AuthProvider.user?.userId)
                                  {
                                    _openUserDeleteDialog(user: user);
                                  }
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
)

        ],
      ),
    );
  }

  void _openUserDeleteDialog({required User user}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izbriši?'),
        content:
            const Text('Jeste li sigurni da želite izbrisati ovog korisnika?'),
        actions: [
         
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
           TextButton(
            onPressed: () async {
              await provider.delete(user.userId);
              await usersPagination.refresh(newFilter: {
                'isDeleted': showDeleted,
      'IsFreelancerIncluded': true,
            });
              if (!mounted) return;
              Navigator.of(context).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Korisnik je uspiješno izbrisan.")),
              );
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }

  void _openUserRestoreDialog({required User user}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vrati?'),
        content:
            const Text('Jeste li sigurni da želite vratiti ovog korisnika?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              await provider.delete(user.userId);
              await usersPagination.refresh(newFilter: {
                'isDeleted': showDeleted,
      'IsFreelancerIncluded': true,
            });
              if (!mounted) return;
              Navigator.of(context).pop(true);
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Korisnik je uspiješno reaktiviran.")),
              );
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }
}
