import 'dart:convert';
import 'dart:io';

import 'package:dgadmin/base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Updatestudent extends StatefulWidget {
  final String collegecode;
  final String collegename;
  final String collegeimage;
  final String studentid;
  const Updatestudent(
      {super.key,
      required this.collegecode,
      required this.collegename,
      required this.collegeimage, required this.studentid});

  @override
  State<Updatestudent> createState() => _UpdatestudentState();
}

class _UpdatestudentState extends State<Updatestudent> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController rollnoController = TextEditingController();

  final TextEditingController pnameController = TextEditingController();
  final TextEditingController pemailController = TextEditingController();
  final TextEditingController pmobileController = TextEditingController();
  final TextEditingController pPasswordController = TextEditingController();
  final TextEditingController pAddressController = TextEditingController();
  final TextEditingController pDOBController = TextEditingController();

  final TextEditingController pconfirmPasswordController =
      TextEditingController();
  final TextEditingController pIdController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  String? standard;
  String? division;
  String? uploadedImageUrl;
  String? puploadedImageUrl;
  bool showParentList = false; // New state variable

  List<String> standards = [];
  Map<String, List<String>> divisionsByStandard = {};

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  File? _parentprofileImage;
  List<dynamic> parents = [];
  bool isLoading = false;

  Future<void> fetchStudentDetails() async {
    final String apiUrl =
        "$studentDetails?college_code=${widget.collegecode}&studentid=${widget..studentid}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          nameController.text = data['fullname'] ?? '';
          standard = data['standard'] ?? '';
          division = data['division'] ?? '';
          dobController.text = data['dob'] ?.split('T')[0] ?? '';
          mobileController.text = data['mobile'] ?? '';
          emailController.text = data['email'] ?? '';
          passwordController.text = data['spassword'] ?? '';
          confirmPasswordController.text = data['spassword'] ?? '';
          uploadedImageUrl = data['profilephoto'] ?? '';

          if (data.containsKey('parent')) {
            pIdController.text = data['parent']['parentid'];
            pnameController.text = data['parent']['parentname'] ?? '';
            pmobileController.text = data['parent']['parentmobile'] ?? '';
            pemailController.text = data['parent']['parentemail'] ?? '';
            pAddressController.text = data['parent']['parentaddress'] ?? '';
            pDOBController.text = data['parent']['parentbirthdate'] ?.split('T')[0] ?? '';
            pPasswordController.text = data['parent']['parentpassword'] ?? '';
            pconfirmPasswordController.text =
                data['parent']['parentpassword'] ?? '';

            puploadedImageUrl = data['parent']['parentprofilephoto'] ?? '';
          }
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

Future<void> updateStudentDetails() async {
  final String apiUrl =
      "$updateStudent/${widget.studentid}?college_code=${widget.collegecode}";

  final Map<String, dynamic> studentData = {
    "fullname": nameController.text,
    "standard": standard,
    "division": division,
    "dob": dobController.text.split('T')[0],
    "mobile": mobileController.text,
    "email": emailController.text,
    "spassword": passwordController.text,
    "profilephoto": uploadedImageUrl,
    "parent": {
            "parentid": pIdController.text,

      "parentname": pnameController.text,
      "parentmobile": pmobileController.text,
      "parentemail": pemailController.text,
      "parentprofilephoto": puploadedImageUrl,
      "parentaddress": pAddressController.text,
      "parentbirthdate": pDOBController.text.split('T')[0],
      "parentpassword": pPasswordController.text,
    }
  };
print(studentData);
  try {
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(studentData),
    );

    if (response.statusCode == 200) {
      print("Student details updated successfully");
    } else {
      print(response.body);
      print("Failed to update student details: ${response.statusCode}");
    }
  } catch (e) {
    print("Error updating student details: $e");
  }
}




  Future<File> urlToFile(String imageUrl, String parentId) async {
    final response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/profile_$parentId.jpg'; // Unique filename
    final file = File(filePath);
    await file.writeAsBytes(response.data);

    return file;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Upload the image and get the URL
      String? imageUrl = await _uploadImage(_profileImage!);

      if (imageUrl != null) {
        setState(() {
          uploadedImageUrl = imageUrl; // Store the uploaded image URL
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image')),
        );
      }
    }
  }

  Future<void> _pickImage1() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _parentprofileImage = File(pickedFile.path);
      });

      // Upload the image and get the URL
      String? imageUrl1 = await _uploadImage(_profileImage!);

      if (imageUrl1 != null) {
        setState(() {
          puploadedImageUrl = imageUrl1; // Store the uploaded image URL
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image')),
        );
      }
    }
  }

  Future<void> fetchClasses() async {
    final url = Uri.parse(
        "$allClasses?college_code=${widget.collegecode}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        Map<String, List<String>> tempDivisions = {};
        Set<String> tempStandards = {};

        for (var item in data) {
          String std = item['standard'];
          String div = item['division'];

          tempStandards.add(std);
          if (!tempDivisions.containsKey(std)) {
            tempDivisions[std] = [];
          }
          tempDivisions[std]?.add(div);
        }

        setState(() {
          standards = tempStandards.toList();
          divisionsByStandard = tempDivisions;
        });
      } else {
        print("Failed to load classes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching classes: $e");
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    var uploadUrl = Uri.parse('http://195.35.45.44:5001/upload?folder=Student');

    var request = http.MultipartRequest('POST', uploadUrl);

    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    request.headers.addAll({
      "Content-Type": "multipart/form-data",
    });

    print('Uploading image...');

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Response Status: ${response.statusCode}');
      print('Response Body: $responseBody'); // Debug response

      if (response.statusCode == 200) {
        var responseData = jsonDecode(responseBody);
        if (responseData['message'] == 'Image uploaded successfully') {
          String imageUrl = responseData['imageUrl'];

          // Check if the returned URL is missing port 5001
          if (!imageUrl.contains(":5001")) {
            imageUrl = imageUrl.replaceFirst(
                "http://195.35.45.44", "http://195.35.45.44:5001");
          }

          print('Corrected Image URL: $imageUrl');
          return imageUrl;
        } else {
          print('Server returned error: ${responseData['message']}');
        }
      } else {
        print('Failed to upload image. HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during image upload: $e');
    }

    return null;
  }

  Future<void> searchParents(String mobileNumber) async {
    if (mobileNumber.length < 2) return; // Prevent unnecessary API calls

    setState(() {
      isLoading = true;
    });

    final String apiUrl =
        "$parentmobile?mobile_no=$mobileNumber&college_code=${widget.collegecode}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(response.body);
        if (data["success"]) {
          setState(() {
            parents = data["parents"];
            showParentList =
                parents.isNotEmpty; // Show list only if parents found
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    fetchStudentDetails();

    fetchClasses();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.2;

    return Scaffold(
      backgroundColor: Colors.grey[200],
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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft, // Move to top right
                    child: CircleAvatar(
                      backgroundColor:
                          Colors.white, // Background color of the circle
                      radius: 24, // Adjust size as needed
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildSection(
                    context,
                    'Student Details',
                    [
                     ClipOval(
                                child: _profileImage != null
                                    ? Image.file(
                                        _profileImage!,
                                        key: UniqueKey(),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : uploadedImageUrl != null
                                        ? Image.network(
                                            "$uploadedImageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}",
                                            key: UniqueKey(),
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/teacher.png',
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                              ),







                      // ClipOval(
                      //   child: _profileImage != null
                      //       ? Image.file(
                      //           _profileImage!,
                      //           width: 120,
                      //           height: 120,
                      //           fit: BoxFit.cover,
                      //         )
                      //       : Image.asset(
                      //           'assets/teacher.png', // Default Image
                      //           width: 120,
                      //           height: 120,
                      //           fit: BoxFit.cover,
                      //         ),
                      // ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.add_a_photo),
                        label: Text('Add Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(context, 'Name:           ', 'Name',
                          controller: nameController),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                context, 'Email:            ', 'Email',
                                controller: emailController),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                                context, 'Mobile No:', 'Mobile No',
                                controller: mobileController),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _buildTextField(context, 'Address:        ', 'Address',
                          controller: rollnoController, maxLines: 3),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );

                                if (pickedDate != null) {
                                  String formattedDate =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  dobController.text =
                                      formattedDate; // Update the TextField with selected date
                                }
                              },
                              child: AbsorbPointer(
                                // Prevent manual text input
                                child: _buildTextField(
                                  context,
                                  'DOB:             ',
                                  'Date Of Birth',
                                  controller: dobController,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Class:              ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              hint: Text('Select Standard'),
                              value: standard,
                              items: standards.map((std) {
                                return DropdownMenuItem(
                                  value: std,
                                  child: Text(std),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  standard = val;
                                  division = null;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              hint: Text('Select Division'),
                              value: division,
                              items: standard != null &&
                                      divisionsByStandard[standard] != null
                                  ? divisionsByStandard[standard]!.map((div) {
                                      return DropdownMenuItem(
                                        value: div,
                                        child: Text(div),
                                      );
                                    }).toList()
                                  : [],
                              onChanged: (val) {
                                setState(() {
                                  division = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                context, 'Password:      ', 'Password',
                                controller: passwordController,
                                obscureText: true),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(context, 'Confirm Password:',
                                'Confirm Password',
                                controller: confirmPasswordController,
                                obscureText: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildSection(
                    context,
                    'Parents Details',
                    [
                      Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile Image
                              ClipOval(
                                child: _parentprofileImage != null
                                    ? Image.file(
                                        _parentprofileImage!,
                                        key: UniqueKey(),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : puploadedImageUrl != null
                                        ? Image.network(
                                            "$puploadedImageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}",
                                            key: UniqueKey(),
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/teacher.png',
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton.icon(
                                onPressed: _pickImage1,
                                icon: Icon(Icons.add_a_photo),
                                label: Text('Add Profile'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Align items vertically
                        children: [
                          Text(
                            "Parent Id:          ", // Label text
                            style: TextStyle(
                                fontSize: 16), // Adjust font size if needed
                          ),
                          const SizedBox(
                              width: 8), // Spacing between Text and TextField
                          Expanded(
                            child: TextField(
                              controller:
                                  pIdController, // Assign the controller
                              readOnly: true, // Make it non-editable
                              decoration: InputDecoration(
                                labelText:
                                    "Parent Id", // Placeholder inside the text field
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _buildTextField(
                          context, 'Parent Name:    ', 'Parent Name',
                          controller: pnameController),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                context, 'Parent Email:     ', 'parent Email',
                                controller: pemailController),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(context, 'Parent Mobile No:',
                                'Parent Mobile No',
                                controller: pmobileController),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _buildTextField(
                          context, ' Parent Address:', 'Parent Address',
                          controller: pAddressController, maxLines: 3),
                      SizedBox(height: 10),
                      Row(
                        children: [
                                                    Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );

                                if (pickedDate != null) {
                                  String formattedDate =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  dobController.text =
                                      formattedDate; // Update the TextField with selected date
                                }
                              },
                              child: AbsorbPointer(
                                // Prevent manual text input
                                child: _buildTextField(
                                  context,
                                  'Parent DOB:      ',
                                  'Date Of Birth',
                                  controller: pDOBController,
                                ),
                              ),
                            ),
                          ),
                          // Expanded(
                          //   child: _buildTextField(
                          //       context, 'Parent DOB:      ', 'Date Of Birth',
                          //       controller: pDOBController),
                          // ),
                          SizedBox(width: 10),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                context, 'Password:         ', 'Password',
                                controller: pPasswordController,
                                obscureText: true),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(context, 'Confirm Password:',
                                'Confirm Password',
                                controller: pconfirmPasswordController,
                                obscureText: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                                            onPressed: updateStudentDetails,

                      // onPressed: () {}, //submitTeacherDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(fontSize: screenWidth * 0.02),
                      ),
                      child: Text('Submit'),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.025,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, String labelName,
      {bool obscureText = false,
      int maxLines = 1,
      TextEditingController? controller}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16), // Adjust font size as needed
        ),
        const SizedBox(width: 8), // Add some spacing between Text and TextField
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: labelName,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, String label, List<String> items,
      {String? value, ValueChanged<String?>? onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}
