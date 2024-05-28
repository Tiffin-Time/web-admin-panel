import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/widgets/custom_text.dart';

class ViewRegisteredRestaurantsScreen extends StatefulWidget {
  final String? userDocId;

  const ViewRegisteredRestaurantsScreen({Key? key, this.userDocId})
      : super(key: key);

  @override
  _ViewRegisteredRestaurantsScreenState createState() =>
      _ViewRegisteredRestaurantsScreenState();
}

class _ViewRegisteredRestaurantsScreenState
    extends State<ViewRegisteredRestaurantsScreen> {
  Stream<List<DocumentSnapshot>>? restaurants;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    restaurants = fetchRestaurants();
  }

  Stream<List<DocumentSnapshot>> fetchRestaurants() {
    return FirebaseFirestore.instance
        .collection('Restaurants')
        .snapshots()
        .map((snapshot) => snapshot.docs
          ..map((doc) => {
                'id': doc.id, // Capture the document ID from Firestore
                ...doc.data() as Map<String,
                    dynamic>, // Include other document data fields
              }).toList());
  }

  Future<String> getImageUrl(String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    try {
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error fetching image URL: $e");
      return 'assets/images/default.jpg';
    }
  }

  Widget buildRestaurantCard(Map<String, dynamic> restaurant) {
    String companyName = restaurant['companyName'] ?? 'Unknown Restaurant';

    String sanitizedRestaurantName =
        companyName.replaceAll(RegExp(r'\W+'), '_');
    String searchKey = restaurant['searchKey'] ?? 'Unknown_searchKey';

    String imagePath =
        'company/images/general_information_images/$searchKey/$sanitizedRestaurantName.jpg';

    return FutureBuilder<String>(
      future: getImageUrl(imagePath),
      builder: (context, imageSnapshot) {
        return Card(
          margin: const EdgeInsets.all(4),
          child: Stack(
            children: [
              InkWell(
                onTap: () async {
                  String? docId = await getDocIdBySearchKey(searchKey);
                  print("Navigating to details with Restaurant ID: $docId");
                  _navigateToDetailsScreen(context, docId);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: getImageUrl(imagePath),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                                height: 60,
                                child:
                                    Center(child: CircularProgressIndicator()));
                          } else if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty)
                            return Icon(Icons.error, size: 50);
                          else {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                snapshot.data!,
                                width: double.infinity,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error, size: 50);
                                },
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 4),
                      Text(
                        restaurant['companyName'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // SizedBox(height: 2),
                      // Text(
                      //   'Company Address: ${restaurant['companyAddress'] ?? 'N/A}',
                      //   maxLines: 2,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: TextStyle(fontSize: 12),
                      // ),
                      SizedBox(height: 2),
                      Text(
                        'Company Number: ${restaurant['companyNumber'] ?? 'N/A'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'NiNumber: ${restaurant['niNumber'] ?? 'N/A'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                      // SizedBox(height: 2),
                      // Text(
                      //   'Bank Details: ${restaurant['bankDetails'] ?? 'N/A}',
                      //   maxLines: 2,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: TextStyle(fontSize: 12),
                      // ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Show confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Deletion"),
                          content: const Text(
                              "Are you sure you want to delete this restaurant? This action cannot be undone."),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                // Dismiss the dialog but do not delete
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                // Proceed with deletion
                                deleteRestaurant(restaurant['id']);
                                // Dismiss the dialog after action
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> getDocIdBySearchKey(String searchKey) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Restaurants')
          .where('searchKey', isEqualTo: searchKey)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching document ID: $e");
      return null;
    }
  }

  void _navigateToDetailsScreen(BuildContext context, String? restaurantId) {
    if (restaurantId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailsScreen(
            restaurantId: restaurantId,
          ),
        ),
      );
    } else {
      // Handle the null case, possibly showing an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid restaurant ID!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> deleteRestaurant(String id) async {
    if (widget.userDocId != null) {
      DocumentReference restaurantDoc = FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(widget.userDocId);
      await restaurantDoc.update({
        id: FieldValue.delete(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query.toLowerCase();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      // appBar: AppBar(title: Text("Registered Restaurants")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  size: 23,
                  text: "Registered Restaurants",
                  align: TextAlign.start,
                  fontWeight: FontWeight.w600,
                  textColor: blackColor,
                ),
                const SizedBox(height: 40),
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: restaurants,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(child: Text("Error fetching data"));
                    }

                    List<DocumentSnapshot> docs = snapshot.data!;
                    List<Map<String, dynamic>> filteredRestaurants = docs
                        .map(
                          (doc) => {
                            'id': doc.id, // Get document ID from Firestore
                            ...doc.data() as Map<String,
                                dynamic> // Spread other document data
                          },
                        ) // Handle possible null data
                        .where((restaurant) =>
                            restaurant != null) // Filter out null restaurants
                        .map((restaurant) => {
                              'companyName': restaurant?['companyName'] ?? '',
                              'searchKey': restaurant?['searchKey'] ?? '',
                              'companyNumber':
                                  restaurant?['companyNumber'] ?? '',
                              'niNumber': restaurant?['niNumber'] ?? '',
                            }) // Normalize data to avoid null issues later
                        .where((restaurant) =>
                            restaurant['companyName']
                                .toLowerCase()
                                .contains(searchQuery) ||
                            restaurant['searchKey']
                                .toLowerCase()
                                .contains(searchQuery) ||
                            restaurant['companyNumber']
                                .toLowerCase()
                                .contains(searchQuery) ||
                            restaurant['niNumber']
                                .toLowerCase()
                                .contains(searchQuery))
                        .toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        var restaurant = filteredRestaurants[index];
                        return buildRestaurantCard(restaurant);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RestaurantDetailsScreen extends StatelessWidget {
  final String restaurantId;

  RestaurantDetailsScreen({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Details"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Restaurants')
            .doc(restaurantId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching details"));
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text("No details available"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          var generalInfo =
              data['generalInformation'] as Map<String, dynamic>? ?? {};
          var parsedAddress =
              generalInfo['address'] as Map<String, dynamic>? ?? {};

          // Safely access String fields
          String companyName = data['companyName'] as String? ?? 'No Name';
          // String companyAddress =
          //     data['companyAddress'] as String? ?? 'No Address';
          String aboutUs = generalInfo['aboutUs'] as String? ?? 'Not provided';

          String companyParsedAddress = parsedAddress.isNotEmpty
              ? "${parsedAddress['firstLine']}, ${parsedAddress['city']}, ${parsedAddress['country']}, ${parsedAddress['postcode']}"
              : 'No Address';

          // Handling List data safely
          List<dynamic> daysOpen =
              generalInfo['daysOpen'] as List<dynamic>? ?? [];

          String collectionRadius = generalInfo['collectionRadius'] ?? '';

          String daysOpenStr = daysOpen.join(
              ', '); // This converts the list to a comma-separated string safely.

          return ListView(
            children: [
              ListTile(
                title: Text("Name"),
                subtitle: Text(companyName),
              ),
              // ListTile(
              //   title: Text("Address"),
              //   subtitle: Text(companyAddress),
              // ),
              ListTile(
                title: Text("About Us"),
                subtitle: Text(aboutUs),
              ),
              ListTile(
                title: Text("Collection Radius"),
                subtitle: Text(collectionRadius),
              ),
              ListTile(
                title: Text("Days Open"),
                subtitle: Text(daysOpenStr),
              ),
              ListTile(
                title: Text("Address"),
                subtitle: Text(companyParsedAddress),
              ),
              //               ListTile(
              //   title: Text("Days Open"),
              //   subtitle: Text(daysOpenStr),
              // ),
              //               ListTile(
              //   title: Text("Days Open"),
              //   subtitle: Text(daysOpenStr),
              // ),
              //               ListTile(
              //   title: Text("Days Open"),
              //   subtitle: Text(daysOpenStr),
              // ),
              //               ListTile(
              //   title: Text("Days Open"),
              //   subtitle: Text(daysOpenStr),
              // ),
              //               ListTile(
              //   title: Text("Days Open"),
              //   subtitle: Text(daysOpenStr),
              // ),

              // Add more fields from generalInformation as required
            ],
          );
        },
      ),
    );
  }
}
