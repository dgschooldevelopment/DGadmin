import 'dart:convert';

import 'package:dgadmin/Admin/dashboard.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CollegeCode extends StatefulWidget {
  const CollegeCode({super.key});

  @override
  State<CollegeCode> createState() => _CollegeCodeState();
}

class _CollegeCodeState extends State<CollegeCode> {
  @override
  Widget build(BuildContext context) {
    // Fetching the screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final logoHeight = screenWidth * 0.1; // 10% of screen width
    final collecodecotroller = TextEditingController();

    login() async {
      String collegecode = collecodecotroller.text;
      final apiUrl = "$adminlogin?college_code=$collegecode";
      Map<String, String> body = {
        "college_code": collegecode,
      };
      var response = await http.post(Uri.parse(apiUrl), body: body);
      if (response.statusCode == 200) {
        // print("login successful");
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Navigate to dashboard
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminDashboard(
                        collegecode: data['college']['college_code'],
                        collegename: data['college']['college_name'],
                        collegeimage: data['college']['college_image'],
                      )));
        }
      } else {}
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(color: Colors.black),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26, // Light shadow color
                  blurRadius: 10, // Softness of the shadow
                  spreadRadius: 2, // How much the shadow expands
                  offset: Offset(4, 4), // Position of the shadow
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    'assets/DreamsGuider.png',
                    height: logoHeight,
                  ),
                  SizedBox(height: 10),

                  // Subtitle
                  Text(
                    "Software | Education | Advertising",
                    style: TextStyle(
                      fontSize: screenWidth * 0.015,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),

                  // School Code input field
                  SizedBox(
                    width: screenWidth * 0.36,
                    child: TextField(
                      controller: collecodecotroller,
                      decoration: InputDecoration(
                        hintText: "Enter School Code",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Proceed Button
                  ElevatedButton(
                    onPressed: () {
                      login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "PROCEED",
                      style: TextStyle(
                          fontSize: screenWidth * 0.015, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       // Background Image with clouds
    //       Container(
    //         width: screenWidth,
    //         height: screenHeight,
    //         decoration: BoxDecoration(
    //           image: DecorationImage(
    //             image: AssetImage("assets/cloud_background.png"),
    //             fit: BoxFit.cover,
    //           ),
    //         ),
    //       ),

    //       // Centered content overlay
    //       Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             // Logo and text
    //             Image.asset(
    //               'assets/DreamsGuider.png', // Replace with your logo asset path
    //               height: logoHeight,
    //             ),
    //             SizedBox(height: screenHeight * 0.01),
    //             Text(
    //               "Software | Education | Advertising",
    //               style: TextStyle(
    //                 fontSize: screenWidth * 0.015,
    //                 color: Colors.black54,
    //               ),
    //             ),
    //             SizedBox(height: screenHeight * 0.05),

    //             // School Code input field
    //             Container(
    //               width: screenWidth * 0.4,
    //               child: TextField(
    //                 controller: collecodecotroller,
    //                 decoration: InputDecoration(
    //                   hintText: "Enter School Code",
    //                   border: OutlineInputBorder(
    //                     borderRadius: BorderRadius.circular(8),
    //                   ),
    //                   filled: true,
    //                   fillColor: Colors.white,
    //                 ),
    //                 textAlign: TextAlign.center,
    //               ),
    //             ),

    //             SizedBox(height: screenHeight * 0.03),

    //             // Proceed button
    //             ElevatedButton(
    //               onPressed: () {
    //                 // Button action here
    //                 login();
    //               },
    //               style: ElevatedButton.styleFrom(
    //                 backgroundColor: Colors.blue,
    //                 padding: EdgeInsets.symmetric(
    //                   horizontal: screenWidth * 0.17,
    //                   vertical: screenHeight * 0.02,
    //                 ),
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(8),
    //                 ),
    //               ),
    //               child: Text(
    //                 "PROCEED",
    //                 style: TextStyle(fontSize: screenWidth * 0.015),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class CollegeInfo {
  final String collegecode;
  final String collegename;
  final String collegeImage;
  CollegeInfo(
      {required this.collegecode,
      required this.collegename,
      required this.collegeImage});
}
