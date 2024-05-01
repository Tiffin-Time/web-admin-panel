import 'package:adminpanelweb/consts/colors.dart';
import 'package:adminpanelweb/screens/calendar%20view/calendar_item_view.dart';
import 'package:adminpanelweb/widgets/customText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

import 'package:google_fonts/google_fonts.dart';

class ViewSchedulePage extends StatefulWidget {
  final String? userDocId;

  const ViewSchedulePage({Key? key, this.userDocId}) : super(key: key);

  @override
  State<ViewSchedulePage> createState() => _ViewSchedulePageState();
}

class _ViewSchedulePageState extends State<ViewSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50, vertical: 80),
          child: const SafeArea(
            child: ViewSheduleWidget(),
          ),
        ),
      ),
    );
  }
}

class ViewSheduleWidget extends StatefulWidget {
  const ViewSheduleWidget({
    super.key,
  });

  @override
  State<ViewSheduleWidget> createState() => _ViewSheduleWidgetState();
}

class _ViewSheduleWidgetState extends State<ViewSheduleWidget> {
  late DateTime selectedMonth;

  List<DateTime> deliveryDates = [];
  List<DateTime> collectDates = [];
  DateTime? selectedDate;

  @override
  void initState() {
    //fetch selected dates from server
    deliveryDates = [
      DateTime(2024, 04, 08),
      DateTime(2024, 04, 01),
      DateTime(2024, 04, 13),
    ];

    collectDates = [
      DateTime(2024, 04, 09),
      DateTime(2024, 04, 11),
      DateTime(2024, 04, 19),
    ];
    selectedMonth = DateTime.now().monthStart;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              //custom Calendar --
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 480,
                    width: size.width * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          selectedMonth: selectedMonth,
                          selectedDate: selectedDate,
                          onChange: (value) =>
                              setState(() => selectedMonth = value),
                        ),
                        Expanded(
                          child: _Body(
                            deliveryDates: deliveryDates,
                            collectDates: collectDates,
                            selectedDate: selectedDate,
                            selectedMonth: selectedMonth,
                            selectDate: (DateTime value) => setState(() {
                              selectedDate = value;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 32,
                              width: 32,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 16, 207, 22),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(10),
                            const CustomText(
                              size: 16,
                              text: 'Delivery',
                              fontWeight: FontWeight.bold,
                              textColor: blackColor,
                            ),
                          ],
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            Container(
                              height: 32,
                              width: 32,
                              decoration: const BoxDecoration(
                                color: const Color.fromARGB(255, 0, 117, 250),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(10),
                            const CustomText(
                              size: 16,
                              text: 'Collect',
                              fontWeight: FontWeight.bold,
                              textColor: blackColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final DateTime selectedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onChange;

  const _Header({
    required this.selectedMonth,
    required this.selectedDate,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    // int currentMonthIndex = selectedMonth.month - 1;
    final List<DropdownMenuItem<DateTime>> dropdownItems = List.generate(
      5,
      (index) {
        final monthIndex = index % 12;
        final yearToAdd = DateTime.now().year + (index ~/ 12);
        final monthToAdd = DateTime(yearToAdd, monthIndex + 1);

        return DropdownMenuItem<DateTime>(
          value: monthToAdd,
          child: Text(
            '${monthNames[monthToAdd.month - 1]}, ${monthToAdd.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<DateTime>(
                  value: selectedMonth,
                  isExpanded: false,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  icon: Icon(Icons.arrow_drop_down_sharp),
                  onChanged: (value) => onChange(value!),
                  items: dropdownItems,
                ),
              ),
              const SizedBox(width: 25),
            ],
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.selectedMonth,
    required this.selectedDate,
    required this.selectDate,
    required this.deliveryDates,
    required this.collectDates,
  });

  final DateTime selectedMonth;
  final DateTime? selectedDate;
  final List<DateTime> deliveryDates;
  final List<DateTime> collectDates;
  final ValueChanged<DateTime> selectDate;

  @override
  Widget build(BuildContext context) {
    var data = CalendarMonthData(
      year: selectedMonth.year,
      month: selectedMonth.month,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomText(
                size: 18,
                text: 'M',
                textColor: whiteColor,
              ),
              CustomText(
                size: 18,
                text: 'T',
                textColor: whiteColor,
              ),
              CustomText(
                size: 18,
                text: 'W',
                textColor: whiteColor,
              ),
              CustomText(
                size: 18,
                text: 'T',
                textColor: whiteColor,
              ),
              CustomText(
                size: 18,
                text: 'F',
                textColor: whiteColor,
              ),
              CustomText(
                size: 18,
                text: 'S',
                textColor: whiteColor,
              ),
              CustomText(
                size: 18,
                text: 'S',
                textColor: whiteColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var week in data.weeks)
                Row(
                  children: [
                    for (var day in week)
                      Expanded(
                        child: _RowItem(
                          hasRightBorder: false,
                          date: day.date,
                          isActiveMonth: day.isActiveMonth,
                          onTap: () => selectDate(day.date),
                          deliveryDates: deliveryDates,
                          collectDates: collectDates,
                        ),
                      ),
                  ],
                ),
              if (selectedDate != null)
                Text('Selected Date: ${selectedDate.toString()}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.hasRightBorder,
    required this.isActiveMonth,
    required this.date,
    required this.onTap,
    required this.deliveryDates,
    required this.collectDates,
  });

  final bool hasRightBorder;
  final bool isActiveMonth;
  final VoidCallback onTap;
  final DateTime date;
  final List<DateTime> deliveryDates;
  final List<DateTime> collectDates;

  @override
  Widget build(BuildContext context) {
    final String number = date.day.toString().padLeft(2, '0');
    final isToday = date.isToday;
    final bool isPassed = date.isBefore(DateTime.now());

    // Check if the date is in the list of selected dates

    final isDeliveryDate = deliveryDates.any((selectedDate) =>
        selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day);

    final isCollectDate = collectDates.any((selectedDate) =>
        selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day);

    final BoxDecoration? boxDecoration = isDeliveryDate || isCollectDate
        ? isPassed
            ? null
            : BoxDecoration(
                color: isCollectDate
                    ? const Color.fromARGB(255, 0, 117, 250)
                    : const Color.fromARGB(255, 16, 207, 22),
                shape: BoxShape.circle,
              )
        : null;

    return GestureDetector(
      onTap: () {
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        height: 40,
        decoration: isActiveMonth ? boxDecoration : null,
        child: GestureDetector(
          onTap: () {
            if (isCollectDate) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarItemView(),
                ),
              );
            } else if (isDeliveryDate) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarItemView(),
                ),
              );
            } else {
              print("No");
            }
          },
          child: CustomText(
              size: 25,
              text: '$number',
              textColor: (isActiveMonth
                  ? isPassed
                      ? isToday
                          ? Colors.white
                          : Colors.grey[600]
                      : Colors.white
                  : blackColor)!),
        ),
      ),
    );
  }
}

class CalendarMonthData {
  CalendarMonthData({
    required this.year,
    required this.month,
  }) {
    weeks = _generateWeeks();
  }

