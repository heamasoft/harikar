import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../widgets/custom_drawer.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  ProfileScreen({
    required this.userName,
    required this.phoneNumber,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final url = Uri.parse('https://legaryan.heama-soft.com/get_user_data.php');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone_number": widget.phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _isLoading = false;
            userData = data['data'];
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'نەمانە';
    }
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isArabic ? "الملف الشخصي" : 'پەڕەی کەسی',
            style: TextStyle(fontFamily: 'NotoKufi', color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(
                    child: Text(
                      isArabic
                          ? "حدث خطأ، يرجى المحاولة مرة أخرى."
                          : 'هەڵە ڕوویدا، تکایە دووبارە هەوڵ بدە.',
                      style: TextStyle(
                        fontFamily: 'NotoKufi',
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // User Information
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple, Colors.blueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic
                                    ? "اسم المستخدم: ${widget.userName}"
                                    : 'ناوی بەکارهێنەر: ${widget.userName}',
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                isArabic
                                    ? "رقم الهاتف: ${widget.phoneNumber}"
                                    : 'ژمارەی تەلەفۆن: ${widget.phoneNumber}',
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // User Details Section
                        Expanded(
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    isArabic ? "المعلومات" : 'زانیاریەکان',
                                    style: TextStyle(
                                      fontFamily: 'NotoKufi',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ListTile(
                                    leading: Icon(Icons.monetization_on,
                                        color: Colors.green),
                                    title: Text(
                                      isArabic ? "مبلغ الدفع" : 'بڕی پارەدان',
                                      style: TextStyle(
                                        fontFamily: 'NotoKufi',
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${userData['payment_amount'] ?? (isArabic ? "غير متوفر" : "نەمانە")} ${isArabic ? "دينار" : "دینار"}',
                                      style: TextStyle(
                                        fontFamily: 'NotoKufi',
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      userData['is_approved'] == 1
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: userData['is_approved'] == 1
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    title: Text(
                                      isArabic ? "حالة التفعيل" : 'دۆخی چالاکی',
                                      style: TextStyle(
                                        fontFamily: 'NotoKufi',
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      userData['is_approved'] == 1
                                          ? (isArabic ? "مفعل" : 'چالاکە')
                                          : (isArabic
                                              ? "غير مفعل"
                                              : 'ناچالاکە'),
                                      style: TextStyle(
                                        fontFamily: 'NotoKufi',
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.date_range,
                                        color: Colors.blueAccent),
                                    title: Text(
                                      isArabic
                                          ? "تاريخ الانتهاء"
                                          : 'بەرواری بەسەرهات',
                                      style: TextStyle(
                                        fontFamily: 'NotoKufi',
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formatDate(
                                          userData['subscription_expiry']),
                                      style: TextStyle(
                                        fontFamily: 'NotoKufi',
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
