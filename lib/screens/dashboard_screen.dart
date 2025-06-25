// lib/screens/dashboard_screen.dart

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:Harikar/screens/form_search_work.dart';
import '../widgets/custom_drawer.dart';
import 'AboutUsPage.dart';
import 'WorkDetailsScreen.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  bool _didFetchData = false;
  Locale? _currentLocale;

  final String categoriesApi =
      "https://legaryan.heama-soft.com/get_categories.php";

  List<Map<String, dynamic>> _slideshowDetails = [];

  List<Map<String, dynamic>> get _infiniteSlideshowData {
    if (_slideshowDetails.isEmpty) return [];
    return [
      _slideshowDetails.last,
      ..._slideshowDetails,
      _slideshowDetails.first,
    ];
  }

  int _currentSlide = 1;
  final PageController _pageController =
      PageController(initialPage: 1, viewportFraction: 0.8);
  Timer? _slideshowTimer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _startSlideshowTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Locale newLocale = Localizations.localeOf(context);
    if (_currentLocale == null || _currentLocale != newLocale) {
      _currentLocale = newLocale;
      if (_categories.isNotEmpty) _applyTranslation();
    }
    if (!_didFetchData) {
      _fetchCategories();
      _fetchSlideshowDetails();
      _didFetchData = true;
    }
  }

  /// Reapply translation when locale changes
  void _applyTranslation() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final Map<String, String> translations = {
      "ئەندازیار": "مهندس",
      "مەساح": "مساح",
      "ئامیرە": "أدواة",
      "هوستا": "وستا",
      "کرێکار": "عمال",
      "مەواد": "مواد",
    };

    setState(() {
      _categories = _categories.map((cat) {
        final orig = cat['original_name']?.toString() ?? '';
        cat['name'] = (isArabic && translations.containsKey(orig))
            ? translations[orig]!
            : orig;
        return cat;
      }).toList();
    });
  }

  /// Fetch categories from API, store original_name, apply order & translation
  Future<void> _fetchCategories() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    setState(() => _isLoading = true);

    try {
      final resp = await http.get(Uri.parse(categoriesApi));
      final jsonBody = json.decode(resp.body);

      if (jsonBody['status'] == 'success') {
        final data = (jsonBody['data'] as List); // keep both active & inactive

        _categories = data.map((c) {
          return {
            'id': int.parse(c['id']),
            'name': c['name'],
            'original_name': c['name'],
            'image_url': c['image_url'],
            'icon': _getCategoryIcon(c['name']),
            'isActive': c['is_active'] == "1", // new flag
          };
        }).toList();

        // desired order map
        final order = {
          "ئەندازیار": 0,
          "مەساح": 1,
          "ئامیرە": 2,
          "هوستا": 3,
          "کرێکار": 4,
          "مەواد": 5,
        };
        _categories.sort((a, b) => (order[a['original_name']] ?? 99)
            .compareTo(order[b['original_name']] ?? 99));

        _applyTranslation();
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      print("Error fetching categories: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "فشل في تحميل الأقسام. الرجاء المحاولة لاحقاً."
                : "Error fetching categories. Please try again later.",
            style: TextStyle(fontFamily: 'NotoKufi'),
          ),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: isArabic ? 'إعادة المحاولة' : 'Retry',
            textColor: Colors.white,
            onPressed: _fetchCategories,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Fetch slideshow items from API
  Future<void> _fetchSlideshowDetails() async {
    final detailsApi =
        "https://legaryan.heama-soft.com/fetch_slideshow_details.php";
    try {
      final resp = await http.get(Uri.parse(detailsApi));
      final jsonBody = json.decode(resp.body);

      if (jsonBody['status'] == 'success') {
        final list = jsonBody['data'] as List;
        setState(() {
          _slideshowDetails = list.map<Map<String, dynamic>>((item) {
            final desc = item['description'] ?? '';
            return {
              'id': item['id'],
              'photo_url': item['photo_url'],
              'name': item['name'],
              'contact_number': item['phone_number'],
              'subcategory_name': item['subcategory_name'],
              'description':
                  desc.length > 60 ? desc.substring(0, 60) + '...' : desc,
            };
          }).toList();
        });
      } else {
        // no ads found or error message from server
        setState(() {
          _slideshowDetails = [];
        });
      }
    } catch (e) {
      print("Error fetching slideshow: $e");
      // on network or parsing error, clear the list
      setState(() {
        _slideshowDetails = [];
      });
    }
  }

  /// Utility to pick an icon per category
  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'گەڕان بۆ کار':
        return Icons.search;
      case 'تۆمارکردن':
        return Icons.app_registration;
      case 'سکالا':
        return Icons.report_problem;
      case 'دەربارەی ئێمە':
        return Icons.info;
      default:
        return Icons.category;
    }
  }

  /// Start automatic slideshow paging
  void _startSlideshowTimer() {
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
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
            isArabic ? "الصفحة الرئيسية" : 'پەڕەی سەرەکی',
            style: TextStyle(
              fontFamily: 'NotoKufi',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: CustomDrawer(),
        body: _isLoading
            ? _buildLoadingState(isArabic)
            : Container(
                color: const Color.fromARGB(255, 245, 244, 244),
                child: Column(
                  children: [
                    _buildAdSection(isArabic),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: _buildSlideshowSection(isArabic),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          itemCount: _categories.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.8,
                          ),
                          itemBuilder: (ctx, i) =>
                              _buildCategoryCard(_categories[i]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (idx) {
            setState(() => _selectedIndex = idx);
            switch (idx) {
              case 0:
                Navigator.pushReplacementNamed(context, '/dashboard');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/register');
                break;
              case 2:
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AboutUsPage()));
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: isArabic ? "الصفحة الرئيسية" : 'پەڕەی سەرەکی'),
            BottomNavigationBarItem(
                icon: Icon(Icons.app_registration),
                label: isArabic ? "التسجيل" : 'خۆتۆمارکردن'),
            BottomNavigationBarItem(
                icon: Icon(Icons.info), label: isArabic ? "حول" : 'دەربارە'),
          ],
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  /// Show bottom sheet with Call / WhatsApp options
  Future<void> _showContactOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.call),
            title: Text('Call 07502827299'),
            onTap: () {
              Navigator.pop(context);
              launchUrl(Uri(scheme: 'tel', path: '07502827299'));
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
            title: Text('WhatsApp 07502827299'),
            onTap: () {
              Navigator.pop(context);
              launchUrl(Uri.parse('https://wa.me/07502827299'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdSection(bool isArabic) {
    const logoUrl = 'https://legaryan.heama-soft.com/uploads/program_logo.png';

    return Container(
      height: 120,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF9C27B0), // purple
                  Color(0xFFE91E63), // pink
                  Color(0xFFFF9800), // orange
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                // logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: logoUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.white24, width: 60, height: 60),
                    errorWidget: (_, __, ___) =>
                        Container(color: Colors.white24, width: 60, height: 60),
                  ),
                ),
                SizedBox(width: 12),

                // call-to-action text + phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isArabic
                            ? 'إذا كنت ترغب في عرض إعلانك أيضًا في التطبيق، حاول الاتصال بهذا الرقم'
                            : 'ژ بو ریکلام کرنێ دناڤ پرۆگرامێ هاریکاردا و پێشاندانا کارێ تە ، پەیوەندی ڤێ ژمارێ بکە',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'NotoKufi',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      InkWell(
                        onTap: _showContactOptions,
                        child: Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.white70),
                            SizedBox(width: 6),
                            Text(
                              '07502827299',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'NotoKufi',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.blueAccent.withOpacity(0.1),
            Colors.deepPurple.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              isArabic ? "جاري تحميل الأقسام..." : 'جارى بارکردنى بەشەکان...',
              style: TextStyle(
                fontFamily: 'NotoKufi',
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideshowSection(bool isArabic) {
    if (_infiniteSlideshowData.isEmpty) {
      return Center(
        child: Text(
          isArabic ? "لا يوجد تصميمات." : 'هیچ کارەساتی دیزاین کراوە نیە.',
          style: TextStyle(
            fontFamily: 'NotoKufi',
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onPanDown: (_) => _slideshowTimer?.cancel(),
          onPanCancel: () => _startSlideshowTimer(),
          onPanEnd: (_) => _startSlideshowTimer(),
          child: SizedBox(
            height: 200.0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _infiniteSlideshowData.length,
              onPageChanged: (idx) {
                setState(() => _currentSlide = idx);
                if (idx == 0) {
                  Future.delayed(Duration(milliseconds: 300), () {
                    _pageController
                        .jumpToPage(_infiniteSlideshowData.length - 2);
                  });
                } else if (idx == _infiniteSlideshowData.length - 1) {
                  Future.delayed(Duration(milliseconds: 300), () {
                    _pageController.jumpToPage(1);
                  });
                }
              },
              itemBuilder: (_, idx) =>
                  _buildSlideshowCard(_infiniteSlideshowData[idx]),
            ),
          ),
        ),
        SizedBox(height: 10),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildSlideshowCard(Map<String, dynamic> slide) {
    return InkWell(
      onTap: () {
        final id = slide['id']?.toString();
        if (id != null && id.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkDetailsScreen(detailId: id, user: slide),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        height: 200,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 147, 176, 224),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 147, 176, 224).withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: slide['photo_url'],
                width: 120,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                    width: 120,
                    color: Colors.grey[300],
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2))),
                errorWidget: (ctx, url, err) => Container(
                    width: 120,
                    color: Colors.grey[300],
                    child:
                        Icon(Icons.broken_image, size: 40, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slide['name'],
                      style: TextStyle(
                        fontFamily: 'NotoKufi',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        slide['subcategory_name'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'NotoKufi',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.white70),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            slide['contact_number'] ?? '',
                            style: TextStyle(
                              fontFamily: 'NotoKufi',
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      slide['description'] ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'NotoKufi',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _slideshowDetails.asMap().entries.map((e) {
        int realIdx = e.key + 1;
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            realIdx,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: Container(
            width: 12,
            height: 12,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  (_currentSlide == realIdx ? Colors.blueAccent : Colors.grey)
                      .withOpacity(0.9),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final imageUrl = category['image_url']?.isNotEmpty == true
        ? 'https://legaryan.heama-soft.com/uploads/${category['image_url']}'
        : 'https://legaryan.heama-soft.com/uploads/work.png';

    final bool isActive = category['isActive'] as bool;

    return Opacity(
      opacity: isActive ? 1.0 : 0.5, // fade out if inactive
      child: InkWell(
        onTap: isActive
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FormSearchWork(initialCategoryId: category['id']),
                  ),
                )
            : null, // disable tap
        borderRadius: BorderRadius.circular(20),
        splashColor: isActive ? Colors.white24 : Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 147, 176, 224),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 125, 150, 190).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  placeholder: (c, u) =>
                      Container(color: Colors.grey[200], height: 80, width: 80),
                  errorWidget: (c, u, e) => Container(
                      color: Colors.grey[200],
                      height: 80,
                      width: 80,
                      child: Icon(Icons.image, size: 40, color: Colors.grey)),
                ),
              ),
              SizedBox(height: 8),
              Text(
                category['name'],
                style: TextStyle(
                  fontFamily: 'NotoKufi',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
