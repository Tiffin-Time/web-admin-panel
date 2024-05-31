// import 'dart:html';
import 'dart:html' hide VoidCallback;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/widgets/custom_text.dart';
import 'package:adminpanelweb/globals/globals.dart' as globals;

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
        .map((snapshot) => snapshot.docs);
  }

  // Stream<List<DocumentSnapshot>> fetchRestaurants() {
  //   return FirebaseFirestore.instance
  //       .collection('Restaurants')
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //         ..map((doc) => {
  //               'id': doc.id, // Capture the document ID from Firestore
  //               ...doc.data() as Map<String,
  //                   dynamic>, // Include other document data fields
  //             }).toList());
  // }

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
                  String? docId = await globals.getDocIdBySearchKey(searchKey);
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
                              onPressed: () async {
                                String? docId = await globals
                                    .getDocIdBySearchKey(searchKey);
                                Navigator.of(context).pop();

                                print("Deleting Restuarant with ID: $docId");
                                // Proceed with deletion
                                if (docId != null) {
                                  deleteRestaurant(docId, companyName);
                                }
                                // Dismiss the dialog after action
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

  Future<void> deleteRestaurant(String id, String companyName) async {
    try {
      // Delete the restaurant document from the Restaurants collection
      await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(id)
          .delete();

      // Delete the associated document from the companyCredentials collection
      await FirebaseFirestore.instance
          .collection('companyCredentials')
          .doc(companyName)
          .delete();

      setState(() {
        restaurants = fetchRestaurants();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Restaurant and associated credentials deleted successfully")),
      );
    } catch (e) {
      print("Error deleting restaurant: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Failed to delete restaurant and associated credentials")),
      );
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

  Future<Map<String, dynamic>?> getRestaurantData(String restaurantId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(restaurantId)
          .get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching restaurant data: $e");
      return null;
    }
  }

  void _navigateToMenuScreen(
      BuildContext context, Map<String, dynamic> dishes, String searchKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuScreen(
          restaurantId: restaurantId,
          dishes: dishes,
          searchKey: searchKey,
        ),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRestaurantDetailsScreen(
          restaurantId: restaurantId,
          restaurantData: data,
          onSave: () {
            Navigator.pop(
                context, true); // Notify parent screen to refresh data
          },
        ),
      ),
    ).then((value) {
      if (value == true) {
        // Call setState to refresh data when returning from edit screen
        (context as Element).markNeedsBuild();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              Map<String, dynamic>? restaurantData =
                  await getRestaurantData(restaurantId);
              if (restaurantData != null) {
                _navigateToEditScreen(context, restaurantData);
              }
            },
          ),
        ],
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
            return Center(child: Text("No details available"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          var generalInfo =
              data['generalInformation'] as Map<String, dynamic>? ?? {};
          var parsedAddress =
              generalInfo['address'] as Map<String, dynamic>? ?? {};

          // Safely access String fields
          String companyName = data['companyName'] as String? ?? 'No Name';
          String aboutUs = generalInfo['aboutUs'] as String? ?? 'Not provided';
          String collectionRadius = generalInfo['collectionRadius'] ?? '';
          var bankDeatails = data['bankDetails'] as Map<String, dynamic>? ?? {};

          String companyParsedAddress = parsedAddress.isNotEmpty
              ? "${parsedAddress['firstLine']}, ${parsedAddress['city']}, ${parsedAddress['country']}, ${parsedAddress['postcode']}"
              : 'No Address';
          String companyParsedBankDetails = bankDeatails.isNotEmpty
              ? "${bankDeatails['accountNumber']}, ${bankDeatails['bankName']}, ${bankDeatails['businessName']}, ${bankDeatails['sortCode']}"
              : 'No Bank Account';

          String searchKey = data['searchKey'] ?? 'Unknown searchKey';
          // Handling List data safely
          List<String> daysOpen =
              List<String>.from(generalInfo['daysOpen'] ?? []);
          String daysOpenStr = daysOpen.join(', ');

          var dishes = data['dishes'] as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    size: 23,
                    text: "Restaurant Details",
                    align: TextAlign.start,
                    fontWeight: FontWeight.w600,
                    textColor: blackColor,
                  ),
                  const SizedBox(height: 40),
                  ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text("About Us"),
                    subtitle: Text(aboutUs),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.map),
                    title: Text("Collection Radius"),
                    subtitle: Text(collectionRadius),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text("Days Open"),
                    subtitle: Text(daysOpenStr),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text("Parsed Address"),
                    subtitle: Text(companyParsedAddress),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.account_box),
                    title: Text("Parsed Bank Account"),
                    subtitle: Text(companyParsedBankDetails),
                  ),
                  Divider(),
                  TextButton(
                    child: const Text("View Menu"),
                    onPressed: () {
                      _navigateToMenuScreen(context, dishes, searchKey);
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RestaurantMenuScreen extends StatelessWidget {
  final String restaurantId;
  final Map<String, dynamic> dishes;
  final String searchKey;

  RestaurantMenuScreen({
    required this.restaurantId,
    required this.dishes,
    required this.searchKey,
  });

  Future<String> getDishImageUrl(
      String searchKey, String sanitizedDishName) async {
    String imagePath =
        'company/images/dish_images/$searchKey/$sanitizedDishName.jpg';
    final ref = FirebaseStorage.instance.ref().child(imagePath);
    try {
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error fetching image URL: $e");
      return 'assets/images/default.jpg'; // Default image if none found
    }
  }

  Widget buildDishesCard(Map<String, dynamic> dish, String searchKey) {
    String dishName = dish['name'] ?? 'Unknown Dish';
    List<dynamic> allergens = dish['allergens'] ?? [];
    // List<dynamic> assignTags = dish['assignTags'] ?? [];
    int comboPrice = dish['comboPrice'] ?? 0;

    String sanitizedDishName = dishName.replaceAll(RegExp(r'\W+'), '_');

    String typeOfDishStr = (dish['typeOfDish'] as Map<String, dynamic>)
        .entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .join(', ');

    return FutureBuilder<String>(
      future: getDishImageUrl(searchKey, sanitizedDishName),
      builder: (context, snapshot) {
        return Card(
          margin: const EdgeInsets.all(4),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantMenuDetailsScreen(
                    restaurantId: restaurantId,
                    dish: dish,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  snapshot.connectionState == ConnectionState.waiting
                      ? const SizedBox(
                          height: 60,
                          child: Center(child: CircularProgressIndicator()))
                      : ClipRRect(
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
                        ),
                  const SizedBox(height: 4),
                  Text(
                    dishName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Allergens: ${allergens.join(', ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  // Text(
                  //   'Tags: ${assignTags.join(', ')}',
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: const TextStyle(fontSize: 12),
                  // ),
                  const SizedBox(height: 2),
                  Text(
                    'Price: £${comboPrice.toString()}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  // const SizedBox(height: 2),
                  // Text(
                  //   'Available: ${(dish['dateAvailability'] as Map<String, dynamic>).entries.where((entry) => entry.value == true).map((entry) => entry.key).join(', ')}',
                  //   style: const TextStyle(fontSize: 12),
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  const SizedBox(height: 2),
                  Text(
                    'Type of Dish: $typeOfDishStr',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> dishesList = dishes.entries.map((entry) {
      return {
        'name': entry.key,
        ...entry.value as Map<String, dynamic>,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                size: 23,
                text: "Restaurant Menu",
                align: TextAlign.start,
                fontWeight: FontWeight.w600,
                textColor: blackColor,
              ),
              const SizedBox(height: 40),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: dishesList.length,
                itemBuilder: (context, index) {
                  return buildDishesCard(dishesList[index], searchKey);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RestaurantMenuDetailsScreen extends StatelessWidget {
  final String restaurantId;
  final Map<String, dynamic> dish;

  RestaurantMenuDetailsScreen({required this.restaurantId, required this.dish});

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDishDetailsScreen(
          restaurantId: restaurantId,
          dish: dish,
          onSave: () {
            Navigator.pop(
                context, true); // Notify parent screen to refresh data
          },
        ),
      ),
    ).then((value) {
      if (value == true) {
        // Call setState to refresh data when returning from edit screen
        (context as Element).markNeedsBuild();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String dishName = dish['name'] ?? 'Unknown Dish';
    List<dynamic> allergens = dish['allergens'] ?? [];
    List<dynamic> assignTags = dish['assignTags'] ?? [];
    int comboPrice = dish['comboPrice'] ?? 0;
    String typeOfDishStr = (dish['typeOfDish'] as Map<String, dynamic>)
        .entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .join(', ');
    // String sanitizedDishName = dishName.replaceAll(RegExp(r'\W+'), '_');

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _navigateToEditScreen(context);
            },
          ),
        ],
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
            return Center(child: Text("No details available"));
          }

          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    size: 23,
                    text: "Dish Details",
                    align: TextAlign.start,
                    fontWeight: FontWeight.w600,
                    textColor: blackColor,
                  ),
                  const SizedBox(height: 40),
                  ListTile(
                    leading: Icon(Icons.fastfood),
                    title: Text(
                      dishName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      dish['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.warning),
                    title: Text('Allergens'),
                    subtitle: Text(
                      allergens.join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.tag),
                    title: Text('Tags'),
                    subtitle: Text(
                      assignTags.join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.attach_money),
                    title: Text('Price'),
                    subtitle: Text(
                      '£${comboPrice.toString()}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Available'),
                    subtitle: Text(
                      (dish['dateAvailability'] as Map<String, dynamic>)
                          .entries
                          .where((entry) => entry.value == true)
                          .map((entry) => entry.key)
                          .join(', '),
                      // style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.restaurant_menu),
                    title: Text('Type of Dish'),
                    subtitle: Text(
                      typeOfDishStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditDishDetailsScreen extends StatefulWidget {
  final String restaurantId;
  final Map<String, dynamic> dish;
  final VoidCallback onSave;

  EditDishDetailsScreen(
      {required this.restaurantId, required this.dish, required this.onSave});

  @override
  _EditDishDetailsScreenState createState() => _EditDishDetailsScreenState();
}

class _EditDishDetailsScreenState extends State<EditDishDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController allergensController;
  late TextEditingController tagsController;
  Map<String, dynamic> dateAvailability = {};
  Map<String, dynamic> typeOfDish = {};

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.dish['name']);
    descriptionController =
        TextEditingController(text: widget.dish['description']);
    priceController =
        TextEditingController(text: widget.dish['comboPrice'].toString());
    allergensController =
        TextEditingController(text: widget.dish['allergens'].join(', '));
    tagsController =
        TextEditingController(text: widget.dish['assignTags'].join(', '));
    dateAvailability =
        Map<String, dynamic>.from(widget.dish['dateAvailability']);
    typeOfDish = Map<String, dynamic>.from(widget.dish['typeOfDish']);
  }

  Future<void> saveDishDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(widget.restaurantId)
          .update({
        'dishes.${widget.dish['name']}': {
          'name': nameController.text,
          'description': descriptionController.text,
          'comboPrice': int.parse(priceController.text),
          'allergens':
              allergensController.text.split(',').map((e) => e.trim()).toList(),
          'assignTags':
              tagsController.text.split(',').map((e) => e.trim()).toList(),
          'dateAvailability': dateAvailability,
          'typeOfDish': typeOfDish,
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dish details updated successfully')),
      );
      widget.onSave(); // Notify the parent widget
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update dish details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Dish'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveDishDetails,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Dish Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: allergensController,
              decoration:
                  InputDecoration(labelText: 'Allergens (comma separated)'),
            ),
            TextField(
              controller: tagsController,
              decoration: InputDecoration(labelText: 'Tags (comma separated)'),
            ),
            const SizedBox(height: 16),
            Text('Date Availability'),
            ...dateAvailability.keys.map((day) {
              return CheckboxListTile(
                title: Text(day),
                value: dateAvailability[day],
                onChanged: (value) {
                  setState(() {
                    dateAvailability[day] = value;
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 16),
            Text('Type of Dish'),
            ...typeOfDish.keys.map((type) {
              return CheckboxListTile(
                title: Text(type),
                value: typeOfDish[type],
                onChanged: (value) {
                  setState(() {
                    typeOfDish[type] = value;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class EditRestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;
  final Map<String, dynamic> restaurantData;
  final VoidCallback onSave;

  EditRestaurantDetailsScreen({
    required this.restaurantId,
    required this.restaurantData,
    required this.onSave,
  });

  @override
  _EditRestaurantDetailsScreenState createState() =>
      _EditRestaurantDetailsScreenState();
}

class _EditRestaurantDetailsScreenState
    extends State<EditRestaurantDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController aboutUsController;
  late TextEditingController collectionRadiusController;
  late TextEditingController cityController;
  late TextEditingController countryController;
  late TextEditingController firstLineController;
  late TextEditingController postcodeController;
  late TextEditingController bankNameController;
  late TextEditingController sortCodeController;
  late TextEditingController accountNumberController;
  late TextEditingController businessNameController;
  List<String> daysOpen = [];

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.restaurantData['companyName']);
    aboutUsController = TextEditingController(
        text: widget.restaurantData['generalInformation']['aboutUs']);
    collectionRadiusController = TextEditingController(
        text: widget.restaurantData['generalInformation']['collectionRadius']);
    var address = widget.restaurantData['generalInformation']['address']
        as Map<String, dynamic>;
    var bankDetails =
        widget.restaurantData['bankDetails'] as Map<String, dynamic>;
    cityController = TextEditingController(text: address['city']);
    countryController = TextEditingController(text: address['country']);
    firstLineController = TextEditingController(text: address['firstLine']);
    postcodeController = TextEditingController(text: address['postcode']);
    daysOpen = List<String>.from(
        widget.restaurantData['generalInformation']['daysOpen'] ?? []);

    bankNameController = TextEditingController(text: bankDetails['']);
    sortCodeController = TextEditingController(text: bankDetails['']);
    accountNumberController = TextEditingController(text: bankDetails['']);
    businessNameController = TextEditingController(text: bankDetails['']);
  }

  Future<void> saveRestaurantDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(widget.restaurantId)
          .update({
        'companyName': nameController.text,
        'generalInformation.aboutUs': aboutUsController.text,
        'generalInformation.collectionRadius': collectionRadiusController.text,
        'generalInformation.address': {
          'city': cityController.text,
          'country': countryController.text,
          'firstLine': firstLineController.text,
          'postcode': postcodeController.text,
        },
        'generalInformation.daysOpen': daysOpen,
        'bankDetails': {
          'accountNumber': accountNumberController.text,
          'bankName': bankNameController.text,
          'businessName': businessNameController.text,
          'sortCode': sortCodeController.text,
        },
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restaurant details updated successfully')),
      );
      widget.onSave(); // Notify the parent widget
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update restaurant details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Restaurant'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveRestaurantDetails,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Restaurant Name'),
            ),
            TextField(
              controller: aboutUsController,
              decoration: InputDecoration(labelText: 'About Us'),
            ),
            TextField(
              controller: collectionRadiusController,
              decoration: InputDecoration(labelText: 'Collection Radius'),
            ),
            TextField(
              controller: firstLineController,
              decoration: InputDecoration(labelText: 'Address Line 1'),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: countryController,
              decoration: InputDecoration(labelText: 'Country'),
            ),
            TextField(
              controller: postcodeController,
              decoration: InputDecoration(labelText: 'Postcode'),
            ),
            TextField(
              controller: accountNumberController,
              decoration: InputDecoration(labelText: 'Account Number'),
            ),
            TextField(
              controller: sortCodeController,
              decoration: InputDecoration(labelText: 'Sort Code'),
            ),
            TextField(
              controller: bankNameController,
              decoration: InputDecoration(labelText: 'Bank Name'),
            ),
            TextField(
              controller: businessNameController,
              decoration: InputDecoration(labelText: 'Business Name'),
            ),
            const SizedBox(height: 16),
            Text('Days Open'),
            ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
              return CheckboxListTile(
                title: Text(day),
                value: daysOpen.contains(day),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      daysOpen.add(day);
                    } else {
                      daysOpen.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
