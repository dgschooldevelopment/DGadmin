import 'dart:convert';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Certificates extends StatefulWidget {
  final String collegeCode;
  const Certificates({super.key, required this.collegeCode});

  @override
  State<Certificates> createState() => _CertificatesState();
}

class _CertificatesState extends State<Certificates> {
  String? selectStartYear;
  String? selectEndYear;
  List<String?> selectfile = [];

  bool isloading = false;
  TextEditingController searchController = TextEditingController();

  List<String> file = ["Bonafide", "Result", "Attendance Sheet"];
  List<String> year = [for (int i = 2000; i <= 2027; i++) i.toString()];
  List<Map<String, String>> studData = [];

  Future<void> fetchStudents() async {
    setState(() {
      isloading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          "$getStudentsByYear?college_code=${widget.collegeCode}&academicYear=2025"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("API Response: ${response.body}");

        if (data is Map && data.containsKey('data')) {
          List students = data['data'];

          setState(() {
            studData = students.map<Map<String, String>>((e) {
              return {
                'studentid': e['studentid'] ?? "Unknown",
                'Name': e['Name'] ?? "Unknown",
                'roll_no': e['roll_no'] ?? "N/A",
                'std': e['std'] ?? "N/A",
                'email': e['email'] ?? "N/A",
                'profile_img':
                    e['profile_img'] ?? "http://default-image-url.com",
              };
            }).toList();

            // Initialize selectfile list with the same length as studData
            selectfile =
                List<String?>.filled(studData.length, null, growable: true);
          });

          print("studData length: ${studData.length}");
          print("selectfile length: ${selectfile.length}");
        } else {
          throw Exception("Invalid data format");
        }
      } else {
        throw Exception("Failed to load students: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching students: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // SizedBox(width: 250, child: sider()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.blue,
                    ),
                    child: Center(
                        child: Text(
                      "Report",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      _buildDropdown("Start Year", selectStartYear, (value) {
                        setState(() {
                          selectStartYear = value;
                        });
                      }),
                      const SizedBox(width: 20),
                      const Text("To",
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                      const SizedBox(width: 20),
                      _buildDropdown("End Year", selectEndYear, (value) {
                        setState(() {
                          selectEndYear = value;
                        });
                      }),
                      const SizedBox(width: 20),
                      _buildSearchBox(),
                      const SizedBox(width: 20),
                      ElevatedButton(
                          onPressed: () async {
                            for (int i = 0; i < studData.length; i++) {
                              final studentName =
                                  studData[i]['Name'] ?? "Unknown";

                              for (String fileType in file) {
                                await _generateAndDownloadFile(
                                    fileType, studentName);
                              }
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "All files have been downloaded successfully!")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(140, 40),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text("Download All"))
                    ],
                  ),
                  const SizedBox(height: 20),
                  isloading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: studData.length,
                                  itemBuilder: (context, index) {
                                    final student = studData[index];
                                    return Card(
                                      elevation: 5,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(7),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ListTile(
                                                title: Text(student['Name'] ??
                                                    "Unknown"),
                                                leading: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor:
                                                      Colors.black45,
                                                  backgroundImage: student[
                                                                  'profile_img'] !=
                                                              null &&
                                                          student['profile_img']!
                                                              .isNotEmpty
                                                      ? NetworkImage(student[
                                                          'profile_img']!)
                                                      : const AssetImage(
                                                              'assets/images/default_profile.png')
                                                          as ImageProvider, // Use a local default image if null
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                width: 200, // Set width
                                                height: 50, // Set height
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: selectfile[
                                                        index], // Ensure it holds the selected file type
                                                    hint: const Text(
                                                        "Select File"),
                                                    isExpanded: true,
                                                    items: file
                                                        .map((String fileName) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: fileName,
                                                        child: Text(fileName),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        selectfile[index] =
                                                            newValue; // Assign selected file type
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              width: 200,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    //  backgroundColor: Colors.brown,

                                                    ),
                                                onPressed: () {
                                                  if (selectfile[index] ==
                                                      null) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              "Please select a file type!")),
                                                    );
                                                    return;
                                                  }
                                                  _generateAndDownloadFile(
                                                      selectfile[index]!,
                                                      student['Name'] ??
                                                          "Unknown");
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            " file downloaded successfully!")),
                                                  );
                                                },
                                                child: const Text("Download"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String hint, String? value, ValueChanged<String?> onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: const TextStyle(color: Colors.white)),
          value: value,
          dropdownColor: Colors.blue,
          style: const TextStyle(color: Colors.white),
          items: year.map((yearItem) {
            return DropdownMenuItem<String>(
              value: yearItem,
              child:
                  Text(yearItem, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.blue),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _generateAndDownloadFile(
    String? fileType, String studentName) async {
  if (fileType == null) {
    print("Please select a file type!");
    return;
  }

  try {
    final pdf = pw.Document();

    // Generate different content based on fileType
    if (fileType == "Bonafide") {
      pdf.addPage(generateBonafideCertificate(studentName));
    } else if (fileType == "Result") {
      pdf.addPage(_generateResultCertificate(studentName));
    } else if (fileType == "Attendance Sheet") {
      pdf.addPage(_generateAttendanceSheet(studentName));
    }

    // Get the directory for storing files
    Directory dir = await getApplicationDocumentsDirectory();

    // Create a new folder "Reports" inside the documents directory
    Directory reportsDir = Directory("${dir.path}/Reports");
    if (!await reportsDir.exists()) {
      await reportsDir.create(
          recursive: true); // Create the directory if it does not exist
    }

    // Define file path inside the "Reports" folder
    String filePath = "${reportsDir.path}/${fileType}_$studentName.pdf";

    // Save PDF to the new folder
    File file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print("File saved at: $filePath");
  } catch (e) {
    print("Error saving file: $e");
  }
}

pw.Page generateBonafideCertificate(String studentName) {
  return pw.Page(
    build: (pw.Context context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text("BONAFIDE CERTIFICATE",
            style: pw.TextStyle(fontSize: 21, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text("ACADEMIC YEAR - 20XX-20XX",
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 30),
        pw.Text(
          "This is to certify that Mr./Ms.    ${studentName}     S/O or D/O Mr./Ms.  "
          "bearing Registration/Admission number _____ is a student of __ year  "
          "He/She is a Bonafide student of ______ with AISHE no____.",
          style: pw.TextStyle(fontSize: 17),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 170),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              children: [
                pw.Text("SIGNATURE OF STUDENT"),
                pw.Text("Mob. No_______ "),
              ],
            ),
            pw.Column(
              children: [
                pw.Text("SIGNATURE OF REGISTRAR/PRINCIPAL/DEAN"),
                pw.Text("_______"),
              ],
            )
          ],
        ),
      ],
    ),
  );
}

// Function to generate Result Certificate
pw.Page _generateResultCertificate(String studentName) {
  return pw.Page(
    build: (pw.Context context) => pw.Center(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Certificate Title
          pw.Text(
            "RESULT CERTIFICATE",
            style: pw.TextStyle(fontSize: 21, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          // Student Name
          pw.Text(
            "Name: $studentName",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),

          // Table Header
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("Subject",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("Marks",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("Grade",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              // Subject-wise Data
              // for (var subject in subjects)
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("Marathi"),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(90.toString()),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("A"),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("Hindi"),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(70.toString()),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("B"),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("English"),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(80.toString()),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("A"),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("science"),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(92.toString()),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("A+"),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("Geography"),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(90.toString()),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text("A"),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 90),

          // Signature
          pw.Text(
            "SIGNATURE OF PRINCIPAL",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

// Function to generate Attendance Sheet
pw.Page _generateAttendanceSheet(String studentName) {
  return pw.Page(
    build: (pw.Context context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text("ATTENDANCE SHEET",
            style: pw.TextStyle(fontSize: 21, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text("Name: $studentName",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 30),
        pw.Text("Attendance record for the academic year."),
        pw.Table(border: pw.TableBorder.all(), children: [
          pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey),
              children: [
                pw.Text("          Month"),
                pw.Text("      Present"),
                pw.Text("Absent"),
                pw.Text("Total"),
                pw.Text("Percentage"),
              ]),
          pw.TableRow(children: [
            pw.Text("January"),
            pw.Text("12"),
            pw.Text("2"),
            pw.Text("14"),
            pw.Text("88.57%"),
          ]),
          pw.TableRow(children: [
            pw.Text("February"),
            pw.Text("15"),
            pw.Text("3"),
            pw.Text("15"),
            pw.Text("100.00%"),
          ]),
          pw.TableRow(children: [
            pw.Text("March"),
            pw.Text("10"),
            pw.Text("4"),
            pw.Text("14"),
            pw.Text("85.71%"),
          ]),
          pw.TableRow(children: [
            pw.Text("Total"),
            pw.Text("45"),
            pw.Text("15"),
            pw.Text("60"),
            pw.Text("91.67%"),
          ]),
        ]),
        pw.SizedBox(height: 200),
        pw.Text("SIGNATURE OF ATTENDANCE OFFICER"),
      ],
    ),
  );
}
