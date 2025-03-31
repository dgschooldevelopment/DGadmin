import 'package:dgadmin/Admin/Student/Homework/homeworkdash.dart';
import 'package:dgadmin/Admin/Student/syallabusdash.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class StudentDash extends StatefulWidget {
   final String collegecode;
   final String collegename;
  final String collegeimage;
  const StudentDash({super.key, required this.collegecode, required this.collegename, required this.collegeimage});

  @override
  State<StudentDash> createState() => _StudentDashState();
}

class _StudentDashState extends State<StudentDash> {
    List<SidebarItemData> sidebarItems = [];
  bool isLoading = true;
  int selectedSidebarIndex = 0; // Track selected sidebar index

  @override
  void initState() {
    super.initState();
    fetchSidebarItems();
    print(widget.collegename);
  }

  Future<void> fetchSidebarItems() async {
    final response =
        await http.get(Uri.parse(studentdash));
         // Replace with your API URL
         print(studentdash);
         print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        sidebarItems =
            data.map((item) => SidebarItemData.fromJson(item)).toList();
        isLoading = false;
      });
    }else{
      print('Failed to fetch sidebar items');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
        return HomeworkDash();
      case 1:
        return Syallabusdash();
      // case 1:
      //   return HomeworkDash();
        //  case 2:
        // return StudentList(collegecode: widget.collegecode, collegename: widget.collegecode, collegeimage: widget.collegeimage,);
        //  case 3:
        // return parentlist(collegecode: widget.collegecode, collegename: widget.collegename, collegeimage: widget.collegeimage,);
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

  SidebarItem({required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? Colors.blue[900] : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 16),
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
      dashboardId: json['id'],
      dashboardImage: json['image'],
      dashboardTitle: json['title'],
    );
  }
}


