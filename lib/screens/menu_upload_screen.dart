// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:csv/csv.dart';
// import 'package:intl/intl.dart';

import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/models/dish.dart';
import 'package:adminpanelweb/models/offer.dart';
import 'package:adminpanelweb/widgets/custom_text.dart';
import 'package:adminpanelweb/widgets/custom_btn.dart';
import 'package:adminpanelweb/widgets/custom_dis_textfield.dart';
import 'package:adminpanelweb/widgets/custom_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adminpanelweb/globals/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MenuUploadScreen extends StatefulWidget {
  final String? userDocId;

  const MenuUploadScreen({Key? key, this.userDocId}) : super(key: key);

  @override
  State<MenuUploadScreen> createState() => _MenuUploadScreenState();
}

class _MenuUploadScreenState extends State<MenuUploadScreen> {
  bool isSubscriptionService = false;
  Map<String, bool> dishTypeValue = {
    'Main': true,
    'Extra': false,
  };
  String combowithAnotherDishValue = '01';
  List<bool> isSelected = List.generate(7, (_) => false);
  List<Dish> dishes = [];
  List<Offer> offers = [];
  String? currentRestaurantDocId;
  Image? _displayImage;
  html.File? selectedFile;
  Uint8List? _selectedImageData;

  final List<String> allergens = [
    'Peanuts',
    'Dairy',
    'Gluten',
    'Shellfish',
    'Soy'
  ];

  final Map<String, bool> selectedAllergens = {
    'Peanuts': false,
    'Dairy': false,
    'Gluten': false,
    'Shellfish': false,
    'Soy': false,
  };

  List<String> options = [
    'Vegetarian',
    'Vegan',
    'Jain',
    'No Onion/ Garlic',
    'High Protein',
    'Meat'
  ];
  List<bool> isTagSelected = [];
  @override
  void initState() {
    super.initState();
    isTagSelected = List.generate(options.length, (index) => false);
  }

  TextEditingController dishNameController = TextEditingController();
  TextEditingController dishDescriptionController = TextEditingController();
  TextEditingController dishPriceController = TextEditingController();
  TextEditingController dishTypeController = TextEditingController();
  TextEditingController dishTagController = TextEditingController();
  TextEditingController dishComboController = TextEditingController();
  TextEditingController dishComboPriceController = TextEditingController();
  TextEditingController dishImageController = TextEditingController();
  TextEditingController dishDateAvailabilityController =
      TextEditingController();

  TextEditingController mealsForWeekController = TextEditingController();
  TextEditingController weekController = TextEditingController();
  TextEditingController offPresentageController = TextEditingController();

  TextEditingController includeWithMainDetailController =
      TextEditingController();

  TextEditingController allergenController = TextEditingController();

  @override
  void dispose() {
    dishNameController.dispose();
    dishDescriptionController.dispose();
    dishPriceController.dispose();
    dishTypeController.dispose();
    dishTagController.dispose();
    dishComboController.dispose();
    dishComboPriceController.dispose();
    dishImageController.dispose();
    dishDateAvailabilityController.dispose();
    mealsForWeekController.dispose();
    weekController.dispose();
    offPresentageController.dispose();
    includeWithMainDetailController.dispose();
    super.dispose();
  }

  DateAvailability _dateAvailability = DateAvailability.everyDay;
  DeliveryFee _deliveryFee = DeliveryFee.freeDelivery;
  DateTime today = DateTime.now();
  DateTime? startRange;
  DateTime? endRange;
  Set<DateTime> selectedDishDates = {}; //Store selected days

