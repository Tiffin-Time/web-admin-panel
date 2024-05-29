import 'package:adminpanelweb/screens/calendar%20view/calenadarview_screen.dart';
import 'package:adminpanelweb/screens/general_screen.dart';
import 'package:adminpanelweb/screens/login_screen.dart';
import 'package:adminpanelweb/screens/menu_upload_screen.dart';
import 'package:adminpanelweb/screens/order%20history/order_history_screen.dart';
import 'package:adminpanelweb/screens/overview/overview_screen.dart';
import 'package:adminpanelweb/screens/sales/sales_screen.dart';
import 'package:adminpanelweb/screens/view_menu_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:adminpanelweb/firebase_options.dart';
import 'package:adminpanelweb/screens/view_registered_restaurants_screen.dart';

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
  String? userDocId; // Store the document ID
  DocumentSnapshot? doc;
  String? searchKey = '';
  String? assetPath = '';

  List<String> get tabNames {
    if (!isLoggedIn) {
      return ['Login'];
    }
    List<String> tabs = [
      'General',
      'Menu Upload',
      'Sales',
      'Calendar View',
      'Order History',
    ];
    if (isAdministrator) {
      tabs.insert(0, 'Overview');
      tabs.remove('General');
      tabs.remove('Menu Upload');
      tabs.add('Registered Restaurants');
    }

    if (isLoggedIn && !isAdministrator) {
      // void add(E value); TODO: COULD ADD INSTEAD
      tabs.insert(5, 'View Menu');
    }

    return tabs;
  }

  List<Widget> get contentWidgets {
    if (!isLoggedIn) {
      return [LoginPage(onLoginSuccess: _handleLoginSuccess)];
    }

    List<Widget> widgets = [
      if (isAdministrator) OverviewScreen(userDocId: userDocId),
      if (!isAdministrator) GeneralScreen(userDocId: userDocId),
      if (!isAdministrator) MenuUploadScreen(userDocId: userDocId),
      SalesScreen(userDocId: userDocId),
      ViewSchedulePage(userDocId: userDocId),
      OrderHistoryScreen(userDocId: userDocId),
      if (isAdministrator)
        ViewRegisteredRestaurantsScreen(userDocId: userDocId),
    ];

    if (isLoggedIn && !isAdministrator) {
      widgets.add(ViewMenuScreen(userDocId: userDocId));
    }

    return widgets;
  }

  Future<void> _handleLoginSuccess(bool isAdmin, String documentId) async {
    setState(() {
      isLoggedIn = true;
      isAdministrator = isAdmin;
      userDocId = documentId; // Save the document ID
      selectedIndex = isAdministrator ? 0 : 1;
    });

    try {
      DocumentReference restaurantDoc =
          FirebaseFirestore.instance.collection('Restaurants').doc(userDocId);
      DocumentSnapshot docSnapshot = await restaurantDoc.get();
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      setState(() {
        // Ensure that searchKey exists in the document
        searchKey = data['searchKey'] ?? 'Unknown Search Key';
        // Sanitize the restaurant name to create a valid file path
        String companyName = data['companyName'] ?? 'Unknown Restaurant';

        String sanitizedRestaurantName =
            companyName.replaceAll(RegExp(r'\W+'), '_');
        assetPath =
            'company/images/general_information_images/$searchKey/$sanitizedRestaurantName.jpg';
      });
    } catch (e) {
      print("Failed to fetch user data: $e");
    }
  }

  void _logout() {
    setState(() {
      isLoggedIn = false;
      isAdministrator = false;
      selectedIndex = 0;
      userDocId = null; // Clear the document ID
    });
  }

  Future<String> getImageUrl(String imagePath) async {
    if (imagePath.isEmpty) {
      print("Provided image path is empty.");
      return 'assets/images/default.png'; // Provide a fallback image
    }

    final ref = FirebaseStorage.instance.ref().child(imagePath);

    try {
      final url = await ref.getDownloadURL();
      print("Obtained URL: $url"); // Log the obtained URL
      return url;
    } catch (e) {
      print("Error fetching image URL: $e");
      return 'assets/images/default.png'; // Provide a fallback image if there's an error
    }
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
                  // const CircleAvatar(
                  //   backgroundImage:
                  //       NetworkImage(getImageUrl(assetPath)),
                  //   radius: 60,
                  // ),
                  FutureBuilder(
                    future: getImageUrl(assetPath!),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            snapshot.data!,
                          ),
                          onBackgroundImageError: (exception, stackTrace) {
                            // handle errors or set a fallback image
                          },
                          // Optional: Display a progress indicator while the image is loading
                          child: snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? CircularProgressIndicator()
                              : null,
                        );
                      } else if (snapshot.connectionState ==
                              ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      return Container(); // or any other fallback widget
                    },
                  ),
                  // FutureBuilder(
                  //   future: getImageUrl(assetPath!),
                  //   builder:
                  //       (BuildContext context, AsyncSnapshot<String> snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.done &&
                  //         snapshot.hasData) {
                  //       return CircleAvatar(
                  //         radius: 60,
                  //         child: Image.network(
                  //           snapshot.data!,
                  //           // width: double.infinity,
                  //           // height: 200,
                  //           fit: BoxFit.cover,
                  //           loadingBuilder: (BuildContext context, Widget child,
                  //               ImageChunkEvent? loadingProgress) {
                  //             if (loadingProgress == null) return child;
                  //             return Center(
                  //               child: CircularProgressIndicator(
                  //                   value: loadingProgress.expectedTotalBytes !=
                  //                           null
                  //                       ? loadingProgress
                  //                               .cumulativeBytesLoaded /
                  //                           loadingProgress.expectedTotalBytes!
                  //                       : null),
                  //             );
                  //           },
                  //           errorBuilder: (BuildContext context,
                  //               Object exception, StackTrace? stackTrace) {
                  //             return const Icon(Icons.error);
                  //           },
                  //         ),
                  //       );
                  //     }
                  //     if (snapshot.connectionState == ConnectionState.waiting ||
                  //         !snapshot.hasData) {
                  //       return const CircularProgressIndicator();
                  //     }
                  //     return Container();
                  //   },
                  // ),
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
                  if (isLoggedIn)
                    ListTile(
                      title: Text('Logout ($searchKey)',
                          style: const TextStyle(color: Colors.red)),
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
