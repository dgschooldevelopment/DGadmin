import 'dart:convert';

import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Syallabusdash extends StatefulWidget {
  const Syallabusdash({super.key});

  @override
  State<Syallabusdash> createState() => _SyallabusdashState();
}

class _SyallabusdashState extends State<Syallabusdash> {
  List<Dashboard> dashboardItems = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData(); // Fetch data when the widget is initialized
  }

  Future<void> fetchDashboardData() async {
    final url = Uri.parse("$subjectlist?standard=10");
    // Uri.parse('https://api2-0-w8ev.onrender.com/admin/admindashboard');
    print(url);
    try {
      final response = await http.get(url);
      print(response.statusCode);

      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> data = jsonDecode(response.body);
        print("enter");
        setState(() {
          print("enter1");

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildGridLayout(constraints.maxWidth > 800 ? 4 : 2);
          },
        ),
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
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Teacherdashboard(collegecode: widget.collegecode, collegename: widget.collegename, collegeimage: widget.collegeimage,),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.image != null
                  ? Image.memory(
                      base64Decode(
                          item.image!), // Decode the Base64 string into bytes
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/teacher.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
            ),
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(8),
            //   child: Image.asset(
            //     item.image != null ? item.image! : 'assets/teacher.png',
            //     width: 150,
            //     height: 150,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            const SizedBox(height: 10),
            Text(
              item.name,
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
  final String id;
  final String name;
  final String stand;
  final String division;
  final String subjectCode;
  final String? image;

  Dashboard(
      {required this.id,
      required this.name,
      required this.stand,
      required this.division,
      required this.subjectCode,
      this.image});

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      id: json['subject_code'].toString(),
      name: json['subject_name'].toString(),
      stand: json['stand'].toString(),
      division: json['division'].toString(),
      subjectCode: json['subject_code_prefixed'].toString(),
      image: json['image'],
    );
  }
}
