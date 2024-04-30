import 'package:adminpanelweb/screens/calendar%20view/calenadarview_screen.dart';
import 'package:adminpanelweb/screens/general_screen.dart';
import 'package:adminpanelweb/screens/login_screen.dart';
import 'package:adminpanelweb/screens/menu_upload_screen.dart';
import 'package:adminpanelweb/screens/order%20history/order_history_screen.dart';
import 'package:adminpanelweb/screens/overview/overview_screen.dart';
import 'package:adminpanelweb/screens/sales/sales_screen.dart';
import 'package:adminpanelweb/widgets/customText.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:adminpanelweb/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSidebarOpen = false;
  bool isLoggedIn = false;
  bool isAdministrator = false;
  int selectedIndex = 0; // Start with the login screen

  List<String> get tabNames {
    if (!isLoggedIn) {
      return ['Login']; // Only show Login when not logged in
    }
    List<String> tabs = [
      'General',
      'Menu Upload',
      'Sales',
      'Calendar View',
      'Order History'
    ];
    if (isAdministrator) {
      tabs.insert(0, 'Overview'); // Admins see 'Overview' at the top
    }
    return tabs;
  }

  List<Widget> get contentWidgets {
    if (!isLoggedIn) {
      return [LoginPage(onLoginSuccess: _handleLoginSuccess)];
    }
    List<Widget> widgets = [
      if (isAdministrator) OverviewScreen(),
      GeneralScreen(),
      MenuUploadScreen(),
      SalesScreen(),
      ViewSchedulePage(),
      OrderHistoryScreen(),
    ];
    return widgets;
  }

  void _handleLoginSuccess(bool isAdmin) {
    setState(() {
      isLoggedIn = true;
      isAdministrator = isAdmin;
      selectedIndex =
          isAdministrator ? 0 : 1; // Adjust based on whether the user is admin
    });
  }

  void _logout() {
    setState(() {
      isLoggedIn = false;
      isAdministrator = false;
      selectedIndex = 0; // Reset to the initial index, showing the login page
    });
    // Perform any additional cleanup like clearing authentication tokens here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: selectedIndex,
            children: contentWidgets,
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -250,
            child: Container(
              width: 250,
              color: Colors.black,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const CircleAvatar(
                    backgroundImage:
                        NetworkImage('https://i.ibb.co/tMWR7gV/logo.jpg'),
                    radius: 60,
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tabNames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            tabNames[index],
                            style: TextStyle(
                                color: selectedIndex == index
                                    ? Colors.orange
                                    : Colors.white),
                          ),
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                              isSidebarOpen = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  if (isLoggedIn) // Only show logout button if logged in
                    ListTile(
                      title:
                          Text('Logout', style: TextStyle(color: Colors.red)),
                      onTap: _logout,
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(isSidebarOpen ? Icons.close : Icons.menu),
              onPressed: () {
                setState(() {
                  isSidebarOpen = !isSidebarOpen;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
