import 'package:adminpanelweb/consts/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final int maxlines;
  final bool enabled;
  final double borderRadius;
  final int maxlen;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.enabled,
    this.maxlines = 2,
    this.borderRadius = 10.0,
    this.maxlen = 150, // Set default border radius
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxlines,
      enabled: enabled,
      maxLength: maxlen,
      controller: controller,
      style: const TextStyle(
        color: blackColor,
        fontSize: 17,
        fontWeight: FontWeight.w300,
      ),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: blackColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: blackColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: blackColor),
        ),
        hintStyle: TextStyle(
          color: blackColor.withOpacity(0.5),
          fontSize: 17,
          fontWeight: FontWeight.w300,
        ),
        hintText: labelText,
      ),
      textAlign: TextAlign.left,
      focusNode: FocusNode(),
    );
  }
}
