// lib/screens/add_category_screen.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // For Uint8List

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_drawer.dart';
import 'package:flutter/foundation.dart'; // To use kIsWeb
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  List<dynamic> _categories = [];
  XFile? _selectedImage; // For image selection

  // Flag to ensure fetching is done only once in didChangeDependencies
  bool _didFetchCategories = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchCategories) {
      _fetchCategories();
      _didFetchCategories = true;
    }
  }

  // Fetch Categories
  Future<void> _fetchCategories() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final url = Uri.parse('https://legaryan.heama-soft.com/get_categories.php');

    try {
      final response = await http.get(url);
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        setState(() {
          _categories = responseData['data'];
        });
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage(
          isArabic ? "خطأ في جلب الفئات: $e" : "هەڵە لە هەڵگرتنی کارەکان: $e");
    }
  }

  // Pick Image
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _addCategory() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String categoryName = _categoryController.text.trim();

    // Validation
    if (categoryName.isEmpty) {
      _showMessage(isArabic ? "يجب إدخال اسم الفئة." : "ناوی کار پێویستە.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://legaryan.heama-soft.com/add_category.php');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['category_name'] = categoryName;

      // Add image file if selected
      if (_selectedImage != null) {
        if (kIsWeb) {
          final bytes = await _selectedImage!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'image', // Field name for the image
              bytes,
              filename: _selectedImage!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image', // Field name for the image
              _selectedImage!.path,
            ),
          );
        }
      }

      // Send the request
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("Server Response: $responseBody");

      final decodedResponse = jsonDecode(responseBody);

      if (decodedResponse['status'] == 'success') {
        _showMessage(decodedResponse['message'], success: true);
        _categoryController.clear();
        setState(() {
          _selectedImage = null;
        });
        _fetchCategories(); // Refresh categories
      } else {
        _showMessage(decodedResponse['message']);
      }
    } catch (e) {
      print("Error: $e");
      _showMessage(isArabic ? "حدث خطأ: $e" : "هەڵە ڕویدا: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Delete Category
  Future<void> _deleteCategory(String id) async {
    final url =
        Uri.parse('https://legaryan.heama-soft.com/delete_category.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        _showMessage(responseData['message'], success: true);
        _fetchCategories();
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage("هەڵە لە سڕینەوەی کارەکان: $e");
    }
  }

  // Show Confirmation Dialog
  Future<void> _confirmDelete(String id) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool confirmed = await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isArabic ? "تأكيد" : 'پشتڕاستکردنەوە'),
          content: Text(isArabic
              ? "هل أنت متأكد من حذف الفئة؟"
              : 'دڵنیایت کە جۆری کارەکە بسڕیتەوە؟'),
          actions: [
            TextButton(
              child: Text(isArabic ? "لا" : 'نەخێر',
                  style: TextStyle(color: Colors.deepPurple)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(isArabic ? "نعم" : 'بەڵێ',
                  style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      _deleteCategory(id);
    }
  }

  // Show Message
  void _showMessage(String message, {bool success = false}) {
    final snackBar = SnackBar(
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoKufi',
          ),
        ),
      ),
      backgroundColor: success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Build Each Category Card
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    bool isActive = int.tryParse(category['is_active'].toString()) == 1;
    String imageUrl =
        category['image_url'] != null && category['image_url'].isNotEmpty
            ? 'https://legaryan.heama-soft.com/uploads/${category['image_url']}'
            : '';

    return Container(
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl,
                    height: 80, width: 80, fit: BoxFit.contain)
                : Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
          ),
          SizedBox(height: 8),
          Text(
            category['name'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Spacer(),
          Divider(height: 1, color: Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () => _showEditDialog(category),
                  iconSize: 20,
                ),
                IconButton(
                  icon: Icon(
                    isActive ? Icons.check_circle : Icons.cancel,
                    color: isActive ? Colors.green : Colors.red,
                  ),
                  onPressed: () => _toggleCategoryStatus(category['id']),
                  iconSize: 20,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(category['id'].toString()),
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCategoryStatus(String id) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final url =
        Uri.parse('https://legaryan.heama-soft.com/toggle_category_status.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"id": id},
      );

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        _showMessage(responseData['message'], success: true);
        _fetchCategories();
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage(isArabic ? "حدث خطأ: $e" : "هەڵە ڕویدا: $e");
    }
  }

  void _showEditDialog(Map<String, dynamic> category) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final TextEditingController _editNameController =
        TextEditingController(text: category['name']);
    XFile? _newImage;
    Uint8List? _imageBytes; // For Web

    Future<void> _pickNewImage() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _newImage = pickedFile;
        });
        if (kIsWeb) {
          _imageBytes = await pickedFile.readAsBytes();
        }
      }
    }

    Future<void> _updateCategory() async {
      final bool isArabic =
          Localizations.localeOf(context).languageCode == 'ar';
      final String updatedName = _editNameController.text.trim();

      if (updatedName.isEmpty) {
        _showMessage(isArabic ? "يجب إدخال اسم الفئة." : "ناوی پۆلێ پێویستە.");
        return;
      }

      final updateUrl =
          Uri.parse('https://legaryan.heama-soft.com/update_category.php');
      var request = http.MultipartRequest('POST', updateUrl);
      request.fields['action'] = 'update_category';
      request.fields['id'] = category['id'].toString();
      request.fields['name'] = updatedName;

      if (_newImage != null) {
        if (kIsWeb) {
          request.files.add(
            http.MultipartFile.fromBytes('image', _imageBytes!,
                filename: _newImage!.name),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('image', _newImage!.path),
          );
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Server Response: $responseBody");

      final decodedResponse = jsonDecode(responseBody);

      if (decodedResponse['status'] == 'success') {
        _showMessage(decodedResponse['message'], success: true);
        _fetchCategories();
        Navigator.of(context).pop();
      } else {
        _showMessage(decodedResponse['message'], success: false);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(isArabic ? "تحديث الفئة" : 'نوێکردنەوەی جۆری کار'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _editNameController,
                      decoration: InputDecoration(
                        labelText: isArabic ? "اسم الفئة" : 'ناوی کارەکە',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        await _pickNewImage();
                        setDialogState(() {});
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image: _newImage != null
                              ? DecorationImage(
                                  image: kIsWeb
                                      ? MemoryImage(_imageBytes!)
                                      : FileImage(File(_newImage!.path))
                                          as ImageProvider,
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: NetworkImage(
                                    'https://legaryan.heama-soft.com/uploads/${category['image_url']}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: _newImage == null
                            ? Center(
                                child: Icon(Icons.add_a_photo,
                                    size: 40, color: Colors.grey),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isArabic ? "إلغاء" : 'پەشیمان بوون'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple),
                  onPressed: _updateCategory,
                  child: Text(
                    isArabic ? "تحديث" : 'نوێکردنەوە',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = Provider.of<UserModel>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            isArabic ? "إضافة فئة جديدة" : 'زیادکردنی کارێ نوێ',
            style: TextStyle(color: Colors.white, fontFamily: 'NotoKufi'),
          ),
        ),
        drawer: CustomDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _categoryController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      labelText: isArabic ? "اسم الفئة" : 'ناوی جۆری کار',
                      prefixIcon:
                          Icon(Icons.category, color: Colors.deepPurple),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(_selectedImage!.path)
                                    : FileImage(File(_selectedImage!.path))
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _selectedImage == null
                          ? Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.grey),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    onPressed: _isLoading ? null : _addCategory,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isArabic ? "إضافة" : 'زیادکردن',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'NotoKufi'),
                          ),
                  ),
                ],
              ),
            ),
            Divider(height: 20),
            Expanded(
              child: _categories.isEmpty
                  ? Center(
                      child: Text(
                        isArabic
                            ? "لم يتم العثور على فئة."
                            : 'هیچ کارەك نەدۆزرایەوە.',
                        style: TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth > 600 ? 4 : 2;
                        return GridView.builder(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryCard(_categories[index]);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
