import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../widgets/custom_drawer.dart';
import '../models/user_model.dart';
import 'InsertDetailsPageNo.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    print("UserInfoPage: initState called.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserInfo();
    });
  }

  Future<void> _fetchUserInfo() async {
    print("UserInfoPage: _fetchUserInfo started.");

    // Access the UserModel from Provider
    final userModel = Provider.of<UserModel>(context, listen: false);
    final phoneNumber = userModel.phoneNumber.trim();
    final currentRole = userModel.role;

    print("UserInfoPage: Retrieved phone number: '$phoneNumber'");
    print("UserInfoPage: Retrieved role: '$currentRole'");

    if (phoneNumber.isEmpty) {
      print("UserInfoPage: Phone number is empty. Cannot fetch user info.");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        'https://legaryan.heama-soft.com/get_user_info.php?phone_number=$phoneNumber');
    print("UserInfoPage: API URL - $url");

    try {
      final response = await http.get(url);
      print("UserInfoPage: HTTP GET Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("UserInfoPage: Received response body: ${response.body}");
        final jsonResponse = json.decode(response.body);
        print("UserInfoPage: Parsed JSON Response: $jsonResponse");

        if (jsonResponse['success'] == true) {
          if (jsonResponse['data'] == null) {
            print("UserInfoPage: 'data' field is null in JSON response.");
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
            return;
          }
          setState(() {
            _userInfo = Map<String, dynamic>.from(jsonResponse['data']);
            _isLoading = false;
            _hasError = false;
          });
          print("UserInfoPage: User info fetched: $_userInfo");

          // Update UserModel with fetched data while retaining the role
          userModel.setUser(
            _userInfo!['full_name'] ?? '',
            _userInfo!['phone_number'] ?? '',
            currentRole,
            city: _userInfo!['city'] ?? '',
          );
          print("UserInfoPage: UserModel updated with fetched data.");
        } else {
          print("UserInfoPage: API returned success=false.");
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      } else {
        print(
            "UserInfoPage: HTTP GET failed with status: ${response.statusCode}");
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      print("UserInfoPage: Exception caught: $error");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("UserInfoPage: build called.");
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(isArabic),
        drawer: CustomDrawer(),
        body: _buildBody(isArabic),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isArabic) {
    print("UserInfoPage: Building AppBar.");
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        isArabic ? "معلومات المستخدم" : 'زانیاری بەکارھێنەر',
        style: TextStyle(
          fontFamily: 'NotoKufi',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      iconTheme: IconThemeData(color: Colors.white),
    );
  }

  Widget _buildBody(bool isArabic) {
    print("UserInfoPage: Building Body.");
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blueAccent.withOpacity(0.1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _isLoading
          ? _buildLoadingIndicator()
          : _hasError
              ? _buildErrorMessage(isArabic)
              : _buildUserInfoContent(isArabic),
    );
  }

  Widget _buildLoadingIndicator() {
    print("UserInfoPage: Building Loading Indicator.");
    return Center(
      child: CircularProgressIndicator(color: Colors.deepPurple),
    );
  }

  Widget _buildErrorMessage(bool isArabic) {
    print("UserInfoPage: Building Error Message.");
    return Center(
      child: Text(
        isArabic
            ? "خطأ: لم يتم العثور على المعلومات."
            : "هەڵە: زانیاری نەدۆزرایەوە.",
        style: TextStyle(
          fontFamily: 'NotoKufi',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _buildUserInfoContent(bool isArabic) {
    print("UserInfoPage: Building User Info Content.");
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          _buildLogo(),
          _buildWelcomeMessage(isArabic),
          _buildUserInfoCard(isArabic),
          _buildThankYouMessage(isArabic),
          _buildAddMoreDataButton(isArabic),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    print("UserInfoPage: Building Logo.");
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          height: 120,
          width: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("UserInfoPage: Error loading logo: $error");
            return Icon(Icons.error, size: 120, color: Colors.red);
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildWelcomeMessage(bool isArabic) {
    print("UserInfoPage: Building Welcome Message.");
    return Column(
      children: [
        Text(
          isArabic ? "شكراً للتسجيل!" : 'سوپاس بۆ تۆمارکردن!',
          style: TextStyle(
            fontFamily: 'NotoKufi',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          isArabic ? "معلومات المستخدم:" : 'زانیاری تایبەتی بەکارھێنەر:',
          style: TextStyle(
            fontFamily: 'NotoKufi',
            fontSize: 18,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(bool isArabic) {
    print("UserInfoPage: Building User Info Card.");
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(isArabic ? "الاسم الكامل:" : 'ناوی تەواو:',
                  _userInfo!['full_name'] ?? 'N/A'),
              Divider(),
              _buildInfoRow(isArabic ? "رقم الهاتف:" : 'ژمارەی مۆبایل:',
                  _userInfo!['phone_number'] ?? 'N/A'),
              Divider(),
              _buildInfoRow(
                  isArabic ? "المدينة:" : 'شار:', _userInfo!['city'] ?? 'N/A'),
              Divider(),
              _buildInfoRow(isArabic ? "نوع العمل:" : 'جۆری کار:',
                  _userInfo!['type_of_work'] ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThankYouMessage(bool isArabic) {
    print("UserInfoPage: Building Thank You Message.");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        isArabic
            ? "شكراً للتسجيل! سنتواصل معك قريباً لإنهاء عملك."
            : 'سوپاس بۆ تۆمارکردن! ئێمە پەیوەندی پێوە دەکەین لە نزیکترین کاتدا بۆ تەواوکردنی کارەکەت.',
        style: TextStyle(
          fontFamily: 'NotoKufi',
          fontSize: 18,
          color: Colors.black87,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAddMoreDataButton(bool isArabic) {
    print("UserInfoPage: Building Add More Data Button.");
    final userModel = Provider.of<UserModel>(context, listen: false);
    final phoneNumber = userModel.phoneNumber;
    final city = userModel.city;

    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InsertDetailsPageNo(
              phoneNumber: phoneNumber,
              city: city,
            ),
          ),
        );
      },
      icon: Icon(Icons.add, color: Colors.white),
      label: Text(
        isArabic ? "إضافة المزيد من المعلومات" : 'زیادکردنی زانیاری زیاتر',
        style: TextStyle(
          fontFamily: 'NotoKufi',
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    print("UserInfoPage: Building Info Row - $label $value");
    return Row(
      children: [
        Icon(Icons.info_outline, color: Colors.deepPurple, size: 24),
        SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label ',
              style: TextStyle(
                fontFamily: 'NotoKufi',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: 'NotoKufi',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
