// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/widgets/custom_text.dart';
import 'package:adminpanelweb/widgets/custom_btn.dart';
import 'package:adminpanelweb/widgets/custom_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'dart:convert';
import 'dart:html' as html;
// import 'dart:html';
// import 'dart:typed_data';
import 'package:csv/csv.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For platform checks

class OverviewScreen extends StatefulWidget {
  final String? userDocId;

  const OverviewScreen({Key? key, this.userDocId}) : super(key: key);

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  PlatformFile? _selectedFile;
  List<PlatformFile>? _foodCetificateFile;

  //create textediting controllers
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyNumberController = TextEditingController();
  final TextEditingController niNumberController = TextEditingController();
  final TextEditingController signedContractPdfController =
      TextEditingController();
  final TextEditingController bankDetailsController = TextEditingController();
  final TextEditingController companyAddressController =
      TextEditingController();

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> pickFoodCetificateFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _foodCetificateFile = result.files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                    text: "Register a Company",
                    align: TextAlign.start,
                    fontWeight: FontWeight.w600,
                    textColor: blackColor),
                const CustomText(
                    size: 18,
                    text:
                        "Please fill in the following details to register your company.",
                    align: TextAlign.start,
                    fontWeight: FontWeight.w400,
                    textColor: blackColor),
                const Gap(40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: size.width * 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              size: 16,
                              text: "Company Name",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: 'My Company (PVT) Limitted.',
                            controller: companyNameController,
                            enabled: true,
                            maxlines: 1,
                            borderRadius: 10.0,
                            maxlen: 20,
                            keyboardType: TextInputType.text,
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "NI Number",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: '1234567890',
                            controller: niNumberController,
                            enabled: true,
                            maxlines: 1,
                            borderRadius: 10.0,
                            maxlen: 20,
                            keyboardType: TextInputType.text,
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Signed contract PDF",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(20),
                          if (_selectedFile != null)
                            Column(
                              children: [
                                Row(
                                  children: <Widget>[
                                    const Icon(Icons.picture_as_pdf),
                                    const SizedBox(width: 8),
                                    Text(_selectedFile!.name),
                                  ],
                                ),
                                const Gap(20),
                              ],
                            ),
                          GestureDetector(
                            onTap: () {
                              pickFile();
                            },
                            child: CustomText(
                                size: 14,
                                text:
                                    _selectedFile == null ? "Upload" : "Change",
                                align: TextAlign.start,
                                fontWeight: FontWeight.w500,
                                textColor: lightBlue),
                          ),
                          const Gap(20),
                          Divider(
                            color: greyColor.withOpacity(0.6),
                            thickness: 1,
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Food Safety Certificate",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(20),
                          if (_foodCetificateFile != null)
                            for (var file in _foodCetificateFile!)
                              Column(
                                children: [
                                  Row(
                                    children: <Widget>[
                                      const Icon(Icons.picture_as_pdf),
                                      const SizedBox(width: 8),
                                      Text(file.name),
                                    ],
                                  ),
                                  const Gap(20),
                                ],
                              ),
                          GestureDetector(
                            onTap: () {
                              pickFoodCetificateFile();
                            },
                            child: CustomText(
                                size: 14,
                                text: _foodCetificateFile == null
                                    ? "Upload"
                                    : "Change",
                                align: TextAlign.start,
                                fontWeight: FontWeight.w500,
                                textColor: lightBlue),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              size: 16,
                              text: "Company Number",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: 'My Company (PVT) Limitted.',
                            controller: companyNumberController,
                            enabled: true,
                            maxlines: 1,
                            borderRadius: 10.0,
                            maxlen: 20,
                            keyboardType: TextInputType.text,
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Bank Details",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: '',
                            controller: bankDetailsController,
                            enabled: true,
                            maxlines: 3,
                            borderRadius: 10.0,
                            maxlen: 150,
                            keyboardType: TextInputType.text,
                          ),
                          const Gap(20),
                          const CustomText(
                              size: 16,
                              text: "Company Address",
                              align: TextAlign.start,
                              fontWeight: FontWeight.w500,
                              textColor: blackColor),
                          const Gap(5),
                          CustomTextField(
                            labelText: '',
                            controller: companyAddressController,
                            enabled: true,
                            maxlines: 3,
                            borderRadius: 10.0,
                            maxlen: 150,
                            keyboardType: TextInputType.text,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Divider(
                  color: greyColor.withOpacity(0.6),
                  thickness: 1,
                ),
                const Gap(30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomButton(
                    text: 'Register Company',
                    onPressed:
                        registerCompany, // Call the function to register the company
                    width: 140,
                    color: lightBlue,
                  ),
                ),
                const Gap(30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void downloadCSV() {
    List<List<dynamic>> rows = [];

    rows.add(['Registration Informations']);
    rows.add(['']);

    rows.add(['Name', '', '', companyNameController.text]);
    rows.add(['NI Number', '', '', niNumberController.text]);
    rows.add(['Company Number', '', '', companyNumberController.text]);
    rows.add(['Bank Details', '', '', bankDetailsController.text]);
    rows.add(['Company Address', '', '', companyAddressController.text]);
    rows.add(['Signed Contract PDF', '', '', _selectedFile?.name ?? '']);
    rows.add([
      'Food Safety Certificate',
      '',
      '',
      _foodCetificateFile?.map((e) => e.name).join(', ') ?? ''
    ]);

    String csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'company_reg.csv';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<void> registerCompany() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String companyName = companyNameController.text.trim();
    String niNumber = niNumberController.text.trim();
    String companyNumber = companyNumberController.text.trim();

    // Generate a searchKey by removing non-alphabetic characters and converting to lowercase
    String searchKey = companyName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]+'), ''); // Keep only lowercase letters

    // Check for existing company registration using searchKey
    QuerySnapshot querySnapshot = await firestore
        .collection('Restaurants')
        .where('searchKey', isEqualTo: searchKey)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A company with these details is already registered."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if the company is already registered
    }

    // Proceed with registration and file upload
    try {
      DocumentReference docRef = await firestore.collection('Restaurants').add({
        'companyName': companyName,
        'niNumber': niNumber,
        'companyNumber': companyNumber,
        'bankDetails': bankDetailsController.text,
        'companyAddress': companyAddressController.text,
        'searchKey': searchKey, // Store the searchKey in Firestore
      });

      // Store the generated document ID in the companyCredentials collection
      await firestore.collection('companyCredentials').doc(companyName).set({
        'documentId': docRef.id,
        'searchKey': searchKey // Include searchKey for easier lookup
      });

      // If registration is successful, proceed to upload files
      if (_selectedFile != null) {
        await uploadFileToFirebaseStorage(
            _selectedFile!, 'contracts', companyName);
      }

      if (_foodCetificateFile != null) {
        for (var file in _foodCetificateFile!) {
          await uploadFileToFirebaseStorage(file, 'certificates', companyName);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Company successfully registered and files uploaded!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error during registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to register company. Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Helper function to handle file uploads
  Future<void> uploadFileToFirebaseStorage(
      PlatformFile file, String category, String companyName) async {
    String fileName = file.name;
    String storagePath = 'company/$category/$companyName/$fileName';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(storagePath);

    try {
      if (kIsWeb) {
        // Web platform uses Blob for file uploads
        if (file.bytes != null) {
          html.Blob blob = html.Blob([file.bytes]); // Ensure data is in a list
          await ref.putBlob(blob);
          print('File uploaded to Firebase Storage at path: $storagePath');
        } else {
          print('No file bytes available for upload');
          throw Exception('No file bytes available for upload');
        }
      }
      print('File uploaded to Firebase Storage at path: $storagePath');
    } catch (e) {
      print('Failed to upload file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> uploadSignedContractPDF() async {
    html.File? pickedFile;
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      if (uploadInput.files!.isEmpty) return;

      pickedFile = uploadInput.files!.first;
      String fileName = pickedFile!.name;
      String companyName = companyNameController.text
          .trim(); // Assuming this is your unique identifier

      // Generate a unique path for each company's contract
      String storagePath = 'company/contracts/$companyName/$fileName';

      try {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child(storagePath);

        // Upload the file using putBlob because File from dart:html is actually a Blob
        TaskSnapshot uploadTask = await ref.putBlob(pickedFile!);

        // Optionally, save the download URL or file path in your database
        print('File uploaded to Firebase Storage at path: $storagePath');
      } catch (e) {
        print('Failed to upload file: $e');
      }
    });
  }

// Similar changes should be made for uploadFoodSafetyCertificate
// This method also allows multiple selections
  Future<void> uploadFoodSafetyCertificate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      for (var pickedFile in result.files) {
        String fileName = pickedFile.name;
        String companyName = companyNameController.text
            .trim(); // Assuming this is your unique identifier
        String storagePath = 'company/certificates/$companyName/$fileName';

        if (kIsWeb) {
          // Handle web file upload
          try {
            FirebaseStorage storage = FirebaseStorage.instance;
            Reference ref = storage.ref().child(storagePath);

            // Web platform uses Blob for file uploads
            await ref.putBlob(pickedFile.bytes!);
            print('File uploaded to Firebase Storage at path: $storagePath');
          } catch (e) {
            print('Failed to upload file: $e');
          }
        }
      }
    }
  }
}
