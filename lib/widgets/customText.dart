import 'package:adminpanelweb/consts/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    Key? key,
    required this.size,
    required this.text,
    this.textColor = blackColor,
    this.align = TextAlign.center,
    this.fontWeight = FontWeight.w400,
    this.isReg = false,
  }) : super(key: key);

  final double size;
  final String text;
  final Color textColor;
  final FontWeight fontWeight;
  final TextAlign align;
  final bool isReg;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: isReg
          ? GoogleFonts.lemon(
              // Use GoogleFonts.roboto to apply the Roboto font
              textStyle: TextStyle(
                color: textColor,
                fontSize: size,
                fontWeight: fontWeight,
              ),
            )
          : GoogleFonts.roboto(
              textStyle: TextStyle(
                color: textColor,
                fontSize: size,
                fontWeight: fontWeight,
              ),
            ),
      textAlign: align,
    );
  }
}
