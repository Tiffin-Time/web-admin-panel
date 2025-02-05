// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:html';
import 'dart:typed_data';
// import 'package:intl/intl.dart';

import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/widgets/custom_text.dart';
import 'package:adminpanelweb/widgets/custom_btn.dart';
import 'package:adminpanelweb/widgets/custom_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

enum DeliveryOption { collect, collectAndDelivery }

class GeneralScreen extends StatefulWidget {
  final String? userDocId;

  const GeneralScreen({Key? key, this.userDocId}) : super(key: key);

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  DeliveryOption _deliveryOption = DeliveryOption.collect;
  List<bool> isSelected = List.generate(7, (_) => false);
  List<bool> isSelectedTiffinType = List.generate(3, (_) => false);
  TimeOfDay selectedTime = TimeOfDay.now();
  String dropdownValue = 'Tiffin-Veg';

  final TextEditingController aboutUsController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController tiffinTypeController = TextEditingController();
  final TextEditingController peopleController = TextEditingController();
  final TextEditingController orderSpendController = TextEditingController();
  final TextEditingController noticeController = TextEditingController();
  final TextEditingController collectionRadiusController =
      TextEditingController();
  final TextEditingController collectionDeliveryRadiusController =
      TextEditingController();
  final TextEditingController deliveryRadiusController =
      TextEditingController();
  final TextEditingController deliveryChargeController =
      TextEditingController();
  final TextEditingController minOrderSpendController = TextEditingController();
  final TextEditingController daysNoticeController = TextEditingController();
  final TextEditingController addressFirstLineController =
      TextEditingController();
  final TextEditingController addressPostCodeController =
      TextEditingController();
  final TextEditingController addressCountryController =
      TextEditingController();
  final TextEditingController addressCityController = TextEditingController();

  Widget buildOption(String title, DeliveryOption value) {
    bool isSelected = _deliveryOption == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _deliveryOption = value;
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

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
            size: 16,
            text: "Address Details:",
            align: TextAlign.start,
            fontWeight: FontWeight.w500,
            textColor: blackColor),
        const Gap(5),
        CustomTextField(
          labelText: 'First Line of Address',
          controller: addressFirstLineController,
          enabled: true,
          maxlines: 1,
          borderRadius: 10.0,
          keyboardType: TextInputType.text,
        ),
        CustomTextField(
          labelText: 'Postcode',
          controller: addressPostCodeController,
          enabled: true,
          maxlines: 1,
          borderRadius: 10.0,
          keyboardType: TextInputType.text,
        ),
        CustomTextField(
          labelText: 'City',
          controller: addressCityController,
          enabled: true,
          maxlines: 1,
          borderRadius: 10.0,
          keyboardType: TextInputType.text,
        ),
        CustomTextField(
          labelText: 'Country',
          controller: addressCountryController,
          enabled: true,
          maxlines: 1,
          borderRadius: 10.0,
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  final List<String> daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  final List<String> tiffinType = [
    'Tiffin-Veg',
    'Tiffin-Meat',
    'Tiffin-Vegan',
  ];

  final Map<String, TimeOfDay?> collectionTimes = {};
  final Map<String, TimeOfDay?> deliveryTimes = {};
  final Map<String, String> maxPeoplePerHour = {};

  Future<void> selectTime(
      BuildContext context, String day, bool isCollection) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isCollection) {
          collectionTimes[day] = picked;
        } else {
          deliveryTimes[day] = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    aboutUsController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    tiffinTypeController.dispose();
    peopleController.dispose();
    orderSpendController.dispose();
    noticeController.dispose();
    collectionRadiusController.dispose();
    collectionDeliveryRadiusController.dispose();
    deliveryRadiusController.dispose();
    deliveryChargeController.dispose();
    minOrderSpendController.dispose();
    daysNoticeController.dispose();
    super.dispose();
  }

  //pick image
  Uint8List? _pickedImage;
  // Image upload function

