library my_project.globals;

String capitalizeEachWord(String text) {
  List<String> words = text.split(' ');

  List<String> capitalizedWords = words.map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).toList();

  return capitalizedWords.join(' ');
}
