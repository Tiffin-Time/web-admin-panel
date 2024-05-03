import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/widgets/custom_text.dart';
import 'package:adminpanelweb/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CalendarItemView extends StatelessWidget {
  const CalendarItemView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      size: 30,
                      text: '2024.10.30',
                      fontWeight: FontWeight.bold,
                      textColor: blackColor.withOpacity(0.8),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          size: 22,
                          text: 'Order Status: ',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        const Gap(10),
                        const CustomText(
                          size: 22,
                          text: 'Accepted',
                          fontWeight: FontWeight.bold,
                          textColor: Colors.greenAccent,
                        ),
                      ],
                    ),
                    const Gap(10),
                    CustomButton(
                      text: 'Set as Completed',
                      onPressed: () {},
                      width: 140,
                      color: const Color.fromARGB(255, 8, 236, 38),
                    ),
                    const Gap(30),
                    Divider(
                      color: greyColor.withOpacity(0.6),
                      thickness: 1,
                    ),
                    const Gap(15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomText(
                          size: 18,
                          text: 'Order No.',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        CustomText(
                          size: 18,
                          text: 'Customer Name',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        CustomText(
                          size: 18,
                          text: 'Details',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        CustomText(
                          size: 18,
                          text: 'Time to Delivery',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        CustomText(
                          size: 18,
                          text: 'Subtotal',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                      ],
                    ),
                    const Gap(15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomText(
                          size: 18,
                          text: '566',
                          fontWeight: FontWeight.w400,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        CustomText(
                          size: 18,
                          text: 'Dineth Umayanga',
                          fontWeight: FontWeight.w400,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        CustomText(
                          size: 18,
                          text: '1 Full rice',
                          fontWeight: FontWeight.w400,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        CustomText(
                          size: 18,
                          text: '8.30 AM',
                          fontWeight: FontWeight.w400,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        CustomText(
                          size: 18,
                          text: 'Rs. 200',
                          fontWeight: FontWeight.w400,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                      ],
                    ),
                    const Gap(30),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
