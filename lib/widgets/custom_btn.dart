import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double width;
  final Color color;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.height = 40,
    this.width = double.infinity,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(0.0),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          minimumSize: MaterialStateProperty.all<Size>(
            const Size(88.0, 36.0),
          ),
          elevation: MaterialStateProperty.all<double>(0.0),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(color: Colors.white),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(23.0)),
          ),
          child: Container(
            alignment: Alignment.center,
            child: CustomText(
              size: 15,
              textColor: whiteColor,
              text: text,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
