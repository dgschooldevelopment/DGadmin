
import 'package:dgadmin/Admin/Teacher/dash.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  final String collegecode;
  final String collegename;
  final String collegeimage;
  final String teachercode;
  final String teachername;
  final String mobileno;
  final String teacherprofile;

  const Dashboard({
    super.key,
    required this.collegecode,
    required this.collegename,
    required this.collegeimage,
    required this.teachercode,
    required this.teachername,
    required this.mobileno,
    required this.teacherprofile,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> titles = [];
  List<String> imagePaths = [];

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final String apiUrl =
        "$teacherdashboard?college_code=${widget.collegecode}&teacher_code=${widget.teachercode}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          titles = data.map((item) => item['title'] as String).toList();
          imagePaths = data.map((item) => item['image'] as String).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.2;
    return Scaffold(
      body: Column(
        children: [
          // Teacher Info Section
          Container(
            color: Colors.blue,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: ElevatedButton(onPressed: (){
                    Navigator.pop(context);

                  }, child: Text("back")),

                ),
                const SizedBox(width: 50),
                ClipOval(
                  child: Image.network(
                    widget.teacherprofile,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.teachername,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.mobileno,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),

          // Responsive Grid
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

  // Function to build responsive GridView
  Widget _buildGridLayout(int crossAxisCount) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : hasError
            ? const Center(child: Text("Failed to load dashboard data"))
            : ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(overscroll: false),
                child: GridView.builder(
                  itemCount: titles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (context, index) {
                    return _buildGridItem(index);
                  },
                ),
              );
  }

  // Function to build individual grid items
  Widget _buildGridItem(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dash(
              collegecode: widget.collegecode,
              teachercode: widget.teachercode,
              teachername: widget.teachername,
              mobileno: widget.mobileno,
              teacherprofile: widget.teacherprofile,
            ),
          ),
        );
      },
      child:
       Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagePaths[index].isNotEmpty
                  ? Image.memory(
                      base64Decode(imagePaths[index]),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/teacher.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              titles[index],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    
    );
  }
}
