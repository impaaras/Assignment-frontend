import 'package:flutter/material.dart';
import 'loginpage.dart'; // Import your LoginPage widget
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String username = prefs.getString('username') ?? '';

  runApp(MaterialApp(
    title: 'Chat Page',
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
      scrollbarTheme: const ScrollbarThemeData(),
    ),
    home: isLoggedIn ? ChatScreen(username: username) : const LoginPage(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Page',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scrollbarTheme: const ScrollbarThemeData(),
      ),
      home: const LoginPage(),
    );
  }
}

class AuthManager {
  static Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> logout(BuildContext context) async {
    await saveLoginState(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String username;

  const ChatScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> userList = []; // List to store user emails
  String selectedUserEmail = ''; // State variable for selected user email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedUserEmail.isNotEmpty
            ? 'Profile - ${widget.username}'
            : 'Profile - ${widget.username}'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.indigo],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth >= 600
                ? _buildWideLayout()
                : _buildNarrowLayout();
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Panel (User List)
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      String? userEmail = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController emailController =
                              TextEditingController();
                          return AlertDialog(
                            title: const Text('Start New Chat'),
                            content: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Enter User Email',
                                hintText: 'example@example.com',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(emailController.text.trim());
                                },
                                child: const Text('Start Chat'),
                              ),
                            ],
                          );
                        },
                      );

                      if (userEmail != null && userEmail.isNotEmpty) {
                        bool userExists = await fetchUserDetails(userEmail);
                        if (userExists) {
                          setState(() {
                            userList.add(userEmail);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not found!'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Chat'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundImage:
                              NetworkImage('https://via.placeholder.com/150'),
                        ),
                        title: Text(
                          userList[index],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedUserEmail = userList[index];
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    AuthManager.logout(context);
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
        // Vertical Divider
        VerticalDivider(
          color: Colors.white,
          thickness: 1,
          width: 1,
        ),
        // Right Panel (Chat Area)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedUserEmail.isNotEmpty
                            ? selectedUserEmail
                            : 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle menu button press
                      },
                      icon: const Icon(Icons.more_vert),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // children: [
                    //   MessageBubble(
                    //     message: 'Hello!',
                    //     isSentByMe: false,
                    //   ),
                    //   MessageBubble(
                    //     message: 'Hi there!',
                    //     isSentByMe: true,
                    //   ),
                    // ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        // Handle sending the message
                      },
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      String? userEmail = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController emailController =
                              TextEditingController();
                          return AlertDialog(
                            title: const Text('Start New Chat'),
                            content: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Enter User Email',
                                hintText: 'example@example.com',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(emailController.text.trim());
                                },
                                child: const Text('Start Chat'),
                              ),
                            ],
                          );
                        },
                      );

                      if (userEmail != null && userEmail.isNotEmpty) {
                        bool userExists = await fetchUserDetails(userEmail);
                        if (userExists) {
                          setState(() {
                            userList.add(userEmail);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not found!'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Chat'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundImage:
                            NetworkImage('https://via.placeholder.com/150'),
                      ),
                      title: Text(
                        userList[index],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedUserEmail = userList[index];
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    AuthManager.logout(context);
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
        // Right Panel (Chat Area)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedUserEmail.isNotEmpty
                            ? selectedUserEmail
                            : 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle menu button press
                      },
                      icon: const Icon(Icons.more_vert),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // children: [
                    //   MessageBubble(
                    //     message: 'Hello!',
                    //     isSentByMe: false,
                    //   ),
                    //   MessageBubble(
                    //     message: 'Hi there!',
                    //     isSentByMe: true,
                    //   ),
                    // ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        // Handle sending the message
                      },
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> fetchUserDetails(String email) async {
    // You need to implement this method to fetch user details from your backend
    // For example, if using HTTP, you might make a GET request to your API endpoint
    // final response = await http.get(Uri.parse('your_api_endpoint_here'));
    // if (response.statusCode == 200) {
    //   // Parse response JSON and check if user exists
    //   // return true if user exists, false otherwise
    // } else {
    //   throw Exception('Failed to load user details');
    // }

    // For demonstration, returning true directly (replace this with actual logic)
    return true;
  }
}
