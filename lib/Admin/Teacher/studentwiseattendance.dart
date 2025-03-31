import 'package:dgadmin/base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
class StudentWiseAttendance extends StatefulWidget {
  final String studId;
  final String collegecode;
    final VoidCallback onBack; // Add back function

  StudentWiseAttendance({
    Key? key,
    required this.studId,
    required this.collegecode, required this.onBack,
  }) : super(key: key);
  @override
  State<StudentWiseAttendance> createState() => _StudentWiseAttendanceState();
}
class _StudentWiseAttendanceState extends State<StudentWiseAttendance> {
  late final ValueNotifier<List<DateTime>> _presentDates;
  late final ValueNotifier<List<DateTime>> _absentDates;
  late final ValueNotifier<List<DateTime>> _holidayDates;
  late final ValueNotifier<List<String>> _selectedDateReasons;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Future<void> _attendanceFuture;
  @override
  void initState() {
    super.initState();
    _presentDates = ValueNotifier<List<DateTime>>([]);
    _absentDates = ValueNotifier<List<DateTime>>([]);
    _holidayDates = ValueNotifier<List<DateTime>>([]);
    _selectedDateReasons = ValueNotifier<List<String>>([]);
    _attendanceFuture = _fetchAttendanceData(widget.studId, widget.collegecode);
  }
  @override
  void dispose() {
    _presentDates.dispose();
    _absentDates.dispose();
    _holidayDates.dispose();
    _selectedDateReasons.dispose();
    super.dispose();
  }
  Future<void> _fetchAttendanceData(String studentId, String collegecode) async {
    try {
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;
      var response = await Dio().get('$studentFetchAttendance', queryParameters: {
        'college_code': collegecode,
        'currentYear': currentYear,
        'currentMonth': currentMonth,
        'student_id': studentId,
      });
  List<dynamic> attendanceData = response.data['attendanceData'];
      List<DateTime> presentDates = [];
      List<DateTime> absentDates = [];
      List<DateTime> holidayDates = [];
      for (var entry in attendanceData) {
        DateTime date = DateTime.parse(entry['date']);
        int? status = entry['status'];
        if (status == 1) {
          presentDates.add(date);
        } else if (status == 0) {
          absentDates.add(date);
        } else if (status == 2) {
          holidayDates.add(date);
        }
      }
     _presentDates.value = presentDates;
      _absentDates.value = absentDates;
      _holidayDates.value = holidayDates;
 // Cache the data locally
      await _cacheAttendanceData(presentDates, absentDates, holidayDates);
    } catch (error) {
      print('Error fetching attendance data: $error');
      await _loadCachedAttendanceData(); // Load cached data if an error occurs
    }
  }
Future<void> _cacheAttendanceData(List<DateTime> present, List<DateTime> absent, List<DateTime> holidays) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Create unique keys based on student ID
  String studentKeyPrefix = 'attendance_${widget.studId}_';
  List<String> presentStringList = present.map((date) => date.toIso8601String()).toList();
  List<String> absentStringList = absent.map((date) => date.toIso8601String()).toList();
  List<String> holidayStringList = holidays.map((date) => date.toIso8601String()).toList();
  await prefs.setStringList('${studentKeyPrefix}presentDates', presentStringList);
  await prefs.setStringList('${studentKeyPrefix}absentDates', absentStringList);
  await prefs.setStringList('${studentKeyPrefix}holidayDates', holidayStringList);
}
Future<void> _loadCachedAttendanceData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();  
  String studentKeyPrefix = 'attendance_${widget.studId}_';
 List<String>? presentStringList = prefs.getStringList('${studentKeyPrefix}presentDates');
  List<String>? absentStringList = prefs.getStringList('${studentKeyPrefix}absentDates');
  List<String>? holidayStringList = prefs.getStringList('${studentKeyPrefix}holidayDates');
  List<DateTime> presentDates = presentStringList != null
      ? presentStringList.map((stringDate) => DateTime.parse(stringDate)).toList()
      : [];
  List<DateTime> absentDates = absentStringList != null
      ? absentStringList.map((stringDate) => DateTime.parse(stringDate)).toList()
      : [];
  List<DateTime> holidayDates = holidayStringList != null
      ? holidayStringList.map((stringDate) => DateTime.parse(stringDate)).toList()
      : [];
 _presentDates.value = presentDates;
  _absentDates.value = absentDates;
  _holidayDates.value = holidayDates;
}
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _updateSelectedDateReasons(selectedDay);
  }
  void _updateSelectedDateReasons(DateTime selectedDay) async {
    try {
      var response = await Dio().get(
        '$studentFetchReason',
        queryParameters: {
          'college_code': widget.collegecode,
          'student_id': widget.studId,
          'date': DateFormat('yyyy-MM-dd').format(selectedDay),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        String reason = response.data['reason'] ?? 'No reason available';
        _selectedDateReasons.value = [reason];
      } else {
        _selectedDateReasons.value = ['No reason available'];
      }
    } catch (error) {
      print('Error fetching reason: $error');
      _selectedDateReasons.value = ['Error fetching reason'];
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.2;
    return Scaffold(
      body: SafeArea(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                        alignment: Alignment.topLeft, // Move to top right

                  child: IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.black,
                  ),
                ),
                
                 SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: FutureBuilder<void>(
                    future: _attendanceFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong !'));
                      } else {
                        return ValueListenableBuilder<List<DateTime>>(
                          valueListenable: _presentDates,
                          builder: (context, presentDates, _) {
                            return ValueListenableBuilder<List<DateTime>>(
                              valueListenable: _absentDates,
                              builder: (context, absentDates, _) {
                                return ValueListenableBuilder<List<DateTime>>(
                                  valueListenable: _holidayDates,
                                  builder: (context, holidayDates, _) {
                                    return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.0), // Set the border color and width
              borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
            ),
                                    child: TableCalendar(
                                      firstDay: DateTime.utc(2020, 1, 1),
                                      lastDay: DateTime.utc(2030, 12, 31),
                                      focusedDay: _focusedDay,
                                      calendarFormat: _calendarFormat,
                                      selectedDayPredicate: (day) {
                                        return _selectedDay != null &&
                                            isSameDay(_selectedDay!, day);
                                      },
                                      onDaySelected: _onDaySelected,
                                      availableCalendarFormats: const {
                                        CalendarFormat.month: 'Month',
                                      },
                                      onFormatChanged: (format) {
                                        // Do nothing as we are only using month format
                                      },
                                      onPageChanged: (focusedDay) {
                                        _focusedDay = focusedDay;
                                      },
                                      headerStyle: HeaderStyle(
                                        formatButtonVisible: false,
                                        titleCentered: true,
                                        titleTextStyle: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        leftChevronIcon: Icon(Icons.chevron_left),
                                        rightChevronIcon: Icon(Icons.chevron_right),
                                      ),
                                      calendarBuilders: CalendarBuilders(
                                        defaultBuilder: (context, day, focusedDay) {
                                          if (day.weekday == DateTime.sunday) {
                                            return _buildCalendarDay(
                                                day, Colors.grey);
                                          } else if (presentDates
                                              .any((d) => isSameDay(d, day))) {
                                            return _buildCalendarDay(
                                                day, Colors.green);
                                          } else if (absentDates
                                              .any((d) => isSameDay(d, day))) {
                                            return _buildCalendarDay(day, Colors.red);
                                          } else if (holidayDates
                                              .any((d) => isSameDay(d, day))) {
                                            return _buildCalendarDay(
                                                day, Colors.yellow);
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    )
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                ValueListenableBuilder<List<String>>(
                  valueListenable: _selectedDateReasons,
                  builder: (context, reasons, _) {
                    if (_selectedDay == null) {
                      return Container();
                    } else if (_presentDates.value
                        .any((d) => isSameDay(d, _selectedDay!))) {
                      return Container(); // Don't display reason card if the selected day is present
                    } else if (_holidayDates.value
                        .any((d) => isSameDay(d, _selectedDay!))) {
                      return Container(); // Don't display reason card if the selected day is a holiday
                    } else if (reasons.isEmpty) {
                      return Center(
                          child: Text('No reasons available for selected date.'));
                    } else {
                      return ReasonCard(
                          reasons: reasons, selectedDate: _selectedDay!);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




 Widget _buildCalendarDay(DateTime day, Color backgroundColor) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}



// class AttendanceCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return 
//     Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0.0),
//       child: Container(
        
//         // width: MediaQuery.of(context).size.width - 40,
//         height: 70,
//         decoration: BoxDecoration(
//           // borderRadius: BorderRadius.circular(15.0),
//           color: Colors.blue,
//           // image: const DecorationImage(
//           //   image: AssetImage('assets/Design.png'),
//           //   fit: BoxFit.cover,
//           // ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10.0),
//               child: IconButton(
//                 onPressed: wi
//                 icon: const Icon(Icons.arrow_back),
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 80),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               alignment: Alignment.centerLeft,
//               child: Row(
//                 children: const [
//                   Text(
//                     'Attendance',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(width: 50),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
 
 
//   }
// }
class ReasonCard extends StatelessWidget {
  final List<String> reasons;
  final DateTime selectedDate;
ReasonCard({required this.reasons, required this.selectedDate});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 1,
                ),
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Text(
                    'Reason for ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: reasons.map((reason) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Reason:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            reason,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
