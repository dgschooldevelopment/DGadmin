import 'package:dgadmin/Admin/Fee%20Collection/fee.dart';
import 'package:dgadmin/Admin/Others/othersdashboard.dart';
import 'package:dgadmin/Admin/Parents/prentslist.dart';
import 'package:dgadmin/Admin/Report/report.dart';
import 'package:dgadmin/Admin/Student/studentlist.dart';
import 'package:dgadmin/Admin/Teacher/teacherlist.dart';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:dgadmin/base.dart';

class Teacherdashboard extends StatefulWidget {
  final String collegecode;
   final String collegename;
  final String collegeimage;

  const Teacherdashboard({super.key, required this.collegecode, required this.collegename, required this.collegeimage});

  @override
  State<Teacherdashboard> createState() => _TeacherdashboardState();
}

class _TeacherdashboardState extends State<Teacherdashboard> {
  List<SidebarItemData> sidebarItems = [];
  bool isLoading = true;
  int selectedSidebarIndex = 0; // Track selected sidebar index

  @override
  void initState() {
    super.initState();
    fetchSidebarItems();
  }

  Future<void> fetchSidebarItems() async {
    final response =
        await http.get(Uri.parse(adminDashboard)); // Replace with your API URL
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        sidebarItems =
            data.map((item) => SidebarItemData.fromJson(item)).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
List<IconData> sidebarIcons = [
  Icons.person_3,              // Teacher
  Icons.people,                // Parent
  Icons.school,                // Student
  Icons.monetization_on,       // Fee Collection
  Icons.assignment_turned_in,  // Exam
  Icons.access_time,           // Timetable
  Icons.feedback,              // Teacher Feedback
  Icons.report_problem,       // Student Issues
  Icons.warning,              // Teacher Issues
  Icons.connect_without_contact, // Connect to Head Branch
];


    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  color: Colors.blue,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 50),
                      Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipOval(
                    child: Image.network(
                      widget.collegeimage,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                      SizedBox(width: 50),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.collegename}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "College Code : ${widget.collegecode}",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


                // Sidebar and Content Layout
                Expanded(
                  child: Row(
                    children: [
                      // Sidebar with dynamic items
                      Container(
                        width: screenWidth * 0.2,
                        color: Colors.blue,
                        child: ListView.builder(
                          itemCount: sidebarItems.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedSidebarIndex = index;
                                });
                              },
                              child: SidebarItem(
                                title: sidebarItems[index].dashboardTitle,
                                isSelected: selectedSidebarIndex == index,
                                icon: sidebarIcons[index], // Get the correct icon
                                // Get the correct icon
                              ),
                            );
                          },
                        ),
                      ),

                      // Main Content Area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildSelectedContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }


  Widget _buildSelectedContent() {
    switch (selectedSidebarIndex) {
      case 0:
        return TeacherListView(collegecode: widget.collegecode, collegename: widget.collegename, collegeimage: widget.collegeimage,);
      case 1:
       return parentlist(collegecode: widget.collegecode, collegename: widget.collegename, collegeimage: widget.collegeimage,);
         case 2:
        return StudentList(collegecode: widget.collegecode, collegename: widget.collegename, collegeimage: widget.collegeimage,);
         case 3:
        return DashboardScreen( collegeCode: widget.collegecode,);
        case 4:
         return Certificates(collegeCode: widget.collegecode,);
          case 5:
         return OthersDash(collegecode: widget.collegecode, );
      default:
        return Center(child: Text('Unknown Content'));
    }
  }
}


// Separate Class for Another Content View
class AnotherContentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Content for Another Sidebar Item'),
    );
  }
}

// Sidebar Item Widget
class SidebarItem extends StatelessWidget {
  final String title;
  final bool isSelected;
   final IconData icon;

  SidebarItem({required this.title, required this.isSelected,required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: isSelected ? Colors.blue[900] : Colors.transparent,
      // padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade100 : Colors.transparent, // Faint blue for selected item
        borderRadius: BorderRadius.circular(8), 
      ),
       margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Add spacing
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      // child: Text(
      //   title,
      //   style: TextStyle(color: Colors.white, fontSize: 16),
      // ),
      child: Row(
        children: [
          Icon(
            icon, // Placeholder for an icon
            size: 18,
            color: isSelected ? Colors.blue.shade700 : Colors.white70,
          ),
          SizedBox(width: 10), // Space between icon and text
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue.shade900 : Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Models
class SidebarItemData {
  final int dashboardId;
  final String? dashboardImage;
  final String dashboardTitle;

  SidebarItemData(
      {required this.dashboardId,
      this.dashboardImage,
      required this.dashboardTitle});

  factory SidebarItemData.fromJson(Map<String, dynamic> json) {
    return SidebarItemData(
      dashboardId: json['dashboard_id'],
      dashboardImage: json['dashboard_image'],
      dashboardTitle: json['dashboard_title'],
    );
  }
}
