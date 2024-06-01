// import 'dart:html';
import 'dart:html' hide VoidCallback;
import 'dart:ui';
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
    bool isDisabled =
        restaurant['disabled'] ?? false; // Check if the restaurant is disabled

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
                  if (!isDisabled) {
                    // Only navigate if the restaurant is not disabled
                    String? docId =
                        await globals.getDocIdBySearchKey(searchKey);
                    print("Navigating to details with Restaurant ID: $docId");
                    _navigateToDetailsScreen(context, docId);
                  }
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
                        globals.capitalizeEachWord(
                            restaurant['companyName'] ?? 'N/A'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    ],
                  ),
                ),
              ),
              if (isDisabled)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: Icon(Icons.visibility_off, color: Colors.red),
                  onPressed: () async {
                    String? docId =
                        await globals.getDocIdBySearchKey(searchKey);
                    if (docId != null) {
                      await FirebaseFirestore.instance
                          .collection('Restaurants')
                          .doc(docId)
                          .update({
                        'disabled': !isDisabled
                      }); // Toggle the disabled status
                    }
                  },
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
                    // var docs = snapshot.data!.docs;

                    var docsWithoutAdmin = docs.where((doc) {
                      var docData = doc.data() as Map<String, dynamic>;
                      var companyName =
                          docData['companyName'].toString().toLowerCase();
                      return companyName != 'admintiffintime';
                    }).toList();

                    List<Map<String, dynamic>> filteredRestaurants =
                        docsWithoutAdmin
                            .map(
                              (doc) => {
                                'id': doc.id, // Get document ID from Firestore
                                ...doc.data() as Map<String,
                                    dynamic> // Spread other document data
                              },
                            ) // Handle possible null data
                            .where((restaurant) =>
                                restaurant !=
                                null) // Filter out null restaurants
                            .map((restaurant) => {
                                  'companyName':
                                      restaurant?['companyName'] ?? '',
                                  'searchKey': restaurant?['searchKey'] ?? '',
                                  'companyNumber':
                                      restaurant?['companyNumber'] ?? '',
                                  'niNumber': restaurant?['niNumber'] ?? '',
                                  'disabled': restaurant?['disabled'] ??
                                      false, // Add disabled status
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
          var collectionTimes =
              generalInfo['collectionTimes'] as Map<String, dynamic>? ?? {};
          var deliveryTimes =
              generalInfo['deliveryTimes'] as Map<String, dynamic>? ?? {};
          var maxPeoplePerHour =
              generalInfo['maxPeoplePerHour'] as Map<String, dynamic>? ?? {};

          // Safely access String fields
          String companyName = data['companyName'] as String? ?? 'No Name';
          String aboutUs = generalInfo['aboutUs'] as String? ?? 'Not provided';
          String collectionRadius = generalInfo['collectionRadius'] ?? '';
          var bankDeatails = data['bankDetails'] as Map<String, dynamic>? ?? {};
          String companyNumber =
              data['companyNumber'] as String? ?? 'No Company Number';
          String niNumber = data['niNumber'] as String? ?? 'No Ni Number';
          //TODO: ADD generalInformation[collectionTimes, daysNotice, deliveryCharge, deliveryRadius, deliveryTimes, maxPeoplePerHour, minOrderSpend, phoneNumber]

          String companyParsedAddress = parsedAddress.isNotEmpty
              ? "${parsedAddress['firstLine']}, ${parsedAddress['city']}, ${parsedAddress['country']}, ${parsedAddress['postcode']}"
              : 'No Address';
          String companyParsedBankDetails = bankDeatails.isNotEmpty
              ? "${bankDeatails['accountNumber']}, ${bankDeatails['bankName']}, ${bankDeatails['businessName']}, ${bankDeatails['sortCode']}"
              : 'No Bank Account';

          String searchKey = data['searchKey'] ?? 'Unknown searchKey';
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
                  ListTile(
                    leading: Icon(Icons.numbers),
                    title: Text("Company Number"),
                    subtitle: Text(companyNumber),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.numbers),
                    title: Text("NINumber"),
                    subtitle: Text(niNumber),
                  ),
                  Divider(),
                  //TODO: ADD generalInformation[ maxPeoplePerHour, minOrderSpend, phoneNumber]

                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text("Collection Times"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: collectionTimes.entries.map((entry) {
                        return Text("${entry.key}: ${entry.value}");
                      }).toList(),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.delivery_dining),
                    title: Text("Delivery Times"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: deliveryTimes.entries.map((entry) {
                        return Text("${entry.key}: ${entry.value}");
                      }).toList(),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text("Max People Per Hour"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: maxPeoplePerHour.entries.map((entry) {
                        return Text("${entry.key}: ${entry.value}");
                      }).toList(),
                    ),
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

class RestaurantMenuScreen extends StatefulWidget {
  final String restaurantId;
  final String searchKey;

  RestaurantMenuScreen({
    required this.restaurantId,
    required this.searchKey,
  });

  @override
  _RestaurantMenuScreenState createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Stream<List<Map<String, dynamic>>> fetchDishes() {
    return FirebaseFirestore.instance
        .collection('Restaurants')
        .doc(widget.restaurantId)
        .snapshots()
        .map((snapshot) {
      var data = snapshot.data() as Map<String, dynamic>?;
      var dishes = data?['dishes'] as Map<String, dynamic>? ?? {};
      return dishes.entries.map((entry) {
        return {
          'name': entry.key,
          ...entry.value as Map<String, dynamic>,
        };
      }).toList();
    });
  }

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
    int price = dish['price'] ?? 0;
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
                    restaurantId: widget.restaurantId,
                    dish: dish,
                  ),
                ),
              ).then((value) {
                if (value == true) {
                  (context as Element).markNeedsBuild();
                }
              });
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
                    globals.capitalizeEachWord(dishName),
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
                  Text(
                    'Price: £${price.toString()}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search dishes...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            setState(() {
              searchQuery = query.toLowerCase();
            });
          },
        ),
      ),
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
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchDishes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error fetching dishes"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No dishes available"));
                  }

                  var dishesList = snapshot.data!
                      .where((dish) =>
                          dish['name'].toLowerCase().contains(searchQuery))
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
                    itemCount: dishesList.length,
                    itemBuilder: (context, index) {
                      return buildDishesCard(
                          dishesList[index], widget.searchKey);
                    },
                  );
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

  Future<Map<String, dynamic>?> getDishData(
      String restaurantId, String dishName) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(restaurantId)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>?;
        var dishes = data?['dishes'] as Map<String, dynamic>?;
        return dishes?[dishName] as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching dish data: $e");
      return null;
    }
  }

  void _navigateToEditScreen(
      BuildContext context, Map<String, dynamic> dishData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDishDetailsScreen(
          restaurantId: restaurantId,
          dish: dishData,
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
    int price = dish['price'] ?? 0;
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
            onPressed: () async {
              Map<String, dynamic>? dishData =
                  await getDishData(restaurantId, dishName);
              if (dishData != null) {
                _navigateToEditScreen(context, dishData);
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
                    title: Text('Combo Price'),
                    subtitle: Text(
                      '£${comboPrice.toString()}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.attach_money),
                    title: Text('Price'),
                    subtitle: Text(
                      '£${price.toString()}',
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
  late TextEditingController comboPriceController;
  late TextEditingController priceController;
  Map<String, dynamic> dateAvailability = {};
  Map<String, dynamic> typeOfDish = {};
  List<String> allergens = [];
  List<String> assignTags = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.dish['name']);
    descriptionController =
        TextEditingController(text: widget.dish['description']);
    comboPriceController =
        TextEditingController(text: widget.dish['comboPrice'].toString());
    priceController =
        TextEditingController(text: widget.dish['price'].toString());
    dateAvailability =
        Map<String, dynamic>.from(widget.dish['dateAvailability']);
    typeOfDish = Map<String, dynamic>.from(widget.dish['typeOfDish']);
    allergens = List<String>.from(widget.dish['allergens'] ?? []);
    assignTags = List<String>.from(widget.dish['assignTags'] ?? []);
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
          'comboPrice': int.parse(comboPriceController.text),
          'price': int.parse(priceController.text),
          'allergens': allergens,
          'assignTags': assignTags,
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
              enabled: false,
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
              controller: comboPriceController,
              decoration: InputDecoration(labelText: 'Combo Price'),
              keyboardType: TextInputType.number,
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
            const SizedBox(height: 16),
            Text('Assigned Tags'),
            ...[
              'Vegetarian',
              'Vegan',
              'Jain',
              'No Onion/ Garlic',
              'High Protein',
              'Meat'
            ].map((assignTag) {
              return CheckboxListTile(
                title: Text(assignTag),
                value: assignTags.contains(assignTag),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      assignTags.add(assignTag);
                    } else {
                      assignTags.remove(assignTag);
                    }
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 16),
            Text('Allergens'),
            ...['Peanuts', 'Dairy', 'Gluten', 'Shellfish', 'Soy']
                .map((allergen) {
              return CheckboxListTile(
                title: Text(allergen),
                value: allergens.contains(allergen),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      allergens.add(allergen);
                    } else {
                      allergens.remove(allergen);
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
  late TextEditingController collectionDeliveryRadiusController;
  late TextEditingController deliveryChargeController;
  late TextEditingController deliveryRadiusController;
  late TextEditingController daysNoticeController;
  late TextEditingController cityController;
  late TextEditingController countryController;
  late TextEditingController firstLineController;
  late TextEditingController postcodeController;
  late TextEditingController bankNameController;
  late TextEditingController sortCodeController;
  late TextEditingController accountNumberController;
  late TextEditingController businessNameController;
  List<String> daysOpen = [];

  Map<String, TextEditingController> collectionTimesControllers = {};
  Map<String, TextEditingController> deliveryTimesControllers = {};
  Map<String, TextEditingController> maxPeoplePerHourControllers = {};

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.restaurantData['companyName']);
    aboutUsController = TextEditingController(
        text: widget.restaurantData['generalInformation']['aboutUs']);
    collectionRadiusController = TextEditingController(
        text: widget.restaurantData['generalInformation']['collectionRadius']);
    deliveryRadiusController = TextEditingController(
        text: widget.restaurantData['generalInformation']['deliveryRadius']);
    collectionDeliveryRadiusController = TextEditingController(
        text: widget.restaurantData['generalInformation']
            ['collectionDeliveryRadius']);
    deliveryChargeController = TextEditingController(
        text: widget.restaurantData['generalInformation']['deliveryCharge']);
    daysNoticeController = TextEditingController(
        text: widget.restaurantData['generalInformation']['daysNotice']
            .toString());
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

    bankNameController = TextEditingController(text: bankDetails['bankName']);
    sortCodeController = TextEditingController(text: bankDetails['sortCode']);
    accountNumberController =
        TextEditingController(text: bankDetails['accountNumber']);
    businessNameController =
        TextEditingController(text: bankDetails['businessName']);

    var collectionTimes = widget.restaurantData['generalInformation']
            ['collectionTimes'] as Map<String, dynamic>? ??
        {};
    var deliveryTimes = widget.restaurantData['generalInformation']
            ['deliveryTimes'] as Map<String, dynamic>? ??
        {};
    var maxPeoplePerHour = widget.restaurantData['generalInformation']
            ['maxPeoplePerHour'] as Map<String, dynamic>? ??
        {};

    collectionTimes.forEach((key, value) {
      collectionTimesControllers[key] = TextEditingController(text: value);
    });

    deliveryTimes.forEach((key, value) {
      deliveryTimesControllers[key] = TextEditingController(text: value);
    });

    maxPeoplePerHour.forEach((key, value) {
      maxPeoplePerHourControllers[key] = TextEditingController(text: value);
    });
  }

  Future<void> saveRestaurantDetails() async {
    try {
      Map<String, String> collectionTimes = {};
      collectionTimesControllers.forEach((key, controller) {
        collectionTimes[key] = controller.text;
      });

      Map<String, String> deliveryTimes = {};
      deliveryTimesControllers.forEach((key, controller) {
        deliveryTimes[key] = controller.text;
      });

      Map<String, String> maxPeoplePerHour = {};
      maxPeoplePerHourControllers.forEach((key, controller) {
        maxPeoplePerHour[key] = controller.text;
      });

      await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(widget.restaurantId)
          .update({
        'companyName': nameController.text,
        'generalInformation.aboutUs': aboutUsController.text,
        'generalInformation.collectionRadius': collectionRadiusController.text,
        'generalInformation.deliveryRadius': deliveryRadiusController.text,
        'generalInformation.collectionDeliveryRadius':
            collectionDeliveryRadiusController.text,
        'generalInformation.deliveryCharge': deliveryChargeController.text,
        'generalInformation.daysNotice':
            int.tryParse(daysNoticeController.text) ?? 0,
        'generalInformation.address': {
          'city': cityController.text,
          'country': countryController.text,
          'firstLine': firstLineController.text,
          'postcode': postcodeController.text,
        },
        'generalInformation.daysOpen': daysOpen,
        'generalInformation.collectionTimes': collectionTimes,
        'generalInformation.deliveryTimes': deliveryTimes,
        'generalInformation.maxPeoplePerHour': maxPeoplePerHour,
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
              enabled: false,
            ),
            TextField(
              controller: aboutUsController,
              decoration: InputDecoration(labelText: 'About Us'),
            ),
            SizedBox(height: 30),
            const Text(
              'Collection/Delivery Field',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: collectionRadiusController,
              decoration: const InputDecoration(
                  labelText:
                      'Collection Radius (If only collection is offered)'),
            ),
            TextField(
              controller: collectionDeliveryRadiusController,
              decoration: const InputDecoration(
                  labelText:
                      'Collection Radius (If Delivery is also offered )'),
            ),
            TextField(
              controller: deliveryRadiusController,
              decoration: InputDecoration(labelText: 'Delivery Radius'),
            ),
            TextField(
              controller: deliveryChargeController,
              decoration: InputDecoration(labelText: 'Delivery Charge'),
            ),
            TextField(
              controller: daysNoticeController,
              decoration: InputDecoration(labelText: 'Days Notice'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            const Text(
              'Address Field',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
            SizedBox(height: 30),
            const Text(
              'Bank Details Field',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
            const SizedBox(height: 30),
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
            SizedBox(height: 30),
            const Text(
              'Collection Times',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...collectionTimesControllers.keys.map((day) {
              return TextField(
                controller: collectionTimesControllers[day],
                decoration: InputDecoration(labelText: '$day Collection Time'),
              );
            }).toList(),
            SizedBox(height: 30),
            const Text(
              'Delivery Times',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...deliveryTimesControllers.keys.map((day) {
              return TextField(
                controller: deliveryTimesControllers[day],
                decoration: InputDecoration(labelText: '$day Delivery Time'),
              );
            }).toList(),
            SizedBox(height: 30),
            const Text(
              'Max People Per Hour',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...maxPeoplePerHourControllers.keys.map((day) {
              return TextField(
                controller: maxPeoplePerHourControllers[day],
                decoration: InputDecoration(labelText: '$day Max People'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
