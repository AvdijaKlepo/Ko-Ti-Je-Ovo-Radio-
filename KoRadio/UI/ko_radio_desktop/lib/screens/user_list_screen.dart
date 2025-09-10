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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool showDeleted = false;
  bool _isInitialized = false;
  bool isLoading = false;
  Timer? _debounce;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    provider = context.read<UserProvider>();
    usersPagination = PaginatedFetcher<User>(
      pageSize: 18,
      initialFilter: {},
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
    );
    usersPagination.addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    // Initialize listeners to controllers
    _firstNameController.addListener(_onSearchChanged);
    _emailController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      await usersPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'IsFreelancerIncluded': true,
      });
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
    });
  }

  Future<void> _refreshWithFilter() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    final filter = <String, dynamic>{
      'isDeleted': showDeleted,
      'IsFreelancerIncluded': true,
    };
    if (_firstNameController.text.trim().isNotEmpty) {
      filter['FirstNameGTE'] = _firstNameController.text.trim();
    }
    if (_emailController.text.trim().isNotEmpty) {
      filter['Email'] = _emailController.text.trim();
    }
    await usersPagination.refresh(newFilter: filter);
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _refreshWithFilter();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _firstNameController.removeListener(_onSearchChanged);
    _firstNameController.dispose();
    _emailController.removeListener(_onSearchChanged);
    _emailController.dispose();
    usersPagination.dispose();
    super.dispose();
  }

  Future<void> _openUserDialog({User? user}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
    if (result == true) {
      if (!mounted) return;
      setState(() => isLoading = true);
      await usersPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'IsFreelancerIncluded': true,
      });
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var filterOutLoggedInUser = usersPagination.items
        .where((element) => element.userId != AuthProvider.user?.userId)
        .toList();

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔎 Search & filters
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Ime i prezime',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _firstNameController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _firstNameController.clear();
                              _refreshWithFilter();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
            
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email adresa',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: _emailController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _emailController.clear();
                            _onSearchChanged();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
                onChanged: (_) => _onSearchChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Switch(
                  value: showDeleted,
                  onChanged: (val) {
                    setState(() => showDeleted = val);
                    _onSearchChanged();
                  },
                ),
                const Text("Prikaži izbrisane"),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

      
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text("Ime", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Prezime", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Lokacija", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Adresa", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Broj Telefona", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text("Račun kreiran", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3,child: Center(child: Text("Slika", style: TextStyle(fontWeight: FontWeight.bold)))),
              
              Expanded(flex: 1, child: Center(child: Text("Akcije", style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
        ),

        const SizedBox(height: 6),

 
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: filterOutLoggedInUser.isEmpty && !isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/usersNotFound.webp', width: 250, height: 250),
                      const SizedBox(height: 16),
                      const Text(
                        'Korisnici nisu pronađeni.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: filterOutLoggedInUser.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final user = filterOutLoggedInUser[index];
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          color: index.isEven ? Colors.grey.shade50 : Colors.white,
                          child: _buildUsers(user),
                        ),
                      );
                    },
                  ),
          ),
        ),

        const SizedBox(height: 12),


        if (_firstNameController.text.isEmpty &&
            _emailController.text.isEmpty &&
            usersPagination.hasNextPage == false)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            children: List.generate(
              (usersPagination.count / usersPagination.pageSize).ceil(),
              (index) {
                final pageNum = index + 1;
                final isActive = currentPage == pageNum;
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isActive ? const Color.fromRGBO(27, 76, 125, 1) : Colors.white,
                    foregroundColor: isActive ? Colors.white : Colors.black87,
                    side: BorderSide(color: isActive ? Colors.transparent : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () async {
                    if (!mounted) return;
                    setState(() {
                      currentPage = pageNum;
                      isLoading = true;
                    });
                    await usersPagination.goToPage(
                      pageNum,
                      filter: {
                        'isDeleted': showDeleted,
                        'IsFreelancerIncluded': true,
                      },
                    );
                    if (!mounted) return;
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Text("$pageNum"),
                );
              },
            ),
          ),

        const SizedBox(height: 8),

        // 📊 Counter
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Prikazano ${(currentPage - 1) * usersPagination.pageSize + 1}"
              " - ${(currentPage - 1) * usersPagination.pageSize + usersPagination.items.length}"
              " od ${usersPagination.count}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildUsers(User user) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(user.firstName ?? '')),
          Expanded(flex: 2, child: Text(user.lastName ?? '')),
          Expanded(flex: 3, child: Text(user.email ?? '')),
          Expanded(flex: 3, child: Text(user.location?.locationName ?? '')),
          Expanded(flex: 3, child: Text(user.address ?? '')),
          Expanded(flex: 3, child: Text(formatPhoneNumber( user.phoneNumber?? ''))),
          Expanded(
            flex: 1,
            child: Text(DateFormat('dd-MM-yyyy').format(user.createdAt!)),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: ClipOval(
                child: user.image != null
                    ? imageFromString(user.image!, width: 40, height: 40)
                    : const Image(
                        image: AssetImage(
                          'assets/images/Sample_User_Icon.png',
                        ),
                        fit: BoxFit.contain,
                        width: 40,
                        height: 40,
                      ),
              ),
            ),
            
          ),
          !showDeleted?
         Expanded(
  flex: 1,
  child: Center(
    child: PopupMenuButton<String>(
      tooltip: 'Uredi/Izbriši',
      icon: const Icon(Icons.more_vert),
      color: Colors.white,
   
      
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Uredi'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Izbriši'),
        ),
      ],
      onSelected: (value) async {
        if (value == 'edit') {
          _openUserDialog(user: user);
        } else if (value == 'delete') {
          _openUserDeleteDialog(user: user);
        }
      
      },
    ),
  ),
) : Expanded(
  flex: 1,
  child: Center(
    child: IconButton(
      color: user.userId != AuthProvider.user?.userId
          ? Colors.black
          : Colors.grey,
      tooltip: 'Reaktiviraj',
      onPressed: () {
        if (user.userId != AuthProvider.user?.userId) {
          _openUserRestoreDialog(user: user);
        }
      },
      icon: const Icon(Icons.restore_outlined),
    ),
  ),
),

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
                const SnackBar(
                    content: Text("Korisnik je uspiješno izbrisan.")),
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
                const SnackBar(
                    content: Text("Korisnik je uspiješno reaktiviran.")),
              );
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }
}
