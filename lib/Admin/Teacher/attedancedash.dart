import 'package:dgadmin/Admin/Teacher/studentlist.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class attedancedash extends StatefulWidget {
  final String teacherId;
  final String collegeCode;
  final String standard;
  final String division;
  const attedancedash({super.key, required this.teacherId, required this.collegeCode, required this.standard, required this.division});

  @override
  State<attedancedash> createState() => _attedancedashState();
}


class _attedancedashState extends State<attedancedash> {
  bool showAttendanceRecords = true; // Toggle between screens

  String? selectedMonth;
  String? selectedYear;
  final List<String> months = [
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
    'December'
  ];
  final List<String> years = [
    DateTime.now().year.toString(),
    (DateTime.now().year - 1).toString(),
    (DateTime.now().year + 1).toString(),
  ];
  List<dynamic> attendanceData = [];
  bool isLoading = false;
  bool dataNotFound = false;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    selectedMonth = months[now.month - 1];
    selectedYear = now.year.toString();
    fetchAttendanceData(now.month, now.year);
  }

  void fetchAttendanceData(int month, int year) async {
    setState(() {
      isLoading = true;
      dataNotFound = false;
    });

    final uri = Uri.parse(
        '$attendencecount?std=${widget.standard}&division=${widget.division}&year=$year&college_code=${widget.collegeCode}&month=$month');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        attendanceData = json.decode(response.body);
        isLoading = false;
        dataNotFound = attendanceData.isEmpty;
      });
    } else {
      setState(() {
        isLoading = false;
        dataNotFound = true;
      });
      throw Exception('Failed to load attendance data');
    }
  }

  void toggleView() {
    setState(() {
      showAttendanceRecords = !showAttendanceRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: showAttendanceRecords ? buildAttendanceRecordsView() : StudentListForAttendance(
          standard: widget.standard,
          division: widget.division,
          collegeCode: widget.collegeCode,
                          onBack: toggleView, // Pass the function to switch views

        ),
      ),
    );
  }

  Widget buildAttendanceRecordsView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                elevation: 5,
                backgroundColor: Color.fromARGB(255, 185, 246, 246),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                setState(() {
                  showAttendanceRecords = !showAttendanceRecords;
                });
              },
              child: Text(
                showAttendanceRecords ? 'Show Student List' : 'Attendance Records',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 241, 163, 163),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Previous Record',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: buildDropdownButton(months, selectedMonth, (newValue) {
                    setState(() {
                      selectedMonth = newValue;
                      fetchAttendanceData(months.indexOf(newValue!) + 1, int.parse(selectedYear!));
                    });
                  }),
                ),
                SizedBox(width: 30),
                Expanded(
                  child: buildDropdownButton(years, selectedYear, (newValue) {
                    setState(() {
                      selectedYear = newValue;
                      fetchAttendanceData(months.indexOf(selectedMonth!) + 1, int.parse(newValue!));
                    });
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : dataNotFound
                    ? Center(child: Text('Data not found'))
                    : ListView.builder(
                        itemCount: attendanceData.length,
                        itemBuilder: (context, index) {
                          final item = attendanceData[index];
                          final presentCount = item['present_count'];
                          final absentCount = item['absent_count'];

                          if ((presentCount == null && absentCount == null) ||
                              (presentCount == "0" && absentCount == "0")) {
                            return SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: AttendanceRecordCard(
                              date: item['date'],
                              presentCount: presentCount,
                              absentCount: absentCount,
                              division: widget.division,
                              standatd: widget.standard,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownButton(List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedValue,
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.black, fontSize: 18),
        underline: SizedBox(),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}


 class AttendanceRecordCard extends StatelessWidget {
  final String date;
  final String presentCount;
  final String absentCount;
  final String standatd;
  final String division;

  const AttendanceRecordCard({
    super.key,
    required this.date,
    required this.presentCount,
    required this.absentCount,
    required this.standatd,
    required this.division,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Class: ${standatd} ${division}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusIndicator(presentCount, 'Present', Colors.green),
                  _buildStatusIndicator(absentCount, 'Absent', Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStatusIndicator(String count, String status, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color,
          child: Text(
            count,
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 5),
        Text(status),
      ],
    );
  }
}

