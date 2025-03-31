import 'package:dgadmin/Admin/collegecode.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DreamsGuider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Delay for 2 seconds and navigate to the next screen
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CollegeCode()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define dynamic sizes based on screen width
    final logoHeight = screenWidth * 0.1; // 10% of screen width
    final subtitleFontSize = screenWidth * 0.015; // 1.5% of screen width
    final footerFontSize = screenWidth * 0.012; // 1.2% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(),
            Column(
              children: [
                // Logo Section with dynamic height
                Image.asset(
                  'assets/DreamsGuider.png', // Replace with your logo asset path
                  height: logoHeight,
                ),
                SizedBox(height: screenHeight * 0.01), // 1% of screen height
                Text(
                  'Software | Education | Advertising',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            Spacer(),
            // Footer Section
            Column(
              children: [
                SizedBox(height: screenHeight * 0.02), // 2% of screen height
                Text(
                  'Powered by',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: footerFontSize),
                ),
                Text(
                  'DreamsGuider.com',
                  style: TextStyle(
                    fontSize: footerFontSize * 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Software | Education | Advertising',
                  style: TextStyle(
                    fontSize: footerFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // 2% of screen height
              ],
            ),
          ],
        ),
      ),
    );
  }
}
