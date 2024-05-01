import 'dart:convert';
import 'dart:html' as html;
import 'dart:html';
import 'dart:typed_data';
import 'package:csv/csv.dart';

import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/models/dish.dart';
import 'package:adminpanelweb/models/offer.dart';
import 'package:adminpanelweb/widgets/customText.dart';
import 'package:adminpanelweb/widgets/custom_btn.dart';
import 'package:adminpanelweb/widgets/custom_dis_textfield.dart';
import 'package:adminpanelweb/widgets/custom_showDialog.dart';
import 'package:adminpanelweb/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuUploadScreen extends StatefulWidget {
  final String? userDocId;

  const MenuUploadScreen({Key? key, this.userDocId}) : super(key: key);

  @override
  State<MenuUploadScreen> createState() => _MenuUploadScreenState();
}

class _MenuUploadScreenState extends State<MenuUploadScreen> {
  bool isSubscriptionService = false;
  String dishTypeValue = 'Main';
  String combowithAnotherDishValue = '01';
  List<bool> isSelected = List.generate(7, (_) => false);
  List<Dish> dishes = [];
  List<Offer> offers = [];
  String? currentRestaurantDocId;

  List<String> options = [
    'Vegetarian',
    'Vegan',
    'Jain',
    'No Onion/ Garlic',
    'High Protien'
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
                  icon: Icon(Icons.delete),
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

  //pick image
  Uint8List? _pickedImage;

  void _pickImage() {
    final InputElement input = document.createElement('input') as InputElement;

    input
      ..type = 'file'
      ..accept = 'image/*';

    input.onChange.listen((event) {
      final File file = input.files!.first;
      final FileReader reader = FileReader();

      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        setState(() {
          _pickedImage =
              base64.decode(reader.result!.toString().split(",").last);
        });
      });
    });

