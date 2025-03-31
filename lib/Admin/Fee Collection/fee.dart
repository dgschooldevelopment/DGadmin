import 'dart:convert';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  final String collegeCode;
  const DashboardScreen({
    super.key,
    required this.collegeCode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalFee = 0;
  int totalPaid = 0;
  int totalRemaining = 0;
  List<Map<String, dynamic>> feeDetails = [];
  List<Map<String, dynamic>> classwiseFeeCollection = [];
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredClasswiseFeeCollection = [];

  @override
  void initState() {
    super.initState();
    fetchFeeData();
    fetchClasswiseFeeData();
  }

  Future<void> fetchFeeData() async {
    final url =
        Uri.parse('$totalFeeDetails?college_code=${widget.collegeCode}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalFee = data['total_fee_all_types'];
          totalPaid = data['total_collected_fee'];
          totalRemaining = data['total_remaining_fee'];
          feeDetails = List<Map<String, dynamic>>.from(data['fees']);
        });
      }
    } catch (error) {
      print('Error fetching fee data: $error');
    }
  }

  Future<void> fetchClasswiseFeeData() async {
    final url =
        Uri.parse('$classwiseFeeDetails?college_code=${widget.collegeCode}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          classwiseFeeCollection = List<Map<String, dynamic>>.from(
              data['class_wise_fee_collection']);
          filteredClasswiseFeeCollection = classwiseFeeCollection;
        });
      }
    } catch (error) {
      print('Error fetching classwise fee data: $error');
    }
  }

  void searchClasswiseFeeCollection(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredClasswiseFeeCollection = classwiseFeeCollection;
      });
      return;
    }

    setState(() {
      filteredClasswiseFeeCollection =
          classwiseFeeCollection.where((classData) {
        String className =
            "${classData['standard']} ${classData['division']}".toLowerCase();
        return className.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                showFeeTypeDialog(context, widget.collegeCode);

                // login();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                // padding: EdgeInsets.symmetric(
                //   horizontal: screenWidth * 0.15,
                //   vertical: screenHeight * 0.02,
                // ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Add fee type",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            _buildFeeSummaryCard(),
            _buildFeeDetailsGrid(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      " Classwise fee collection search :-",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.height *
                          0.4, // Adjusted width for the search bar
                      height: 40,
                      child: TextField(
                        controller: searchController,
                        onChanged:
                            searchClasswiseFeeCollection, // Call search function on input
                        decoration: InputDecoration(
                          hintText: 'Search student',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildClasswiseFeeCollectionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeSummaryCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Card(
        elevation: 10,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 9, top: 7),
              child: Text(
                "Fee Summary :",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: totalPaid.toDouble(),
                            title: 'Paid',
                            titleStyle: TextStyle(color: Colors.white),
                            color: Colors.green,
                            radius: 100,
                          ),
                          PieChartSectionData(
                            value: totalRemaining.toDouble(),
                            title: 'Remaining',
                            titleStyle: TextStyle(color: Colors.white),
                            color: Colors.red,
                            radius: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Table(
                      border: TableBorder.all(color: Colors.black),
                      columnWidths: {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      children: [
                        _buildTableRow("Category", "Amount", isHeader: true),
                        _buildTableRow("Total Fee", "$totalFee"),
                        _buildTableRow("Total Paid", "$totalPaid"),
                        _buildTableRow("Total Remaining", "$totalRemaining"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeDetailsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 5),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemCount: feeDetails.length,
        itemBuilder: (context, index) {
          return _buildFeeCard(feeDetails[index], context);
        },
      ),
    );
  }

  Widget _buildClasswiseFeeCollectionGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 5),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        // Change classwiseFeeCollection to filteredClasswiseFeeCollection
        itemCount: filteredClasswiseFeeCollection.length,
        itemBuilder: (context, index) {
          return _buildClasswiseFeeCard(filteredClasswiseFeeCollection[index]);
        },
      ),
    );
  }

  Widget _buildFeeDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      child: Column(
        children: feeDetails.map((fee) {
          return _buildFeeCard(fee, context);
        }).toList(),
      ),
    );
  }

  Widget _buildClasswiseFeeCollection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      child: Column(
        children: classwiseFeeCollection.map((classData) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.20,
            height: MediaQuery.of(context).size.height * 0.20,
            child: Card(
              elevation: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeeRow(
                    "Class:",
                    "${classData['standard']} ${classData['division']}",
                  ),
                  _buildFeeRow("Total Fee:", "${classData['total_fee']}"),
                  _buildFeeRow("Total Paid:", "${classData['collected_fee']}"),
                  _buildFeeRow(
                      "Total Remaining:", "${classData['remaining_fee']}"),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

Widget _buildFeeRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}

Widget _buildFeeCard(Map<String, dynamic> fee, context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.40,
    height: MediaQuery.of(context).size.height * 0.40,
    child: Card(
        elevation: 10,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 9, top: 7),
              child: Text(
                "${fee['type_of_fee']} Fee :",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 10),
            Flexible(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 160,
                      width: 160,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: (fee['collected_fee'] as int).toDouble(),
                              title: 'Paid',
                              titleStyle: TextStyle(color: Colors.white),
                              color: Colors.blue,
                              radius: 80,
                            ),
                            PieChartSectionData(
                              value: (fee['remaining_fee'] as int).toDouble(),
                              title: 'Remaining',
                              titleStyle: TextStyle(color: Colors.white),
                              color: Colors.orange,
                              radius: 80,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeeRow("Total Fee:", "${fee['total_fee']}"),
                        _buildFeeRow("Total Paid:", "${fee['collected_fee']}"),
                        _buildFeeRow(
                            "Total Remaining:", "${fee['remaining_fee']}"),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        )),
  );
}

TableRow _buildTableRow(String first, String second, {bool isHeader = false}) {
  return TableRow(
    children: [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          first,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          second,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    ],
  );
}

Widget _buildClasswiseFeeCard(Map<String, dynamic> classData) {
  return Container(
    child: Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Class: ${classData['standard']} ${classData['division']}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("Total Fee: ${classData['total_fee']}"),
            Text("Total Paid: ${classData['collected_fee']}"),
            Text("Total Remaining: ${classData['remaining_fee']}"),
          ],
        ),
      ),
    ),
  );
}