  //UPLOADING IMAGES WITHOUT COMPRESSING THEM
  // Future<String> uploadImage(
  //     Uint8List data, String companyName, String searchKey) async {
  //   // String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  //   final sanitizedCompanyName = companyName.replaceAll(RegExp(r'\W+'), '_');
  //   String storagePath =
  //       'company/images/general_information_images/$searchKey/$sanitizedCompanyName.jpg';

  //   FirebaseStorage storage = FirebaseStorage.instance;
  //   Reference ref = storage.ref().child(storagePath);

  //   TaskSnapshot uploadTask = await ref.putData(data);

  //   return await uploadTask.ref.getDownloadURL();
  // }

//UPLOADING IMAGES WHILE COMPRESSING THEM
  Future<String> uploadImage(
      Uint8List data, String companyName, String searchKey) async {
    // Sanitize the company name for the storage path
    final sanitizedCompanyName = companyName.replaceAll(RegExp(r'\W+'), '_');
    String storagePath =
        'company/images/general_information_images/$searchKey/$sanitizedCompanyName.jpg';

    // Decode the image from the byte data
    img.Image? image = img.decodeImage(data);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize the image to a maximum dimension (e.g., 600x600)
    img.Image resizedImage = img.copyResize(image, width: 600, height: 600);

    // Compress the image to JPEG with 80% quality
    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 80);

    // Convert the compressed bytes to Uint8List
    Uint8List compressedData = Uint8List.fromList(compressedBytes);

    // Upload the compressed image to Firebase Storage
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(storagePath);

    TaskSnapshot uploadTask = await ref.putData(compressedData);

