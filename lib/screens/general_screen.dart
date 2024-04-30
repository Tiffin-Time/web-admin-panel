import 'dart:convert';
import 'dart:html' as html;
import 'dart:html';
import 'dart:typed_data';

import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/widgets/customText.dart';
import 'package:adminpanelweb/widgets/custom_btn.dart';
import 'package:adminpanelweb/widgets/custom_textfield.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker_web/image_picker_web.dart';

enum DeliveryOption { collect, collectAndDelivery }

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({Key? key}) : super(key: key);

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  DeliveryOption _deliveryOption = DeliveryOption.collect;
  List<bool> isSelected = List.generate(7, (_) => false);
  TimeOfDay selectedTime = TimeOfDay.now();
  String dropdownValue = 'Option 1';

  final TextEditingController aboutUsController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController tiffinTypeController = TextEditingController();
  final TextEditingController peopleController = TextEditingController();
  final TextEditingController orderSpendController = TextEditingController();
  final TextEditingController noticeController = TextEditingController();
  final TextEditingController collectionRadiusController =
      TextEditingController();
  final TextEditingController deliveryRadiusController =
      TextEditingController();
  final TextEditingController deliveryChargeController =
      TextEditingController();
  final TextEditingController minOrderSpendController = TextEditingController();
  final TextEditingController daysNoticeController = TextEditingController();

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

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
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
    deliveryRadiusController.dispose();
    deliveryChargeController.dispose();
    minOrderSpendController.dispose();
    daysNoticeController.dispose();
    super.dispose();
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
                            children: const <Widget>[
                              Text('Mon'),
                              Text('Tue'),
                              Text('Wed'),
                              Text('Thu'),
                              Text('Fri'),
                              Text('Sat'),
                              Text('Sun'),
                            ],
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
                                        maxlen: 3,
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
                                        maxlen: 2,
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
                                        maxlen: 3,
                                        keyboardType: TextInputType.number,
                                      ),
                                      const Gap(20),
                                      const CustomText(
                                          size: 16,
                                          text: "Delivery Charge",
                                          align: TextAlign.start,
                                          fontWeight: FontWeight.w500,
                                          textColor: blackColor),
                                      const Gap(5),
                                      CustomTextField(
                                        labelText: 'Enter Price',
                                        controller: deliveryChargeController,
                                        enabled: true,
                                        maxlines: 1,
                                        borderRadius: 10.0,
                                        maxlen: 3,
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
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              const TableRow(
                                children: [
                                  Text('Times for:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  CustomText(
                                    size: 14,
                                    text: 'Collection',
                                    align: TextAlign.start,
                                  ),
                                  CustomText(
                                    size: 14,
                                    text: 'Delivery',
                                    align: TextAlign.start,
                                  ),
                                  CustomText(
                                    size: 14,
                                    text: 'Max People Per Hour',
                                    align: TextAlign.start,
                                  ),
                                ],
                              ),
                              ...daysOfWeek.map((day) {
                                return TableRow(
                                  children: [
                                    Text(day),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: GestureDetector(
                                          onTap: () =>
                                              selectTime(context, day, true),
                                          child: CustomText(
                                            size: 14,
                                            textColor: lightBlue,
                                            text: collectionTimes[day]
                                                    ?.format(context) ??
                                                'Select Time',
                                            align: TextAlign.start,
                                          ),
                                        )),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: GestureDetector(
                                          onTap: () =>
                                              selectTime(context, day, false),
                                          child: CustomText(
                                            size: 14,
                                            textColor: lightBlue,
                                            text: deliveryTimes[day]
                                                    ?.format(context) ??
                                                'Select Time',
                                            align: TextAlign.start,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 45,
                                      child: TextField(
                                        onChanged: (value) {
                                          maxPeoplePerHour[day] = value;
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
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
                              text: "Address:",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: 'Address (including Postal Code)',
                            controller: addressController,
                            enabled: true,
                            maxlines: 4,
                            borderRadius: 10.0,
                            maxlen: 200,
                            keyboardType: TextInputType.text,
                          ),
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
                            maxlen: 10,
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
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
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
                                value: dropdownValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Option 1',
                                  'Option 2',
                                  'Option 3',
                                  'Option 4'
                                ].map<DropdownMenuItem<String>>((String value) {
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
                            maxlen: 2,
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
                    onPressed: downloadCSV,
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

  void downloadCSV() {
    List<List<dynamic>> rows = [];

    rows.add(['General Information']);
    rows.add(['']);
    rows.add(['']);

    rows.add(['About us', '', '', aboutUsController.text]);
    rows.add(['Address', '', '', addressController.text]);
    rows.add(['Phone Number', '', '', phoneNumberController.text]);
    List<String> row = ['Days you are open', '', ''];
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i]) {
        row.add(daysOfWeek[i]);
      }
    }

    rows.add(row);
    rows.add(['Tiffin Type Provided', '', '', dropdownValue]);
    rows.add(['Card Image Selection', '', '', 'true']);
    rows.add(['People', '', '', peopleController.text]);
    rows.add(['Order Spend', '', '', orderSpendController.text]);
    rows.add(['Notice', '', '', noticeController.text]);
    rows.add(['Collection Radius', '', '', collectionRadiusController.text]);
    rows.add(['Delivery Radius', '', '', deliveryRadiusController.text]);
    rows.add(['Delivery Charge', '', '', deliveryChargeController.text]);
    rows.add(['Min Order Spend', '', '', minOrderSpendController.text]);
    rows.add(['Days Notice', '', '', daysNoticeController.text]);
    rows.add(['']);
    rows.add(['']);

    // Add header to rows
    rows.add(['', 'Collection', 'Delivery', 'Max people per hour']);

    // Add data to rows
    for (String day in daysOfWeek) {
      List<dynamic> row = [];
      row.add(day);
      row.add(collectionTimes[day]?.format(context) ?? 'N/A');
      row.add(deliveryTimes[day]?.format(context) ?? 'N/A');
      row.add(maxPeoplePerHour[day] ?? 'N/A');
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'general_information.csv';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

//
//
//
}
