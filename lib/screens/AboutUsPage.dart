// lib/screens/AboutUsPage.dart

import 'package:flutter/material.dart';
import '../widgets/footer_menu.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Program description
    final String programDesc = isArabic
        ? 'هذا التطبيق مصمم للبحث عن الوظائف وتوظيف الموظفين والمهندسين بأفضل الطرق وبسرعة وكفاءة عالية.'
        : 'ئەڤ پرگرامە یێ هاریکار هاتیە دروست کرن بۆ دیتنا کەرستەێت بیناسازی و کرێکار ب باشترین و ئاستنرین رێك.';

    // Advertise prompt
    final String advertiseText = isArabic
        ? ':07502827299 إذا كنت ترغب في عرض إعلانك أيضًا في التطبيق، حاول الاتصال بهذا الرقم'
        : 'ژ بو ریکلام کرنێ دناڤ پرۆگرامێ هاریکاردا و پێشاندانا کارێ تە ، پەیوەندی ڤێ ژمارێ بکە: 07502827299';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isArabic ? 'حولنا' : 'دەربارەی ئێمە',
            style: TextStyle(
              fontFamily: 'NotoKufi',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.blueAccent.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // — Brand Card —
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                isArabic ? 'هاريكار' : 'هاریکار',
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade700,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                programDesc,
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 16,
                                  height: 1.8,
                                  color: Colors.grey.shade800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // — Company Contact Card (original second card) —
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                isArabic
                                    ? 'رقم التواصل للشركة'
                                    : 'ژمارەی پەیوەندی کۆمپانیا',
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade700,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '0750-282-7299',
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // — Advertise-as-Job Card —
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Logo (ensure assets/logo.png exists & is declared)
                              Image.asset(
                                'assets/logo.png',
                                width: 120,
                                height: 120,
                              ),
                              SizedBox(height: 20),
                              Text(
                                programDesc,
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 16,
                                  height: 1.8,
                                  color: Colors.grey.shade800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              Text(
                                advertiseText,
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // — Footer developer info —
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      isArabic
                          ? 'تم تطوير هذا التطبيق من قبل Heama Soft.'
                          : 'ئەم بەرنامەیە لەلایەن Heama Soft پەرەپێدراوە.',
                      style: TextStyle(
                        fontFamily: 'NotoKufi',
                        fontSize: 14,
                        color: Colors.deepPurple.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      isArabic
                          ? 'للتواصل: 07504848085'
                          : 'بۆ پەیوەندیکردن: 07504848085',
                      style: TextStyle(
                        fontFamily: 'NotoKufi',
                        fontSize: 14,
                        color: Colors.deepPurple.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        bottomNavigationBar: FooterMenu(selectedIndex: 2),
      ),
    );
  }
}