  final int year;
  final int month;

  late List<List<CalendarDayData>> weeks;

  List<List<CalendarDayData>> _generateWeeks() {
    final firstDay = DateTime(year, month);
    final lastDay = DateTime(year, month + 1).subtract(const Duration(days: 1));

    final weeks = <List<CalendarDayData>>[];
    var week = <CalendarDayData>[];

    // Determine the number of days to show from the previous month
    int daysBefore = firstDay.weekday - 1;

    for (var i = 0; i < daysBefore; i++) {
      final date = firstDay.subtract(Duration(days: daysBefore - i));
      week.add(CalendarDayData(date: date, isActiveMonth: false));
    }

    for (var i = 0; i < lastDay.day; i++) {
      final date = firstDay.add(Duration(days: i));
      week.add(CalendarDayData(date: date, isActiveMonth: true));
      if (date.month != month) {
        week.removeLast(); // Remove days outside the current month
      }
      if (week.length == 7) {
        weeks.add(week);
        week = <CalendarDayData>[];
      }
    }

    // Determine the number of days to show from the next month
    int daysAfter = 7 - lastDay.weekday;

    for (var i = 0; i < daysAfter; i++) {
      final date = lastDay.add(Duration(days: i + 1));
      week.add(CalendarDayData(date: date, isActiveMonth: false));
    }

    if (week.isNotEmpty) {
      weeks.add(week);
    }

    return weeks;
  }
}

class CalendarDayData {
  CalendarDayData({
    required this.date,
    required this.isActiveMonth,
  });

  final DateTime date;
  final bool isActiveMonth;
}

extension DateTimeExt on DateTime {
  DateTime get monthStart => DateTime(year, month);
  DateTime get dayStart => DateTime(year, month, day);

  DateTime addMonth(int count) {
    return DateTime(year, month + count, day);
  }

  bool isSameDate(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }

  bool get isToday {
    return isSameDate(DateTime.now());
  }
}
