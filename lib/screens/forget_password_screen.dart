import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters

class ForgetPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: TextDirection.rtl, // Enforce RTL layout
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          iconTheme: IconThemeData(
            color: Colors.white, // AppBar icon color
          ),
          title: Text(
            isArabic ? "هل نسيت كلمة السر؟" : 'وشەی نهێنی لەبیرت چووە؟',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'NotoKufi',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instruction Text
                  Text(
                    isArabic
                        ? "يرجى إدخال رقم هاتفك لإرسال رمز التحقق."
                        : 'تکایە ژمارەی مۆبایلەکەت بنووسە بۆ ناردنی کۆدی نوسینەوە.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'NotoKufi',
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Phone Number Input
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Allow only numbers
                    ],
                    decoration: InputDecoration(
                      labelText: isArabic ? "رقم الهاتف" : 'ژمارەی مۆبایل',
                      labelStyle: TextStyle(fontFamily: 'NotoKufi'),
                      prefixIcon: Icon(Icons.phone, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Send Code Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Logic to handle password reset request (sending a code)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic
                                ? "تم إرسال رمز التحقق إلى رقم الهاتف."
                                : 'کۆدی نوسینەوە بۆ ژمارەیەکە نێردرا.',
                            style: TextStyle(fontFamily: 'NotoKufi'),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text(
                      isArabic ? "إرسال الرمز" : 'ناردنی کۆد',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NotoKufi',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