void showFeeTypeDialog(BuildContext context, String collegeCode) {
  TextEditingController _feeTypeController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  List<String> stdList = [];
  List<String> divList = [];
  String? _selectedStd;
  String? _selectedDiv;

  Future<void> fetchClassData() async {
    final String apiUrl = "$allClasses?college_code=$collegeCode";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        Set<String> uniqueStd = {};
        Set<String> uniqueDiv = {};

        for (var item in data) {
          uniqueStd.add(item["standard"].toString());
          uniqueDiv.add(item["division"].toString());
        }

        stdList = uniqueStd.toList();
        divList = uniqueDiv.toList();

        _selectedStd = stdList.isNotEmpty ? stdList[0] : null;
        _selectedDiv = divList.isNotEmpty ? divList[0] : null;
      } else {
        print("Failed to load data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }


 Future<void> addFeeType() async {
    final String apiUrl = "$addFeeType?college_code=$collegeCode";
    
    Map<String, dynamic> requestBody = {
      "fee_type": _feeTypeController.text,
      "fee_amount": int.tryParse(_amountController.text) ?? 0,
      "std": _selectedStd,
      "division": _selectedDiv,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print("Message: ${responseData['message']}");
        print("Fee ID: ${responseData['fee_id']}");
                          Navigator.of(context).pop();

        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      } else {
        print("Failed to add fee. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding fee: $e");
    }
  }




  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder(
        future: fetchClassData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              title: Text("Loading..."),
              content: Center(child: CircularProgressIndicator()),
            );
          }
          return AlertDialog(
            title: Text("Add Fee Type"),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(context, "Fee Type:", "Enter Fee Type",
                      controller: _feeTypeController),
                  SizedBox(height: 10),
                  _buildTextField(context, "Amount: ", "Enter Amount",
                      controller: _amountController),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          context,
                          "Std: ",
                          "Select Standard",
                          stdList,
                          _selectedStd,
                          (String? newValue) {
                            _selectedStd = newValue;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdownField(
                          context,
                          "Div:",
                          "Select Division",
                          divList,
                          _selectedDiv,
                          (String? newValue) {
                            _selectedDiv = newValue;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                 onPressed: () async {
                  await addFeeType();
                  // Navigator.of(context).pop();
                },
                child: Text("Add Fee Type"),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildDropdownField(
    BuildContext context,
    String label,
    String hint,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 16),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          value: selectedValue,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}


Widget _buildTextField(BuildContext context, String label, String labelName,
    {bool obscureText = false,
    int maxLines = 1,
    TextEditingController? controller}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 16),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: labelName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ],
  );
}