    input.click();
  }

  void addDishToLocalList(Dish dish) {
    setState(() {
      dishes.add(dish);
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> uploadDishesToFirestore() async {
      // Proceed with uploading the dishes
      if (widget.userDocId == null) {
        print('No user document ID provided');
        return;
      }

      DocumentReference restaurantDoc = FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(widget.userDocId);

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

      print('Updating restaurant with ID: ${widget.userDocId}');

      // Clear the local dishes list after uploading
      setState(() {
        dishes.clear();
      });
    }

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
                dishes.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const CustomText(
                            size: 16,
                            text: 'You added Dishes',
                            fontWeight: FontWeight.bold,
                            textColor: blackColor,
                          ),
                          const Gap(10),
                          Column(
                            children: dishes
                                .map((e) => ListTile(
                                      title: Text(e.name),
                                      subtitle: Text(e.description),
                                      //show dish image
                                      leading: Image.memory(
                                          base64Decode(e.dishImage)),
                                    ))
                                .toList(),
                          ),
                        ],
                      )
                    : const SizedBox(),
                const Gap(10),
                Container(
                  decoration: BoxDecoration(
                    color: lightBlue2,
                    // border: Border.all(
                    //   color: blackColor,
                    //   width: 1,
                    // ),
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
                                  maxlen: 250,
                                  keyboardType: TextInputType.text,
                                ),
                                const Gap(20),
                                const CustomText(
                                    size: 16,
                                    text: "Price",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                CustomTextField(
                                  labelText: 'Price of the Dish in INR',
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
                                      value: dishTypeValue,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dishTypeValue = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        'Main',
                                        'Extra',
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
                                    text: "Assign Tags",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                const Gap(5),
                                Container(
                                  height: 250,
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
                                    text: "Combo Price",
                                    align: TextAlign.start,
                                    fontWeight: FontWeight.w500,
                                    textColor: blackColor),
                                Gap(5),
                                CustomTextField(
                                  labelText: 'Price of the Combo in INR',
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
                                if (_pickedImage != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    height: 100,
                                    width: 100,
                                    child: Image.memory(
                                      _pickedImage!,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  child: Text(_pickedImage != null
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
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Gap(15),
                                          ToggleButtons(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            children: const [
                                              Text('Mon'),
                                              Text('Tue'),
                                              Text('Wed'),
                                              Text('Thu'),
                                              Text('Fri'),
                                              Text('Sat'),
                                              Text('Sun'),
                                            ],
                                            onPressed: (int index) {
                                              setState(() {
                                                isSelected[index] =
                                                    !isSelected[index];
                                              });
                                            },
                                            isSelected: isSelected,
                                          ),
                                          const Gap(20),
                                        ],
                                      )
                                    : const SizedBox(),
                                const Gap(5),
                                buildOptionforDateAvail(
                                    'Every Day', DateAvailability.everyDay),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      CustomButton(
                        text: 'Add a Dish',
                        onPressed: () {
                          if (dishNameController.text.isEmpty ||
                              dishDescriptionController.text.isEmpty ||
                              dishPriceController.text.isEmpty ||
                              dishComboPriceController.text.isEmpty ||
                              _pickedImage == null) {
                            uploadedDishValidateErrorDialog(context);
                            return;
                          }

                          Dish newDish = Dish(
                            name: dishNameController.text,
                            description: dishDescriptionController.text,
                            price: double.parse(dishPriceController.text),
                            typeOfDish: dishTypeValue,
                            assignTags: getSelectedTags(),
                            comboWithAnotherDish: combowithAnotherDishValue,
                            comboPrice:
                                double.parse(dishComboPriceController.text),
                            dishImage: base64.encode(_pickedImage!),
                            dateAvailability: getAvailabilityMap(
                                _dateAvailability, isSelected),
                          );

                          // Add the dish to the local list
                          addDishToLocalList(newDish);

                          // Clear the form fields and update the UI as needed
                          setState(() {
                            dishNameController.clear();
                            dishDescriptionController.clear();
                            dishPriceController.clear();
                            dishComboPriceController.clear();
                            _pickedImage = null;
                            isSelected = List.generate(7, (index) => false);
                          });

                          // Optionally, show a dialog or a snackbar to inform the user of success
                        },
                        width: 140,
                        color: lightBlue,
                      ),
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
                      bool isSunday = now.weekday == DateTime.wednesday;
                      bool isBetween3And5PM = (now.hour >= 6 && now.hour < 23);

                      if (!(isSunday && isBetween3And5PM)) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              "You can only upload menus on Sundays between 3 PM and 5 PM"),
                          backgroundColor: Colors.red,
                        ));
                        return; // Exit the function if it's not the allowed time
                      }

                      // Call upload function if the conditions are met
                      await uploadDishesToFirestore();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Dishes uploaded successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
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
            padding: EdgeInsets.all(20.0),
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

  void downloadCSV() {
    List<List<dynamic>> rows = [];

    rows.add(['-- Menu Upload --', '', '', '']);
    rows.add(['']);

    rows.add(['-> Uploaded Dishes', '', '', '']);
    rows.add(['']);
    if (dishes.isEmpty) {
      rows.add(['No Dishes Uploaded']);
    } else {
      rows.add([
        'No.',
        'Name',
        'Description',
        'Price',
        'Type of Dish',
        'Assign Tag',
        'Combo with another Dish',
        'Combo Price',
        'Dish Image',
        'Date Availability',
      ]);
    }

    for (int i = 0; i < dishes.length; i++) {
      var dishDateAval = 'Everyday';
      if (dishes[i].dateAvailability == DateAvailability.selectedDays) {
        dishDateAval = 'Selected Days';
      }
      rows.add([
        "${(i + 1)}). ",
        dishes[i].name,
        dishes[i].description,
        dishes[i].price,
        dishes[i].typeOfDish,
        dishes[i].assignTags,
        dishes[i].comboWithAnotherDish,
        dishes[i].comboPrice,
        'true',
        dishDateAval,
      ]);
    }
    rows.add(['']);

    var isSubscriptionServiceString = 'No';
    var deliveryFees = 'Free Delivery';
    if (isSubscriptionService) {
      isSubscriptionServiceString = 'Yes';
    }

    if (_deliveryFee == DeliveryFee.minimumOrderForFreeDelivery) {
      deliveryFees = 'Minimum order spend for free delivery';
    }

    rows.add([
      'Do you offer subscription service?',
      '',
      '',
      isSubscriptionServiceString
    ]);
    rows.add([
      'Does anything come included with a main?',
      '',
      '',
      includeWithMainDetailController.text
    ]);
    rows.add(['Do you offer', '', '', deliveryFees]);
    rows.add(['']);
    rows.add(['-> Promotion Campaign', '', '', '']);
    rows.add(['-']);
    rows.add(['']);
    rows.add(['-> Offers', '', '', '']);
    rows.add(['']);

    if (offers.isEmpty) {
      rows.add(['No Offers Uploaded']);
    } else {
      rows.add(['No.', 'Dish Number', '% Off', 'Number of Days']);
    }
    for (int i = 0; i < offers.length; i++) {
      rows.add([
        "${(i + 1)}). ",
        offers[i].mealsForWeek,
        offers[i].week,
        offers[i].offPresentage,
      ]);
    }
    rows.add(['']);

    String csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'uploaded_menu.csv';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
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
