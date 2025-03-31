import 'dart:convert';
import 'dart:io';

import 'package:dgadmin/base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AddStudent extends StatefulWidget {
  final String collegecode;
  final String collegename;
  final String collegeimage;

  const AddStudent(
      {super.key,
      required this.collegecode,
      required this.collegename,
      required this.collegeimage});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
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



  Future<void> submitTeacherDetails() async {
    // Validate password and confirm password
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }
    if (pPasswordController.text != pconfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }
    // Prepare request body
    final body = {
      "profile_img": uploadedImageUrl ??
          "http://195.35.45.44:5001/images/Student/Default_image.png",
      "password": passwordController.text,
     "roll_no": rollnoController.text,
      "std": standard,
      "Name": nameController.text,
      "email": emailController.text,
      "mobile": mobileController.text,
      "college_code": widget.collegecode,
      "parent_id": pIdController.text.isNotEmpty ? pIdController.text : null,
      "division": division,
      "stud_dob": dobController.text,
      "fcm_token": null,
      "parentname": pnameController.text,
      "pmobile_no": pmobileController.text,
      "ppassword": pconfirmPasswordController.text,
      "profilephoto": puploadedImageUrl ??
          "http://195.35.45.44:5001/images/Student/Default_image.png",
      "address": pAddressController.text,
      "birth_date": pDOBController.text,
      "pemail": pemailController.text,
    };
    print(body);

    try {
      final response = await http.post(
        Uri.parse('$addstudent?college_code=${widget.collegecode}'),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );
      print(body);
      print(response.statusCode);
      // Check response status
      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        print(responseBody);
        if (responseBody['message'] == 'Student added successfully.') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to add teacher: ${responseBody['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
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
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/teacher.png', // Default Image
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
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
                      _buildTextField(context, 'Roll No:        ', 'Roll No',
                          controller: rollnoController,),
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
                      // Row(
                      //   children: [
                      //     Text(
                      //       'Class:              ',
                      //       style: TextStyle(fontSize: 16),
                      //     ),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Standard',
                      //         ['8', '9', '10', '11'],
                      //         value: standard,
                      //         onChanged: (val) =>
                      //             setState(() => standard = val),
                      //       ),
                      //     ),
                      //     SizedBox(width: 10),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Division',
                      //         ['A', 'B', 'C'],
                      //         value: division,
                      //         onChanged: (val) =>
                      //             setState(() => division = val),
                      //       ),
                      //     ),
                      //   ],
                      // ),

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
                              // Search Bar
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  width: screenWidth * 0.24,
                                  height: 40,
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        searchParents(value);
                                        showParentList = value
                                            .isNotEmpty; // Show list only if there is input
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search parent',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),

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

                          // Search Results Overlay (Positioned inside Stack)
                          if (showParentList)
                            Positioned(
                              top:
                                  35, // Adjust to position under the search bar
                              right:
                                  0, // Align to the right like the search bar
                              child: Container(
                                width: screenWidth * 0.24,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border(
                                    top: BorderSide(color: Colors.white),
                                    left: BorderSide(color: Colors.grey),
                                    right: BorderSide(color: Colors.grey),
                                    bottom: BorderSide(color: Colors.grey),
                                  ), // boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                                ),
                                child: ListView.builder(
                                  itemCount: parents.length,
                                  itemBuilder: (context, index) {
                                    final parent = parents[index];
                                    return ListTile(
                                      title: Text(parent["parentname"]),
                                      subtitle: Text(parent["pmobile_no"]),
                                      onTap: () async {
                                        setState(() {
                                          pIdController.text =
                                              parent["parent_id"];
                                          pnameController.text =
                                              parent["parentname"];
                                          pemailController.text =
                                              parent["email"];
                                          pmobileController.text =
                                              parent["pmobile_no"];
                                          pAddressController.text =
                                              parent["address"];
                                          pDOBController.text =
                                              parent["birth_date"];
                                          pPasswordController.text =
                                              parent["password"];
                                          pconfirmPasswordController.text =
                                              parent["password"];
                                          puploadedImageUrl =
                                              parent["profilephoto"];
                                          _parentprofileImage = null;
                                          showParentList = false;
                                        });

                                        await Future.delayed(
                                            Duration(milliseconds: 100));

                                        File downloadedImage = await urlToFile(
                                            parent["profilephoto"],
                                            parent["parent_id"]);

                                        setState(() {
                                          _parentprofileImage = downloadedImage;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
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
                                  pDOBController.text =
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
                      onPressed: submitTeacherDetails,
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
