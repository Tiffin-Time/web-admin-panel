class Dish {
  final String name;
  final String description;
  final double price;
  final String typeOfDish;
  final List assignTags;
  final String comboWithAnotherDish;
  final double comboPrice;
  final String dishImage;
  final List<String> allergens;
  final Map<String, bool> dateAvailability;

  Dish({
    required this.name,
    required this.description,
    required this.price,
    required this.typeOfDish,
    required this.assignTags,
    required this.comboWithAnotherDish,
    required this.comboPrice,
    required this.dishImage,
    required this.dateAvailability,
    required this.allergens,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'typeOfDish': {
        typeOfDish: true,
      },
      'assignTags': assignTags,
      'comboWithAnotherDish': comboWithAnotherDish,
      'comboPrice': comboPrice,
      'dishImage': dishImage,
      'dateAvailability': dateAvailability,
      'allergens': allergens
    };
  }
}
//enum DateAvailability { everyDay, selectedDays }
