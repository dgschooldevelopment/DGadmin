import 'package:dgadmin/Admin/Teacher/teacherdashboard.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminDashboard extends StatefulWidget {
  final String collegecode;
  final String collegename;
  final String collegeimage;

  const AdminDashboard(
      {super.key,
      required this.collegecode,
      required this.collegename,
      required this.collegeimage});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Dashboard> dashboardItems = [];

  @override
  
  void initState() {
    super.initState();
    fetchDashboardData(); // Fetch data when the widget is initialized
  }

  Future<void> fetchDashboardData() async {
    final url =
        Uri.parse(adminDashboard);
                // Uri.parse('https://api2-0-w8ev.onrender.com/admin/admindashboard');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          dashboardItems =
              data.map((item) => Dashboard.fromJson(item)).toList();
        });
      } else {
        print('Failed to load dashboard data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
      double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.2;
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 50),
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
                const SizedBox(width: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.collegename,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "College Code : ${widget.collegecode}",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _buildGridLayout(constraints.maxWidth > 800 ? 4 : 2);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLayout(int crossAxisCount) {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(overscroll: false),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: dashboardItems.map((item) => _buildGridItem(item)).toList(),
      ),
    );
  }

  Widget _buildGridItem(Dashboard item) {
    return GestureDetector(
      onTap: () {
        // Navigate to a new screen on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Teacherdashboard(collegecode: widget.collegecode, collegename: widget.collegename, collegeimage: widget.collegeimage,),
          ),
        );
      },
      child:
       Container(
         decoration: BoxDecoration(
        // color: Colors.black,
        borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black),

      ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.image != null ? item.image! : 'assets/teacher.png',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class Dashboard {
  final int id;
  final String? image;
  final String title;

  Dashboard({required this.id, this.image, required this.title});

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      id: json['dashboard_id'],
      image: json['dashboard_image'],
      title: json['dashboard_title'],
    );
  }
}

