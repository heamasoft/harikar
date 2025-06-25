// lib/screens/dashboard_screen.dart

import 'package:Harikar/screens/AboutUsPage.dart';
import 'package:Harikar/screens/WorkDetailsScreen.dart';
import 'package:Harikar/screens/form_search_work.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  bool _didFetchData = false;
  Locale? _currentLocale; // To keep track of the current locale

  final String categoriesApi =
      "https://legaryan.heama-soft.com/get_categories.php";

  // Dynamic slideshow data loaded from the API
  List<Map<String, dynamic>> _slideshowDetails = [];

  // Infinite slideshow data with duplicated items at beginning/end
  List<Map<String, dynamic>> get _infiniteSlideshowData {
    if (_slideshowDetails.isEmpty) return [];
    List<Map<String, dynamic>> infiniteData = [];
    infiniteData.add(_slideshowDetails.last);
    infiniteData.addAll(_slideshowDetails);
    infiniteData.add(_slideshowDetails.first);
    return infiniteData;
  }

  int _currentSlide = 1;
  final PageController _pageController =
      PageController(initialPage: 1, viewportFraction: 0.8);
  Timer? _slideshowTimer;
  int _selectedIndex = 0; // For BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _startSlideshowTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Locale newLocale = Localizations.localeOf(context);
    // If the locale has changed, update the categories accordingly.
    if (_currentLocale == null || _currentLocale != newLocale) {
      _currentLocale = newLocale;
      if (_categories.isNotEmpty) {
        _applyTranslation();
      }
    }
    if (!_didFetchData) {
      _fetchCategories();
      _fetchSlideshowDetails();
      _didFetchData = true;
    }
  }

  // Applies translation based on the current locale.
  // We use the stored original name ("original_name") to reapply translations.
  void _applyTranslation() {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final Map<String, String> categoryTranslations = {
      "ئەندازیار": "مهندس",
      "مەساح": "مساح",
      "ئامیرە": "أدواة",
      "هوستا": "وستا",
      "کرێکار": "عمال",
      "مەواد": "مواد",
    };
    setState(() {
      _categories = _categories.map((category) {
        String originalName =
            category['original_name']?.toString().trim() ?? '';
        if (isArabic && categoryTranslations.containsKey(originalName)) {
          category['name'] = categoryTranslations[originalName];
        } else {
          category['name'] = originalName;
        }
        return category;
      }).toList();
    });
  }

  // Complete _fetchCategories method that stores the original names and applies translation.
  Future<void> _fetchCategories() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(categoriesApi));
      final categoriesJson = json.decode(response.body);

      if (categoriesJson['status'] == 'success') {
        List categoriesData = categoriesJson['data'];

        // Process only active categories
        final activeCategories = categoriesData
            .where((category) => category['is_active'] == "1")
            .toList();

        _categories = activeCategories.map((category) {
          return {
            "id": int.parse(category['id']),
            "name": category['name'], // Original name (will be updated later)
            "original_name":
                category['name'], // Store original name for future translation
            "image_url": category['image_url'],
            "icon": _getCategoryIcon(category['name']),
            "is_active": category['is_active']
          };
        }).toList();

        // Define desired order using the original Kurdish names
        Map<String, int> order = {
          "ئەندازیار": 0,
          "مەساح": 1,
          "ئامیرە": 2,
          "هوستا": 3,
          "کرێکار": 4,
          "مەواد": 5,
        };

        _categories.sort((a, b) {
          int aOrder = order[a["original_name"]] ?? 100;
          int bOrder = order[b["original_name"]] ?? 100;
          return aOrder.compareTo(bOrder);
        });

        // Apply the translation mapping based on the current locale
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // The rest of your methods remain unchanged

  Future<void> _fetchSlideshowDetails() async {
    final String detailsApi =
        "https://legaryan.heama-soft.com/fetch_slideshow_details.php";
    try {
      final response = await http.get(Uri.parse(detailsApi));
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        List detailsData = jsonData['data'];
        setState(() {
          _slideshowDetails = detailsData.map<Map<String, dynamic>>((item) {
            return {
              "id": item['id'],
              "photo_url": item['photo_url'],
              "name": item['name'],
              "contact_number": item['phone_number'],
              "subcategory_name": item['subcategory_name'],
              "description": item['description'] != null &&
                      item['description'].toString().length > 60
                  ? item['description'].toString().substring(0, 60) + '...'
                  : item['description'] ?? '',
            };
          }).toList();
        });
      } else {
        print("Error fetching slideshow details: ${jsonData['message']}");
      }
    } catch (e) {
      print("Exception in fetching slideshow details: $e");
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
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

  void _startSlideshowTimer() {
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
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
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
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
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return _buildCategoryCard(category);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/dashboard');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/register');
                break;
              case 2:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()));
                break;
              default:
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: isArabic ? "الصفحة الرئيسية" : 'پەڕەی سەرەکی',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.app_registration),
              label: isArabic ? "التسجيل" : 'خۆتۆمارکردن',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: isArabic ? "حول" : 'دەربارە',
            ),
          ],
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
        ),
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
              isArabic ? "جاري تحميل الأقسام..." : 'جارى باركردنى بەشەکان...',
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
          onPanDown: (_) {
            _slideshowTimer?.cancel();
          },
          onPanCancel: () {
            _startSlideshowTimer();
          },
          onPanEnd: (_) {
            _startSlideshowTimer();
          },
          child: SizedBox(
            height: 200.0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _infiniteSlideshowData.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentSlide = index;
                });
                if (index == 0) {
                  Future.delayed(Duration(milliseconds: 300), () {
                    _pageController
                        .jumpToPage(_infiniteSlideshowData.length - 2);
                  });
                } else if (index == _infiniteSlideshowData.length - 1) {
                  Future.delayed(Duration(milliseconds: 300), () {
                    _pageController.jumpToPage(1);
                  });
                }
              },
              itemBuilder: (BuildContext context, int index) {
                final slide = _infiniteSlideshowData[index];
                return _buildSlideshowCard(slide);
              },
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
        String? detailId = slide['id']?.toString();
        if (detailId != null && detailId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkDetailsScreen(
                detailId: detailId,
                user: slide,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 147, 176, 224),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 147, 176, 224).withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  slide['photo_url'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.white70,
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slide['name'],
                      style: TextStyle(
                        fontFamily: 'NotoKufi',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 118, 110),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        slide['subcategory_name'] ?? '',
                        style: TextStyle(
                          fontFamily: 'NotoKufi',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      slide['contact_number'],
                      style: TextStyle(
                        fontFamily: 'NotoKufi',
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 12),
                    Text(
                      slide['description'],
                      style: TextStyle(
                        fontFamily: 'NotoKufi',
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final indicatorSource = _slideshowDetails;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicatorSource.asMap().entries.map((entry) {
        int realIndex = entry.key + 1;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              realIndex,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            width: 12.0,
            height: 12.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  (_currentSlide == realIndex ? Colors.blueAccent : Colors.grey)
                      .withOpacity(0.9),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    String imageUrl =
        category['image_url'] != null && category['image_url'].isNotEmpty
            ? 'https://legaryan.heama-soft.com/uploads/${category['image_url']}'
            : 'https://legaryan.heama-soft.com/uploads/work.png';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormSearchWork(
              initialCategoryId: category['id'],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.white24,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 147, 176, 224),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 125, 150, 190).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    );
                  },
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
