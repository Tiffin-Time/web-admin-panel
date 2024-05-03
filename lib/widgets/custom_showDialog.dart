import 'package:adminpanelweb/widgets/custom_text.dart';
import 'package:adminpanelweb/widgets/custom_btn.dart';
import 'package:flutter/material.dart';

Future uploadedDishValidateErrorDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Container(
          width: 500.00,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomText(
                  size: 17,
                  fontWeight: FontWeight.w600,
                  text:
                      "All fields are required including the image. Please fill all fields and try again."),
              const SizedBox(height: 20.0),
              CustomButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Close')
            ],
          ),
        ),
      );
    },
  );
}

Future dishSuccessfullyAddedDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop(true);
      });

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Container(
          width: 500.00,
          padding: const EdgeInsets.all(20.0),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: NetworkImage('https://i.ibb.co/HYD1Bkv/6459980.png'),
                height: 100,
              ),
              SizedBox(height: 20.0),
              CustomText(
                  size: 17,
                  fontWeight: FontWeight.w600,
                  text: "Dish successfully added to the menu."),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      );
    },
  );
}
