import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziggy_app/Common/Re-usable%20widgets/loader.dart';
import 'package:ziggy_app/Common/Re-usable%20widgets/scaffoldmessage.dart';
import 'package:ziggy_app/Utilities/colors.dart';
import 'package:ziggy_app/Models/models.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<UserModel>> _futureUsers;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _futureUsers = getUsers();
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final response =
          await http.get(Uri.parse('https://reqres.in/api/users?page=2'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<UserModel> users = [];
        for (var user in data['data']) {
          users.add(UserModel.fromJson(user));
        }
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<void> _showCreateUserDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _avatarController,
                decoration:
                    const InputDecoration(labelText: 'Avatar Image Link'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                String firstName = _firstNameController.text;
                String lastName = _lastNameController.text;
                String email = _emailController.text;
                String avatar = _avatarController.text;
                _createUser(firstName, lastName, email, avatar);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createUser(
      String firstName, String lastName, String email, String avatar) async {
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      showSnackBar(context, 'Please fill all fields');
      return;
    }

    try {
      UserModel newUser = await createUser(firstName, lastName, email, avatar);
      setState(() {
        _futureUsers = _futureUsers.then((users) {
          return [newUser, ...users];
        });
      });
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      showSnackBar(context, 'User created successfully');
    } catch (e) {
      showSnackBar(context, 'Failed to create user');
    }
  }

  Future<UserModel> createUser(
      String firstName, String lastName, String email, String avatar) async {
    try {
      final response = await http.post(
        Uri.parse('https://reqres.in/api/users'),
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'avatar': avatar
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Users',
            style: GoogleFonts.braahOne(
                color: textColor, letterSpacing: 2, fontSize: 35)),
        centerTitle: true,
        toolbarHeight: 50,
        backgroundColor: appBarColor,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loader();
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Unable to load users.',
                    style: GoogleFonts.almarai(fontSize: 30)));
          } else {
            final users = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('List Of Users',
                      style: GoogleFonts.anekLatin(
                          letterSpacing: 1.5,
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationThickness: 3)),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            color: textColor.withOpacity(0.7),
                          ),
                          child: ListTile(
                            leading: user.avatar.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(user.avatar),
                                    radius: 25,
                                  )
                                : const CircleAvatar(
                                    radius: 25,
                                    child: Icon(Icons.person, size: 30),
                                  ),
                            title: Text(
                              '${user.firstName} ${user.lastName}',
                              style: GoogleFonts.alata(fontSize: 25),
                            ),
                            subtitle: Text(
                              user.email,
                              style: GoogleFonts.alata(fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        splashColor: appBarColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