    // Return the download URL of the uploaded image
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> uploadGeneralInfoToFirestore() async {
    if (widget.userDocId == null) {
      _showError('User document ID not provided.');
      return;
    }

    try {
      DocumentReference restaurantDoc = FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(widget.userDocId);

      DocumentSnapshot docSnapshot = await restaurantDoc.get();
      if (!docSnapshot.exists) {
        _showError('Restaurant not found.');
        return;
      }

      String companyName = docSnapshot['companyName'];
      if (companyName.isEmpty) {
        _showError('Company name not found.');
        return;
      }

      // Extract the searchKey from the restaurant data
      String searchKey = docSnapshot['searchKey'];
      if (searchKey.isEmpty) {
        _showError('searchKey not found.');
        return;
      }

      // Upload image and get URL
      String imageUrl = '';
      if (_pickedImage != null) {
        imageUrl = await uploadImage(_pickedImage!, companyName, searchKey);
      }

      // Pair daysOfWeek and isSelected using indices
      List<String> daysOpen = [];
      for (int i = 0; i < daysOfWeek.length; i++) {
        if (isSelected[i]) {
          daysOpen.add(daysOfWeek[i]);
        }
      }

      List<String> tiffinTypeChosen = [];
      for (int i = 0; i < tiffinType.length; i++) {
        if (isSelectedTiffinType[i]) {
          tiffinTypeChosen.add(tiffinType[i]);
        }
      }

      bool isValidPhoneNumber(String input) {
        // This pattern is quite general; you might need a more specific one depending on your needs
        final RegExp phoneRegex = RegExp(r'^\+?(\d[\d -]{7,}\d$)');
        return phoneRegex.hasMatch(input);
      }

      // Validate phone number first
      String phoneNumber = phoneNumberController.text;
      if (!isValidPhoneNumber(phoneNumber)) {
        _showError('Please enter a valid phone number.');
        return;
      }

      Map<String, dynamic> address = {
        'firstLine': addressFirstLineController.text,
        'postcode': addressPostCodeController.text,
        'city': addressCityController.text,
        'country': addressCountryController.text
      };

      Map<String, dynamic> generalInfo = {
        'aboutUs': aboutUsController.text,
        'address': address,
        'phoneNumber': phoneNumber,
        'imageUrl': imageUrl,
        'daysOpen': daysOpen,
        'tiffinType': tiffinTypeChosen,
        'collectionRadius': collectionRadiusController.text,
        'collectionDeliveryRadius': collectionDeliveryRadiusController.text,
        'deliveryRadius': deliveryRadiusController.text,
        'deliveryCharge': deliveryChargeController.text,
        'minOrderSpend': minOrderSpendController.text,
        'orderSpendController': double.parse(orderSpendController.text),
        'daysNotice': int.parse(daysNoticeController.text),
        'peopleController': int.parse(peopleController.text),
        'collectionTimes':
            collectionTimes.map((k, v) => MapEntry(k, v?.format(context))),
        'deliveryTimes':
            deliveryTimes.map((k, v) => MapEntry(k, v?.format(context))),
        'maxPeoplePerHour': maxPeoplePerHour,
      };

      await restaurantDoc
          .set({'generalInformation': generalInfo}, SetOptions(merge: true));

      // await restaurantDoc.update({'generalInformation': generalInfo});

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("General information uploaded successfully"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      _showError('Error uploading general information: ${e.toString()}');
    }
  }

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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
              children: <Widget>[
                const CustomText(
                    size: 23,
                    text: "General Information",
                    align: TextAlign.start,
                    fontWeight: FontWeight.w600,
                    textColor: blackColor),
                const CustomText(
                    size: 18,
                    text:
                        "Please fill in the following information to help us understand your business better. This information will be displayed on your profile page.",
                    align: TextAlign.start,
                    fontWeight: FontWeight.w400,
                    textColor: blackColor),
                const Gap(40),
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
                              text: "About Us:",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(10),
                          CustomTextField(
                            labelText:
                                'Write a short description about your tiffins/who you are to be seen by customers on home screen.',
                            controller: aboutUsController,
                            enabled: true,
                            maxlines: 3,
                            borderRadius: 10.0,
                            maxlen: 150,
                            keyboardType: TextInputType.text,
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Days you are open:",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(10),
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(30),
                            onPressed: (int index) {
                              setState(() {
                                isSelected[index] = !isSelected[index];
                              });
                            },
                            isSelected: isSelected,
                            color: Colors.black,
                            selectedColor: Colors.white,
                            fillColor: lightBlue,
                            children: List<Widget>.generate(daysOfWeek.length,
                                (index) => Text(daysOfWeek[index])),
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Do you offer delivery:",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(10),
                          buildOption('Collect', DeliveryOption.collect),
                          _deliveryOption == DeliveryOption.collect
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Gap(20),
                                      const CustomText(
                                          size: 16,
                                          text: "Collection Radius (in miles)",
                                          align: TextAlign.start,
                                          fontWeight: FontWeight.w500,
                                          textColor: blackColor),
                                      const Gap(5),
                                      CustomTextField(
                                        labelText: 'Enter Number',
                                        controller: collectionRadiusController,
                                        enabled: true,
                                        maxlines: 1,
                                        borderRadius: 10.0,
                                        maxlen: 5,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 10),
                          buildOption('Collect and Delivery',
                              DeliveryOption.collectAndDelivery),
                          _deliveryOption == DeliveryOption.collectAndDelivery
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Gap(20),
                                      const CustomText(
                                          size: 16,
                                          text:
                                              "Minimum Order spend for delivery",
                                          align: TextAlign.start,
                                          fontWeight: FontWeight.w500,
                                          textColor: blackColor),
                                      const Gap(5),
                                      CustomTextField(
                                        labelText: 'Enter Number',
                                        controller: minOrderSpendController,
                                        enabled: true,
                                        maxlines: 1,
                                        borderRadius: 10.0,
                                        maxlen: 5,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          _deliveryOption == DeliveryOption.collectAndDelivery
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Gap(20),
                                      const CustomText(
                                          size: 16,
                                          text: "Delivery Radius (in miles)",
                                          align: TextAlign.start,
                                          fontWeight: FontWeight.w500,
                                          textColor: blackColor),
                                      const Gap(5),
                                      CustomTextField(
                                        labelText: 'Enter Number',
                                        controller: deliveryRadiusController,
                                        enabled: true,
                                        maxlines: 1,
                                        borderRadius: 10.0,
                                        maxlen: 5,
                                        keyboardType: TextInputType.number,
                                      ),
                                      const Gap(20),
                                      const CustomText(
                                          size: 16,
                                          text: "Collection Radius (in miles)",
                                          align: TextAlign.start,
                                          fontWeight: FontWeight.w500,
                                          textColor: blackColor),
                                      const Gap(5),
                                      CustomTextField(
                                        labelText: 'Enter Number',
                                        controller:
                                            collectionDeliveryRadiusController,
                                        enabled: true,
                                        maxlines: 1,
                                        borderRadius: 10.0,
                                        maxlen: 5,
                                        keyboardType: TextInputType.number,
                                      ),
                                      const Gap(20),
                                      const CustomText(
                                          size: 16,
                                          text: "Delivery Charge in £",
                                          align: TextAlign.start,
                                          fontWeight: FontWeight.w500,
                                          textColor: blackColor),
                                      const Gap(5),
                                      CustomTextField(
                                        labelText: 'Enter Price in £',
                                        controller: deliveryChargeController,
                                        enabled: true,
                                        maxlines: 1,
                                        borderRadius: 10.0,
                                        maxlen: 5,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          const Gap(30),
                          Divider(
                            color: greyColor.withOpacity(0.5),
                          ),
                          const Gap(20),
                          buildTable(),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAddressSection(),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Phone Number:",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: 'Phone Number',
                            controller: phoneNumberController,
                            enabled: true,
                            maxlines: 1,
                            borderRadius: 10.0,
                            maxlen: 11,
                            keyboardType: TextInputType.number,
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Tiffin Type Provided:",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(30),
                            constraints: const BoxConstraints.expand(
                                width: 90, height: 50),
                            onPressed: (int index) {
                              setState(() {
                                isSelectedTiffinType[index] =
                                    !isSelectedTiffinType[index];
                              });
                            },
                            isSelected: isSelectedTiffinType,
                            color: Colors.black,
                            selectedColor: Colors.white,
                            fillColor: lightBlue,
                            children: const <Widget>[
                              Text('Tiffin-Veg'),
                              Text('Tiffin-Vegan'),
                              Text('Tiffin-Meat'),
                            ],
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Card Image Selection:",
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
                          const Gap(15),
                          const CustomText(
                              size: 16,
                              text:
                                  "Maximum Number of people that you can cater for per day:",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: 'Number of People',
                            controller: peopleController,
                            enabled: true,
                            maxlines: 1,
                            borderRadius: 10.0,
                            maxlen: 3,
                            keyboardType: TextInputType.number,
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Minimum Order Spend:",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: 'Enter Value',
                            controller: orderSpendController,
                            enabled: true,
                            maxlines: 1,
                            borderRadius: 10.0,
                            maxlen: 5,
                            keyboardType: TextInputType.number,
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text:
                                  "How many days notice do you need to prepare a meal:",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: 'Enter Value',
                            controller: daysNoticeController,
                            enabled: true,
                            maxlines: 1,
                            borderRadius: 10.0,
                            maxlen: 2,
                            keyboardType: TextInputType.number,
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
                      List<TextEditingController> controllers = [
                        aboutUsController,
                        addressFirstLineController,
                        addressPostCodeController,
                        addressCityController,
                        addressCountryController,
                        phoneNumberController,
                        daysNoticeController,
                        peopleController,
                        orderSpendController,
                      ];

                      List<TextEditingController>
                          collectAndDeliveryControllers = [
                        deliveryRadiusController,
                        deliveryChargeController,
                        minOrderSpendController,
                        collectionDeliveryRadiusController,
                      ];

                      bool isValidNumericInput(String input) {
                        try {
                          double.parse(input);
                          return false;
                        } catch (e) {
                          return true;
                        }
                      }

                      // Check if all delivery fields are empty or all are filled and if they are of type int
                      bool allDeliveryFieldsValid =
                          (collectAndDeliveryControllers.any(
                                    (c) {
                                      try {
                                        double.parse(c.text);
                                        return false;
                                      } catch (e) {
                                        return true;
                                      }
                                    },
                                  ) &&
                                  (_deliveryOption ==
                                      DeliveryOption.collectAndDelivery)) ||
                              (isValidNumericInput(
                                      collectionRadiusController.text) &&
                                  (_deliveryOption == DeliveryOption.collect));

                      // Check if any text field is empty
                      bool anyFieldEmpty =
                          controllers.any((c) => c.text.isEmpty);

                      // Check if no day is selected
                      bool noDaySelected =
                          isSelected.every((element) => !element);

                      // Check if no tiffin type is selected
                      bool noTiffinTypeSelected =
                          isSelectedTiffinType.every((element) => !element);

                      // Check if no image is selected
                      bool noImageSelected = _pickedImage == null;

                      bool validateDayEntries() {
                        bool isValid = true;

                        for (int i = 0; i < daysOfWeek.length; i++) {
                          if (isSelected[i]) {
                            // If the day is selected
                            // Check if times and max people per hour are provided and valid
                            if ((collectionTimes[daysOfWeek[i]] == null &&
                                    _deliveryOption ==
                                        DeliveryOption.collect) ||
                                (deliveryTimes[daysOfWeek[i]] == null &&
                                    _deliveryOption ==
                                        DeliveryOption.collectAndDelivery) ||
                                maxPeoplePerHour[daysOfWeek[i]] == null ||
                                maxPeoplePerHour[daysOfWeek[i]]!.isEmpty ||
                                int.tryParse(
                                        maxPeoplePerHour[daysOfWeek[i]]!) ==
                                    null) {
                              isValid = false;
                              break;
                            }
                          }
                        }

                        return isValid;
                      }

                      if (allDeliveryFieldsValid ||
                          anyFieldEmpty ||
                          noDaySelected ||
                          noTiffinTypeSelected ||
                          noImageSelected) {
                        _showError(
                            'Please ensure all fields are filled correctly and selections are made.');
                        return;
                      }

                      if (!validateDayEntries()) {
                        _showError(
                            'Please ensure all times and max people entries are filled out correctly for each active day.');
                        return;
                      }

                      // Proceed to upload information if all validations are passed
                      await uploadGeneralInfoToFirestore();
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

  Widget buildTable() {
    bool showCollection = _deliveryOption == DeliveryOption.collect ||
        _deliveryOption == DeliveryOption.collectAndDelivery;
    bool showDelivery = _deliveryOption == DeliveryOption.collectAndDelivery;
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            const Text('Times for:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (showCollection)
              CustomText(size: 14, text: 'Collection', align: TextAlign.start),
            if (showDelivery)
              CustomText(size: 14, text: 'Delivery', align: TextAlign.start),
            CustomText(
                size: 14, text: 'Max People Per Hour', align: TextAlign.start),
          ],
        ),
        ...daysOfWeek
            .asMap()
            .entries
            .where((entry) => isSelected[entry.key]) // entry.key is the index
            .map(
          (entry) {
            String day = entry.value;
            {
              return TableRow(
                children: [
                  Text(day),
                  if (showCollection)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => selectTime(context, day, true),
                        child: CustomText(
                          size: 14,
                          textColor: lightBlue,
                          text: collectionTimes[day]?.format(context) ??
                              'Select Time',
                          align: TextAlign.start,
                        ),
                      ),
                    ),
                  if (showDelivery)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => selectTime(context, day, false),
                        child: CustomText(
                          size: 14,
                          textColor: lightBlue,
                          text: deliveryTimes[day]?.format(context) ??
                              'Select Time',
                          align: TextAlign.start,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 45,
                    child: TextField(
                      onChanged: (value) => maxPeoplePerHour[day] = value,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                ],
              );
            }
          },
        ).toList(),
      ],
    );
  }
}
