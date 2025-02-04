import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/widgets/custom_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:adminpanelweb/globals/globals.dart' as globals;

class ViewMenuScreen extends StatefulWidget {
  final String? userDocId;

  const ViewMenuScreen({Key? key, this.userDocId}) : super(key: key);

  @override
  _ViewMenuScreenState createState() => _ViewMenuScreenState();
}

class _ViewMenuScreenState extends State<ViewMenuScreen> {
  Stream<List<Map<String, dynamic>>>? dishes;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    dishes = fetchDishes();
  }

  Stream<List<Map<String, dynamic>>> fetchDishes() {
    if (widget.userDocId == null) {
      return Stream.value([]);
    }
    DocumentReference restaurantDoc = FirebaseFirestore.instance
        .collection('Restaurants')
        .doc(widget.userDocId);

    return restaurantDoc.snapshots().map((docSnapshot) {
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return [];
      }

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      String searchKey = data['searchKey'] ?? 'Unknown_searchKey';

      List<Map<String, dynamic>> dishesList = [];
      if (data.containsKey('dishes')) {
        data['dishes'].forEach((key, value) {
          dishesList.add({
            ...value,
            'searchKey': searchKey,
            'id': key,
          });
        });
      }
      return dishesList;
    });
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

  Future<void> deleteDish(String dishId) async {
    if (widget.userDocId != null) {
      DocumentReference restaurantDoc = FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(widget.userDocId);
      await restaurantDoc.update({
        'dishes.$dishId': FieldValue.delete(),
      });
    }
  }

  Widget buildDishCard(Map<String, dynamic> dish) {
    String sanitizedDishName = dish['name'].replaceAll(RegExp(r'\W+'), '_');
    String searchKey = dish['searchKey'] ?? 'Unknown_searchKey';
    String imagePath =
        'company/images/dish_images/$searchKey/$sanitizedDishName.jpg';

    return FutureBuilder<String>(
      future: getImageUrl(imagePath),
      builder: (context, imageSnapshot) {
        return Card(
          margin: const EdgeInsets.all(4),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dish.isNotEmpty)
                      if (imageSnapshot.connectionState ==
                          ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (imageSnapshot.hasError ||
                          !imageSnapshot.hasData ||
                          imageSnapshot.data!.isEmpty)
                        const Icon(Icons.error, size: 50)
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            imageSnapshot.data!,
                            width: double.infinity,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error building image: $error');
                              return const Icon(Icons.error, size: 50);
                            },
                          ),
                        ),
                    const SizedBox(height: 4),
                    Text(
                      globals.capitalizeEachWord(dish['name']),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dish['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Price: \£${dish['price'].toString()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Type of Dish: ${(dish['typeOfDish'] as Map<String, dynamic>).entries.where((entry) => entry.value == true).map((entry) => entry.key).join(', ')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Available: ${dish['dateAvailability']}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (dish['assignTags'] != null &&
                        dish['assignTags'].isNotEmpty)
                      Text(
                        'Tags: ' + dish['assignTags'].join(', '),
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    if (dish['allergens'] != null &&
                        dish['allergens'].isNotEmpty)
                      Text(
                        'Allergens: ' + dish['allergens'].join(', '),
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  // onPressed: () async {
                  //   await deleteDish(dish['id']);
                  //   setState(() {
                  //     dishes = fetchDishes();
                  //   });
                  // },
                  onPressed: () {
                    // Show confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Deletion"),
                          content: const Text(
                              "Are you sure you want to delete this dish? This action cannot be undone."),
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
                                await deleteDish(dish['id']);
                                setState(() {
                                  dishes = fetchDishes();
                                });
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  size: 23,
                  text: "View Menu",
                  align: TextAlign.start,
                  fontWeight: FontWeight.w600,
                  textColor: blackColor,
                ),
                const SizedBox(height: 40),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: dishes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.error != null || snapshot.data == null) {
                      return const Center(child: Text('Failed to load dishes'));
                    }

                    // Filter dishes based on search query
                    final List<Map<String, dynamic>> filteredDishes = snapshot
                        .data!
                        .where((dish) =>
                            dish['name'].toLowerCase().contains(searchQuery) ||
                            dish['description']
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
                      itemCount: filteredDishes.length,
                      itemBuilder: (ctx, i) {
                        var dish = filteredDishes[i];
                        return buildDishCard(dish);
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