  Widget buildOptionForDateAvailability() {
    return Column(
      children: [
        TableCalendar(
          focusedDay: today,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 1, 1),
          selectedDayPredicate: (day) {
            return selectedDishDates
                .any((selectedDay) => isSameDay(selectedDay, day));
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              today = focusedDay;
              if (selectedDishDates.contains(selectedDay)) {
                //remove the date if already selected
                selectedDishDates.remove(selectedDay);
              } else {
                //add new date
                selectedDishDates.add(selectedDay);
              }
            });
          },
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        if (selectedDishDates.isNotEmpty)
          Text(
            'Selected dates:${selectedDishDates.map((entry) => entry.toLocal().toString().split(' ')[0]).join(', ')}',
            textAlign: TextAlign.center,
          )
      ],
    );
  }
  // BpoAKJnu5THlN8GIgvLR

  Widget buildOptionforDateAvail(String title, DateAvailability value) {
    bool isSelected = _dateAvailability == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _dateAvailability = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? lightBlue : Colors.black,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget buildOptionforDelivery(String title, DeliveryFee value) {
    bool isSelected = _deliveryFee == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _deliveryFee = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? lightBlue : Colors.black,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget offerListingWidget() {
    var containerSize = 80 * offers.length;
    return SizedBox(
      height: containerSize.toDouble(),
      child: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: lightBlue2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomText(
                  size: 16,
                  text: '${offers[index].mealsForWeek} Meals per week for',
                  fontWeight: FontWeight.w500,
                  textColor: blackColor,
                ),
                CustomText(
                  size: 16,
                  text: '${offers[index].week} of weeks',
                  fontWeight: FontWeight.w500,
                  textColor: blackColor,
                ),
                CustomText(
                  size: 16,
                  text: '${offers[index].offPresentage}% Off',
                  fontWeight: FontWeight.w500,
                  textColor: blackColor,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Delete the item from the list
                    setState(() {
                      offers.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<String> uploadImage(
      Uint8List data, String searchKey, String dishName) async {
    // String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // Sanitize the dish name for use in a URL
    final sanitizedDishName = dishName.replaceAll(RegExp(r'\W+'), '_');

    // Construct the storage path
    String storagePath =
        'company/images/dish_images/$searchKey/$sanitizedDishName.jpg';

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(storagePath);

    // Upload the image
    TaskSnapshot uploadTask = await ref.putData(data);

    // Return the download URL
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> uploadDishesToFirestore() async {
    if (widget.userDocId == null) {
      _showError('User document ID not provided.');
      return;
    }

    try {
      // Get restaurant document reference
      DocumentReference restaurantDoc = FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(widget.userDocId);

      // Get the restaurant document
      DocumentSnapshot docSnapshot = await restaurantDoc.get();
      if (!docSnapshot.exists) {
        _showError('Restaurant not found.');
        return;
      }

      // Extract the searchKey from the restaurant data
      String searchKey = docSnapshot['searchKey'];
      if (searchKey.isEmpty) {
        _showError('searchKey not found.');
        return;
      }

// Prepare the data structure for Firestore
      Map<String, dynamic> existingDishes = {};
      final data = docSnapshot.data() as Map<String, dynamic>;
      if (data != null && data.containsKey('dishes')) {
        existingDishes = Map<String, dynamic>.from(data['dishes']);
      }

      for (Dish dish in dishes) {
        String imageUrl =
            await uploadImage(dish.imageData, searchKey, dish.name);
        existingDishes[dish.name] = dish.toFirestoreMap()
          ..['dishImage'] = imageUrl
          ..['dateAvailability'] = dish.dateAvailability.contains("Everyday")
              ? "Everyday"
              : dish.dateAvailability;
      }

      // Update the Firestore document
      await restaurantDoc.update({'dishes': existingDishes});

      setState(() {
        dishes.clear(); // Clear local dishes after uploading
        _selectedImageData = null;
        selectedFile = null;
      });
    } catch (e) {
      _showError('Error uploading dishes: $e');
    }
  }

  void _handleFileReadError(dynamic error) {
    // Handle the error (e.g., show a message to the user)
    print('Error reading file: $error');
  }

  void _pickImage() {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = 'image/*';
    input.click();

    input.onChange.listen((event) {
      if (input.files != null && input.files!.isNotEmpty) {
        final html.File file = input.files!.first;

        // Check if the file is empty
        if (file.size == 0) {
          _showError('Selected file is empty');
          return;
        }

        // Check the file format
        final supportedFormats = ['image/jpeg', 'image/png'];
        if (!supportedFormats.contains(file.type)) {
          _showError(
              'Unsupported file format. Please select a JPEG or PNG image');
          return;
        }

        // Read the file as bytes
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);

        reader.onLoadEnd.listen((event) {
          final Uint8List? data = reader.result as Uint8List?;

          if (data == null || data.isEmpty) {
            _showError('Failed to read file');
            return;
          }
          // Debugging: Print data length to verify
          print('Image data length: ${data.length}');
          // Update the state with the selected image data
          setState(() {
            _selectedImageData = data;
            selectedFile = file;
          });
        });

        reader.onError.listen((error) {
          _showError('Failed to read file: $error');
        });
      } else {
        _showError('No file selected');
      }
    });
  }

// Helper method to show an error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _addDishLocally() async {
    if (dishNameController.text.isEmpty ||
        dishDescriptionController.text.isEmpty ||
        // dishPriceController.text.isEmpty ||
        // dishComboPriceController.text.isEmpty ||
        _selectedImageData == null) {
      _showError('Please fill in all details and select an image.');
      return;
    }

    try {
      // Attempt to parse the price and combo price to double
      double.parse(dishPriceController.text);
      double.parse(dishComboPriceController.text);
    } catch (e) {
      // If parsing fails, show an error and return
      _showError('Please fill in price details in numbers only.');
      return;
    }

    final selectedAllergenList = selectedAllergens.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Check for invalid tag combinations
    List<String> selectedTags = getSelectedTags();
    if (selectedTags.contains('Vegetarian') && selectedTags.contains('Vegan')) {
      _showError('A dish cannot be both Vegetarian and Vegan.');
      return;
    }
    if (selectedTags.contains('Vegetarian') && selectedTags.contains('Meat')) {
      _showError('A dish cannot be both Vegetarian and Meat.');
      return;
    }
    if (selectedTags.contains('Vegan') && selectedTags.contains('Meat')) {
      _showError('A dish cannot be both Vegan and Meat.');
      return;
    }

    if (selectedTags.isEmpty) {
      _showError('Please select at least one tag.');
      return;
    }

    // Check if at least one allergen is selected
    if (selectedAllergenList.isEmpty) {
      _showError('Please select at least one allergen.');
      return;
    }

    final List<String> selectedDishDatesList =
        _dateAvailability == DateAvailability.everyDay
            ? ["Everyday"]
            : selectedDishDates
                .map((date) => DateFormat('EEEE - dd-MM').format(date))
                .toList();

    final dish = Dish(
      name: dishNameController.text,
      description: dishDescriptionController.text,
      price: double.parse(dishPriceController.text),
      typeOfDish: dishTypeValue,
      assignTags: selectedTags,
      comboWithAnotherDish: combowithAnotherDishValue,
      comboPrice: double.parse(dishComboPriceController.text),
      dishImage: base64Encode(
          _selectedImageData!), // Use encoded image for local preview
      imageData: _selectedImageData!, // Store original image data
      dateAvailability: selectedDishDatesList,
      allergens: selectedAllergenList, // Include the allergen data
    );

    // Check if the dish already exists in Firestore
    bool dishExists = await checkDishExists(dish);

    if (dishExists) {
      _showError('Dish with the same name and price already exists.');
    } else {
      setState(() {
        dishes.add(dish); // Add dish locally
        _selectedImageData = null;
        selectedFile = null;
        // Reset data availability
        _dateAvailability =
            DateAvailability.everyDay; // or another default value
        isSelected = List.generate(7, (_) => false); // Reset all days to false
      });

      // Clear the form fields and update the UI as needed
      dishNameController.clear();
      dishDescriptionController.clear();
      dishPriceController.clear();
      dishComboPriceController.clear();
      selectedAllergens.updateAll((key, value) => false);
      selectedDishDates.clear();
      // options.clear();
    }
  }

  Future<bool> checkDishExists(Dish dish) async {
    if (widget.userDocId == null) return false;

    DocumentReference restaurantDoc = FirebaseFirestore.instance
        .collection('Restaurants')
        .doc(widget.userDocId);

    DocumentSnapshot docSnapshot = await restaurantDoc.get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      return false;
    }

    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    if (data.containsKey('dishes')) {
      for (var existingDish in data['dishes'].values) {
        if (globals.capitalizeEachWord(existingDish['name']) ==
                globals.capitalizeEachWord(dish.name) &&
            existingDish['price'] == dish.price) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                    size: 23,
                    text: "Menu Upload",
                    align: TextAlign.start,
                    fontWeight: FontWeight.w600,
                    textColor: blackColor),
                const CustomText(
                    size: 18,
                    text:
                        "Upload your dishes, set your prices and availability",
                    align: TextAlign.start,
                    fontWeight: FontWeight.w400,
                    textColor: blackColor),
                const Gap(40),
                const CustomText(
                  size: 20,
                  text: 'Upload a Dish',
                  fontWeight: FontWeight.bold,
                  textColor: blackColor,
                ),
                const Gap(10),

                // Add dish image under 'Upload a Dish'
                dishes.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            size: 16,
                            text: 'You added Dishe(s)',
                            fontWeight: FontWeight.bold,
                            textColor: blackColor,
                          ),
                          const Gap(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: dishes
                                .map((e) => Container(
                                      margin: const EdgeInsets.all(
                                          10), // Provides spacing around the card
                                      child: Card(
                                        elevation: 1,
                                        child: IntrinsicWidth(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.memory(
                                                    base64Decode(e.dishImage),
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      10), // Space between image and text
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(e.name,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(e.description),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  setState(() {
                                                    dishes.remove(
                                                        e); // Removes the dish from the list
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          )
                        ],
                      )
                    : const SizedBox(),
                const Gap(10),
                Container(
                  decoration: BoxDecoration(
                    color: lightBlue2,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: size.width * 0.45,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomText(
                                    size: 16,
                                    text: "Name of the Dish",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                CustomTextField(
                                  labelText:
                                      'Enter the name of the Dish you want to upload.',
                                  controller: dishNameController,
                                  enabled: true,
                                  maxlines: 1,
                                  borderRadius: 10.0,
                                  maxlen: 80,
                                  keyboardType: TextInputType.text,
                                ),
                                const Gap(20),
                                const CustomText(
                                    size: 16,
                                    text: "Description",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                CustomTextField(
                                  labelText:
                                      'Enter a brief description about your Dish.',
                                  controller: dishDescriptionController,
                                  enabled: true,
                                  maxlines: 3,
                                  borderRadius: 10.0,
                                  maxlen: 100,
                                  keyboardType: TextInputType.text,
                                ),
                                const Gap(20),
                                const CustomText(
                                    size: 16,
                                    text: "Price in £",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                CustomTextField(
                                  labelText: 'Price of the Dish in £',
                                  controller: dishPriceController,
                                  enabled: true,
                                  maxlines: 1,
                                  borderRadius: 10.0,
                                  maxlen: 4,
                                  keyboardType: TextInputType.number,
                                ),
                                const Gap(20),
                                const CustomText(
                                    size: 16,
                                    text: "Type of Dish",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: dishTypeValue.keys.firstWhere(
                                          (k) => dishTypeValue[k] == true),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          if (newValue != null) {
                                            dishTypeValue.updateAll(
                                                (key, value) =>
                                                    dishTypeValue[key] =
                                                        (key == newValue));
                                          }
                                        });
                                      },
                                      items: <String>['Main', 'Extra']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),

                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 10.0),
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(20),
                                //     border: Border.all(
                                //       color: Colors.grey,
                                //       width: 1.0,
                                //     ),
                                //   ),
                                //   child: DropdownButtonHideUnderline(
                                //     child: DropdownButton<String>(
                                //       isExpanded: true,
                                //       value: dishTypeValue,
                                //       onChanged: (String? newValue) {
                                //         setState(() {
                                //           dishTypeValue = newValue!;
                                //         });
                                //       },
                                //       items: <String>[
                                //         'Main',
                                //         'Extra',
                                //       ].map<DropdownMenuItem<String>>(
                                //           (String value) {
                                //         return DropdownMenuItem<String>(
                                //           value: value,
                                //           child: Text(value),
                                //         );
                                //       }).toList(),
                                //     ),
                                //   ),
                                // ),
                                const Gap(20),
                                const CustomText(
                                    size: 16,
                                    text: "Assign Tags",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                SizedBox(
                                  height: 300,
                                  child: ListView.builder(
                                    itemCount: options.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return CheckboxListTile(
                                        activeColor: lightBlue,
                                        title: Text(options[index]),
                                        value: isTagSelected[index],
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isTagSelected[index] = value!;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const Gap(20),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.35,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomText(
                                    size: 16,
                                    text: "Combo with Another Dish",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: combowithAnotherDishValue,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          combowithAnotherDishValue = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        '01',
                                        '02',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                const Gap(20),
                                const CustomText(
                                    size: 16,
                                    text: "Combo Price in £",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                CustomTextField(
                                  labelText: 'Price of the Combo in £',
                                  controller: dishComboPriceController,
                                  enabled: true,
                                  maxlines: 1,
                                  borderRadius: 10.0,
                                  maxlen: 4,
                                  keyboardType: TextInputType.number,
                                ),
                                const Gap(20),
                                const CustomText(
                                    size: 16,
                                    text: "Dish Image",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                if (_selectedImageData != null &&
                                    _selectedImageData!.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    height: 100,
                                    width: 100,
                                    child: Image.memory(
                                      _selectedImageData!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  child: Text(selectedFile != null
                                      ? 'Change Image'
                                      : 'Select Image'),
                                ),
                                const Gap(15),
                                Divider(
                                  color: greyColor.withOpacity(0.5),
                                ),
                                const Gap(20),
                                const CustomText(
                                    size: 16,
                                    text: "Date Availability",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                buildOptionforDateAvail('Selected Days',
                                    DateAvailability.selectedDays),
                                _dateAvailability ==
                                        DateAvailability.selectedDays
                                    ? buildOptionForDateAvailability()
                                    : const SizedBox(),
                                const Gap(5),
                                buildOptionforDateAvail(
                                    'Every Day', DateAvailability.everyDay),
                                const Gap(20),
                                const CustomText(
                                  size: 16,
                                  text: "Allergens",
                                  align: TextAlign.start,
                                  fontWeight: FontWeight.w500,
                                  textColor: blackColor,
                                ),
                                const Gap(5),
                                Column(
                                  children: allergens.map((allergen) {
                                    return CheckboxListTile(
                                      title: Text(allergen),
                                      value: selectedAllergens[allergen],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          selectedAllergens[allergen] = value!;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                const Gap(20),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      CustomButton(
                        text: 'Add a Dish',
                        onPressed: _addDishLocally,
                        width: 140,
                        color: lightBlue,
                      ),
                      // Add dish image under 'Add a Dish'
                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   itemCount: dishes.length,
                      //   itemBuilder: (context, index) {
                      //     Dish dish = dishes[index];
                      //     return ListTile(
                      //       title: Text(dish.name),
                      //       subtitle: Text(dish.description),
                      //       leading: Image.memory(base64Decode(dish.dishImage)),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
                const Gap(25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: size.width * 0.45,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            title: const Text(
                                'Do you offer subscription service?'),
                            value: isSubscriptionService,
                            onChanged: (bool? value) {
                              setState(() {
                                isSubscriptionService = value!;
                              });
                            },
                          ),
                          const Gap(20),
                          Divider(
                            color: greyColor.withOpacity(0.5),
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Promotion Campaign",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const CustomText(
                              size: 14,
                              text:
                                  "Add discounts onto any of your dishes for a limited time",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w400,
                              textColor: blackColor),
                          const Gap(5),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: lightBlue2,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomText(
                                    size: 16,
                                    text: "Dish Number",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                CustomTextField(
                                  labelText: 'Enter the Dish Number',
                                  controller: TextEditingController(),
                                  enabled: true,
                                  maxlines: 1,
                                  borderRadius: 10.0,
                                  maxlen: 10,
                                  keyboardType: TextInputType.number,
                                ),
                                const Gap(10),
                                const CustomText(
                                    size: 16,
                                    text: "% Off",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                CustomDisTextField(
                                  labelText: 'Offer ammount in %',
                                  controller: TextEditingController(),
                                  enabled: true,
                                  maxlines: 1,
                                  borderRadius: 10.0,
                                  maxlen: 2,
                                  keyboardType: TextInputType.number,
                                ),
                                const Gap(10),
                                const CustomText(
                                    size: 16,
                                    text: "Number of Days",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                CustomTextField(
                                  labelText:
                                      'How many days the offer will last?',
                                  controller: TextEditingController(),
                                  enabled: true,
                                  maxlines: 1,
                                  borderRadius: 10.0,
                                  maxlen: 2,
                                  keyboardType: TextInputType.number,
                                ),
                                const Gap(5),
                                CustomButton(
                                  text: 'Add Promotion',
                                  onPressed: () {},
                                  width: 140,
                                  color: lightBlue,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              size: 16,
                              text: "Does anything come included with a main?",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: '',
                            controller: includeWithMainDetailController,
                            enabled: true,
                            maxlines: 3,
                            borderRadius: 10.0,
                            maxlen: 50,
                            keyboardType: TextInputType.number,
                          ),
                          const Gap(15),
                          Divider(
                            color: greyColor.withOpacity(0.5),
                          ),
                          const Gap(15),
                          const CustomText(
                              size: 16,
                              text: "Do you offer",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          buildOptionforDelivery(
                              'Free Delivery', DeliveryFee.freeDelivery),
                          const Gap(5),
                          buildOptionforDelivery(
                              'Minimum order spend for free delivery',
                              DeliveryFee.minimumOrderForFreeDelivery),
                          const Gap(20),
                          Divider(
                            color: greyColor.withOpacity(0.5),
                          ),
                          const Gap(20),
                          //offers handeling

                          const CustomText(
                            size: 16,
                            text: 'If the customer orders',
                            fontWeight: FontWeight.w500,
                            textColor: blackColor,
                          ),
                          const Gap(5),
                          offers.isNotEmpty
                              ? offerListingWidget()
                              : const SizedBox(),
                          const Gap(5),
                          CustomButton(
                            text: 'Add more',
                            onPressed: () {
                              showOrderMoreDiscountDialog(
                                () {
                                  if (mealsForWeekController.text.isEmpty ||
                                      weekController.text.isEmpty ||
                                      offPresentageController.text.isEmpty) {
                                    return;
                                  }
                                  setState(() {
                                    offers.add(
                                      Offer(
                                        mealsForWeek:
                                            mealsForWeekController.text,
                                        week: weekController.text,
                                        offPresentage: double.parse(
                                            offPresentageController.text),
                                      ),
                                    );
                                  });

                                  mealsForWeekController.clear();
                                  weekController.clear();
                                  offPresentageController.clear();
                                  Navigator.pop(context);
                                },
                              );
                            },
                            width: 140,
                            color: lightBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Divider(
                  color: greyColor.withOpacity(0.5),
                ),
                const Gap(20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomButton(
                    text: 'Save Changes',
                    onPressed: () async {
                      // Get the current time
                      DateTime now = DateTime.now();

                      // Check if today is Sunday and the current time is between 3 PM and 5 PM
                      bool isSunday = now.weekday == DateTime.sunday;
                      bool isBetween3And5PM = (now.hour >= 1 && now.hour < 23);

                      // if (!(isSunday && isBetween3And5PM)) {
                      //   ScaffoldMessenger.of(context)
                      //       .showSnackBar(const SnackBar(
                      //     content: Text(
                      //         "You can only upload menus on Sundays between 3 PM and 5 PM"),
                      //     backgroundColor: Colors.red,
                      //   ));
                      //   return; // Exit the function if it's not the allowed time
                      // }
                      if (dishes.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              "Please add at least one dish to save changes."),
                          backgroundColor: Colors.red,
                        ));
                      } else {
                        await uploadDishesToFirestore();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Dishes uploaded successfully"),
                                backgroundColor: Colors.green));
                      }
                    },
                    width: 140,
                    color: lightBlue,
                  ),
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> getSelectedTags() {
    List<String> selectedTags = [];
    for (int i = 0; i < isTagSelected.length; i++) {
      if (isTagSelected[i]) {
        selectedTags.add(options[i]);
      }
    }
    return selectedTags;
  }

  Future showOrderMoreDiscountDialog(void Function() function) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomText(
                    size: 17, fontWeight: FontWeight.w600, text: "Meals :"),
                CustomTextField(
                  labelText: 'Enter the number of meals',
                  controller: mealsForWeekController,
                  enabled: true,
                  maxlines: 1,
                  borderRadius: 10.0,
                  maxlen: 2,
                  keyboardType: TextInputType.number,
                ),
                const Gap(10),
                const CustomText(
                    size: 17, fontWeight: FontWeight.w600, text: "Weeks :"),
                CustomTextField(
                  labelText: 'Enter the number of weeks',
                  controller: weekController,
                  enabled: true,
                  maxlines: 1,
                  borderRadius: 10.0,
                  maxlen: 2,
                  keyboardType: TextInputType.number,
                ),
                const Gap(10),
                const CustomText(
                    size: 17, fontWeight: FontWeight.w600, text: "Off :"),
                CustomDisTextField(
                  labelText: 'Enter the discount percentage',
                  controller: offPresentageController,
                  enabled: true,
                  maxlines: 1,
                  borderRadius: 10.0,
                  maxlen: 2,
                  keyboardType: TextInputType.number,
                ),
                CustomButton(
                  text: 'Add ',
                  onPressed: function,
                  color: lightBlue,
                ),
                const Gap(10),
                CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Close'),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> addDishToFirestore(List<Dish> dishes, String? userDocId) async {
  if (userDocId == null) {
    print('No user document ID provided');
    return;
  }

  DocumentReference restaurantDoc =
      FirebaseFirestore.instance.collection('Restaurants').doc(userDocId);

  // Check if the document exists
  DocumentSnapshot docSnapshot = await restaurantDoc.get();
  if (!docSnapshot.exists) {
    // Create the document with the basic structure if it doesn't exist
    await restaurantDoc.set({});
  }

  // Prepare the data structure for Firestore
  Map<String, Map<String, dynamic>> dishMaps = {
    for (Dish dish in dishes) dish.name: dish.toFirestoreMap()
  };

  // Update the document with the dishes data
  await restaurantDoc.update({'dishes': dishMaps});

  print('Updating restaurant with ID: $userDocId');
}

Future<void> addDishToExistingRestaurant(
    String restaurantDocId, Dish dish) async {
  DocumentReference restaurantDoc =
      FirebaseFirestore.instance.collection('Restaurants').doc(restaurantDocId);

  await restaurantDoc.update({
    'meals': FieldValue.arrayUnion([dish.toFirestoreMap()])
  });
}

Map<String, bool> getAvailabilityMap(
    DateAvailability availability, List<bool> selectedDays) {
  if (availability == DateAvailability.everyDay) {
    return {
      'Mon': true,
      'Tue': true,
      'Wed': true,
      'Thu': true,
      'Fri': true,
      'Sat': true,
      'Sun': true,
    };
  }

  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  Map<String, bool> availabilityMap = {};

  for (int i = 0; i < days.length; i++) {
    availabilityMap[days[i]] = selectedDays[i];
  }

  return availabilityMap;
}

enum DateAvailability { everyDay, selectedDays }

enum DeliveryFee { freeDelivery, minimumOrderForFreeDelivery }
