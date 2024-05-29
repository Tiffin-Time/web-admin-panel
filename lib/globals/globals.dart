library my_project.globals;

import 'package:cloud_firestore/cloud_firestore.dart';

String capitalizeEachWord(String text) {
  List<String> words = text.split(' ');

  List<String> capitalizedWords = words.map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).toList();

  return capitalizedWords.join(' ');
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
