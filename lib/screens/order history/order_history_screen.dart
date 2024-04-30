import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/widgets/customText.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: SafeArea(
              child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50, vertical: 80),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: greyColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CustomText(
                          size: 20,
                          text: 'Total Orders',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        Gap(20),
                        CustomText(
                          size: 20,
                          text: '51',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor,
                        ),
                      ],
                    ),
                  ),
                  Gap(10),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: greyColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CustomText(
                          size: 20,
                          text: 'Gross Revenue this month',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor.withOpacity(0.8),
                        ),
                        Gap(20),
                        CustomText(
                          size: 20,
                          text: '\$1280',
                          fontWeight: FontWeight.bold,
                          textColor: blackColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(30),
              TabBar(
                tabs: [
                  Tab(text: 'Weekly'),
                  Tab(text: 'Monthly'),
                ],
              ),
              Container(
                height: 500, // Adjust this value as needed
                child: TabBarView(
                  children: [
                    DataListView(dataList: weeklyDataList),
                    DataListView(dataList: monthlyDataList),
                  ],
                ),
              ),
            ],
          ),
        ),
      ))),
    );
  }
}

class DataListView extends StatelessWidget {
  final List<Map<String, dynamic>> dataList;

  DataListView({required this.dataList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dataList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomText(
                  size: 14,
                  text: 'Order No.',
                  fontWeight: FontWeight.bold,
                  textColor: blackColor.withOpacity(0.8),
                ),
                CustomText(
                  size: 14,
                  text: 'Ordered Date',
                  fontWeight: FontWeight.bold,
                  textColor: blackColor.withOpacity(0.8),
                ),
                CustomText(
                  size: 14,
                  text: 'Delivery',
                  fontWeight: FontWeight.bold,
                  textColor: blackColor.withOpacity(0.8),
                ),
                CustomText(
                  size: 14,
                  text: 'Time',
                  fontWeight: FontWeight.bold,
                  textColor: blackColor.withOpacity(0.8),
                ),
                CustomText(
                  size: 14,
                  text: 'Subtotal',
                  fontWeight: FontWeight.bold,
                  textColor: blackColor.withOpacity(0.8),
                ),
              ],
            ),
          );
        }

        Map<String, dynamic> item = dataList[index - 1];

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: lightBlue2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomText(
                  size: 14,
                  text: item['orderNumber'],
                  fontWeight: FontWeight.w400,
                  textColor: blackColor.withOpacity(0.8),
                ),
                CustomText(
                  size: 14,
                  text: item['orderDate'],
                  fontWeight: FontWeight.w400,
                  textColor: blackColor.withOpacity(0.8),
                ),
                CustomText(
                  size: 14,
                  text: item['deliveryMethod'],
                  fontWeight: FontWeight.w400,
                  textColor: blackColor.withOpacity(0.8),
                ),
                CustomText(
                  size: 14,
                  text: item['deliveryDate'],
                  fontWeight: FontWeight.w400,
                  textColor: blackColor.withOpacity(0.8),
                ),
                CustomText(
                  size: 14,
                  text: item['subTotal'],
                  fontWeight: FontWeight.w400,
                  textColor: blackColor.withOpacity(0.8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<Map<String, dynamic>> monthlyDataList = [
  {
    'status': 'Delivered',
    'orderNumber': '12345',
    'orderDate': '2022-01-01',
    'details': 'Item details',
    'deliveryMethod': 'Courier',
    'deliveryDate': '2022-01-02',
    'subTotal': '50.00',
  },
  {
    'status': 'In Transit',
    'orderNumber': '12346',
    'orderDate': '2022-01-02',
    'details': 'Item details',
    'deliveryMethod': 'Collect',
    'deliveryDate': '2022-01-03',
    'subTotal': '75.00',
  },
];
List<Map<String, dynamic>> weeklyDataList = [
  {
    'status': 'Delivered',
    'orderNumber': '12345',
    'orderDate': '2022-01-01',
    'details': 'Item details',
    'deliveryMethod': 'Collect',
    'deliveryDate': '2022-01-02',
    'subTotal': '50.00',
  },
  {
    'status': 'In Transit',
    'orderNumber': '12346',
    'orderDate': '2022-01-02',
    'details': 'Item details',
    'deliveryMethod': 'Collect',
    'deliveryDate': '2022-01-03',
    'subTotal': '75.00',
  },
];
