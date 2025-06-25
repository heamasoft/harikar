// lib/screens/WorkDetailsPage.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/custom_drawer.dart';
import '../widgets/footer_menu.dart';
import 'WorkDetailsScreen.dart';

class WorkDetailsPage extends StatefulWidget {
  final String? subcategoryId;

  WorkDetailsPage({this.subcategoryId});

  @override
  _WorkDetailsPageState createState() => _WorkDetailsPageState();
}

class _WorkDetailsPageState extends State<WorkDetailsPage> {
  List<Map<String, dynamic>> _subcategories = [];
  List<Map<String, dynamic>> _allWorkUsers = [];
  List<Map<String, dynamic>> _filteredWorkUsers = [];
  Map<String, String> _subcategoryMap = {};

  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _totalPages = 1;

  String? _selectedSubcategoryId;
  String? _selectedCity;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _cities = [
    'دهۆک',
    'زاخۆ',
    'سێمێل',
    'ئاکرێ',
    'هەولێر',
    'سلێمانی'
  ];

  bool _didLoadData = false;
  Locale? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Locale newLocale = Localizations.localeOf(context);
    if (_currentLocale == null || _currentLocale != newLocale) {
      _currentLocale = newLocale;
      _didLoadData = false;
    }
    if (!_didLoadData) {
      _fetchSubcategories().then((_) {
        if (widget.subcategoryId != null && widget.subcategoryId!.isNotEmpty) {
          setState(() {
            _selectedSubcategoryId = widget.subcategoryId;
          });
        }
        _fetchWorkUsers(
          subcategoryId: widget.subcategoryId,
          city: _selectedCity,
        );
      });
      _didLoadData = true;
    }
  }

  /// Fetch subcategories and translate names
  Future<void> _fetchSubcategories() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    const String url = 'https://legaryan.heama-soft.com/get_subcategories.php';
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          var fetched =
              List<Map<String, dynamic>>.from(data['data']).map((sub) {
            return {
              ...sub,
              'original_name': sub['name'],
              'name': sub['name'],
            };
          }).toList();
          setState(() {
            _subcategories = fetched;
            _applySubcategoryTranslation();
            _subcategoryMap = {
              for (var sub in _subcategories) sub['id'].toString(): sub['name']
            };
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ??
                (isArabic
                    ? 'فشل في جلب الأقسام.'
                    : 'خەلەتی یا هەی ل وەرگرتنا بەشا');
          });
        }
      } else {
        setState(() {
          _errorMessage = isArabic
              ? 'خطأ بالخادم: ${response.statusCode}'
              : 'خەلەتی یا هەی لە سێرڤەری: ${response.statusCode}.';
        });
      }
    } catch (e) {
      print("Error fetching subcategories: $e");
      setState(() {
        _errorMessage = isArabic
            ? 'حدث خطأ أثناء جلب الأقسام.'
            : 'خەلەتی یا هەی دەمێ وەرگرتنا بەشا.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Apply Kurdish<->Arabic mapping for subcategory names
  void _applySubcategoryTranslation() {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final Map<String, String> subcategoryTranslations = {
      "شەڤەر": "شفل",
      "کرێکار": "عمال",
      "نەجار": "نجار",
      "حاديله": "ضاغطة التربة",
      "تانکەرێ ئاڤێ": "تنكر ماء",
      "سلنگ": "كرين",
      "قەلابە": "قلاب",
      "گرێدەر": "آلات تسوية الطرق",
      "حەفارە": "حفارة",
      "بەنا": "بناء",
      "سەباخ": "صباغ",
      "لەباخ": "لباخ",
      "سیرامیك و کاشی": "سيراميك و أرضيات",
      "مەرمەر": "مرمر",
      "فلین": "فلين خارجي",
      "سەقف مەخربی": "صقف مغربي",
      "حداد": "حداد",
      "ئەندازیاری": "مهندس",
      "مەساح": "مساح",
      "کەهرەبای": "كهربائي",
      "مەجاری": "مجاري",
    };

    setState(() {
      _subcategories = _subcategories.map((sub) {
        String orig = sub['original_name'].toString().trim();
        if (isArabic && subcategoryTranslations.containsKey(orig)) {
          sub['name'] = subcategoryTranslations[orig]!;
        } else {
          sub['name'] = orig;
        }
        return sub;
      }).toList();
      _subcategoryMap = {
        for (var sub in _subcategories) sub['id'].toString(): sub['name']
      };
    });
  }

  /// Fetch work users, then prefetch their photos
  Future<void> _fetchWorkUsers({String? subcategoryId, String? city}) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    String url = 'https://legaryan.heama-soft.com/fetch_full_details.php';
    Map<String, String> queryParams = {
      if (subcategoryId != null && subcategoryId.isNotEmpty)
        'sub_category_id': subcategoryId,
      if (city != null && city.isNotEmpty && city != 'هەموو شەهرەکان')
        'city': city,
      'lang': isArabic ? 'ar' : 'ku',
    };
    if (city != null && city.isNotEmpty && city != 'هەموو شەهرەکان') {
      queryParams['city'] = city;
    }
    if (queryParams.isNotEmpty) {
      url = Uri.parse(url).replace(queryParameters: queryParams).toString();
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          var fetchedUsers = List<Map<String, dynamic>>.from(data['data']);
          setState(() {
            _allWorkUsers = fetchedUsers;
            _applyFilters();
          });
          // ── Prefetch each image ──
          for (var u in fetchedUsers) {
            final img = u['photo_url'] as String?;
            if (img != null && img.isNotEmpty) {
              CachedNetworkImageProvider(img)
                  .resolve(const ImageConfiguration());
            }
          }
        } else {
          setState(() {
            _allWorkUsers = [];
            _filteredWorkUsers = [];
            _totalPages = 1;
            _currentPage = 1;
            _errorMessage = data['message'] ??
                (isArabic
                    ? 'فشل في جلب المستخدمين.'
                    : 'خەلەتی یا هەی دەمێ وەرگرتنا کارهێنەرا.');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? (data['message'] ?? 'خطأ في الوصول إلى البيانات')
                    : (data['message'] ??
                        'خەلەتی یا هەی دەمێ وەرگرتنا کارهێنەرا.'),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = isArabic
              ? 'خطأ بالخادم: ${response.statusCode}'
              : 'هه‌ڵه‌ی سێرڤه‌ر: ${response.statusCode}.';
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        _errorMessage = isArabic
            ? 'حدث خطأ أثناء جلب المستخدمين.'
            : 'خەلەتی یا هەی دەمێ وەرگرتنا کارهێنەرا.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic
              ? 'خطأ في الاتصال بالبيانات'
              : 'خەلەتی یا هەی دەمێ وەرگرتنا داتا.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Filter and paginate
  void _applyFilters() {
    _filteredWorkUsers = _allWorkUsers.where((user) {
      bool ok = true;
      if (_selectedSubcategoryId?.isNotEmpty == true) {
        ok &= user['subcategory_id'].toString() == _selectedSubcategoryId;
      }
      if (_selectedCity?.isNotEmpty == true &&
          _selectedCity != 'هەموو شەهرەکان') {
        ok &= user['location']?.toString() == _selectedCity;
      }
      return ok;
    }).toList();

    _totalPages = (_filteredWorkUsers.length / _rowsPerPage)
        .ceil()
        .clamp(1, double.infinity)
        .toInt();
    if (_currentPage > _totalPages) _currentPage = _totalPages;
    setState(() {});
  }

  void _onSubcategoryChanged(String? v) {
    setState(() {
      _selectedSubcategoryId = v;
      _currentPage = 1;
    });
    _fetchWorkUsers(subcategoryId: v, city: _selectedCity);
  }

  void _onCityChanged(String? v) {
    setState(() {
      _selectedCity = v;
      _currentPage = 1;
    });
    _fetchWorkUsers(subcategoryId: _selectedSubcategoryId, city: v);
  }

  void _onRowsPerPageChanged(int? v) {
    if (v != null) {
      setState(() {
        _rowsPerPage = v;
        _currentPage = 1;
      });
      _applyFilters();
    }
  }

  void _goToPage(int p) {
    if (p >= 1 && p <= _totalPages) {
      setState(() => _currentPage = p);
    }
  }

  List<Map<String, dynamic>> get _currentWorkUsers {
    int start = (_currentPage - 1) * _rowsPerPage;
    int end = start + _rowsPerPage;
    if (start >= _filteredWorkUsers.length) return [];
    return _filteredWorkUsers.sublist(
      start,
      end > _filteredWorkUsers.length ? _filteredWorkUsers.length : end,
    );
  }

  Future<void> _navigateToDetails(Map<String, dynamic> user) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    String? id = user['id']?.toString();
    if (id?.isNotEmpty == true) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkDetailsScreen(detailId: id!, user: user),
        ),
      );
      _refreshPage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isArabic ? 'معرّف التفاصيل غير صالح' : 'خەلەتی داتا دا یاهەی.'),
        ),
      );
    }
  }

  Future<void> _onWhatsAppClicked(Map<String, dynamic> user) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    String? id = user['id']?.toString();
    String phone = user['phone_number'] ?? '';
    if (id?.isEmpty == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isArabic ? 'معرّف التفاصيل غير صالح' : 'خەلەتی داتا دا یاهەی.'),
        ),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isArabic ? 'رقم الهاتف غير معرف' : 'ژمارا  مۆبایل دیارنینە.'),
        ),
      );
      return;
    }
    // increment view...
    try {
      final res = await http.post(
        Uri.parse('https://legaryan.heama-soft.com/increment_view_count.php'),
        body: {'detail_id': id},
      );
      if (res.statusCode == 200) {
        var d = json.decode(res.body);
        if (d['status'] == 'success') {
          setState(() {
            int cnt = int.tryParse(user['view_count']?.toString() ?? '') ?? 0;
            user['view_count'] = cnt + 1;
          });
        }
      }
    } catch (_) {}
    String msg = isArabic
        ? 'مرحبا، لقد وجدتك في تطبيق هاريكار. أود التواصل معك لمزيد من التفاصيل عن عملك.'
        : 'سلاڤ، من دڤێت پەیوەندی تە بکەم . من پێزانین تە دیتینە رێکا پرۆگرامێ هاریکار.';
    await _launchWhatsApp(phone, message: msg);
  }

  Future<void> _launchWhatsApp(String phone, {String message = ''}) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    String num = sanitizePhoneNumber(phone);
    if (!num.startsWith('964')) num = '964' + num;
    String encoded = Uri.encodeComponent(message);
    final url1 = 'whatsapp://send?phone=$num&text=$encoded';
    if (await canLaunchUrl(Uri.parse(url1))) {
      await launchUrl(Uri.parse(url1), mode: LaunchMode.externalApplication);
    } else {
      final url2 = 'https://wa.me/$num?text=$encoded';
      if (await canLaunchUrl(Uri.parse(url2))) {
        await launchUrl(Uri.parse(url2), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic
                ? 'لا يمكن فتح WhatsApp. تأكد من تثبيته على جهازك.'
                : 'نەشی پەیوەندی ب وتس ئاپ وی بەکەی ، چنکی وتس ئاپ نە درەستە موبایلێ دا.'),
          ),
        );
      }
    }
  }

  void _refreshPage() {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _fetchWorkUsers(subcategoryId: _selectedSubcategoryId, city: _selectedCity)
        .then((_) {
      setState(() => _isLoading = false);
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        _errorMessage = isArabic
            ? 'خطأ إعادة تحميل الصفحة: $e'
            : 'خەلەتی ل دەمێ وەرگرتنا داتا : $e';
      });
    });
  }

  /// Cached image with placeholder & fade-in
  Widget _buildUserImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(Icons.person, size: 30, color: Colors.grey);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) =>
          Icon(Icons.broken_image, size: 30, color: Colors.grey),
      fadeInDuration: Duration(milliseconds: 300),
      memCacheWidth: 200,
      memCacheHeight: 200,
    );
  }

  /// Phone dialer with Kurdish error
  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    String sanitized = sanitizePhoneNumber(phoneNumber);
    final uri = Uri(scheme: 'tel', path: sanitized);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic
              ? 'لا يمكن فتح تطبيق الاتصال'
              : 'نەشێ پەیوەندی ڤێ ژمارێ بکەی .'),
        ),
      );
    }
  }

  String sanitizePhoneNumber(String phoneNumber) {
    String sanitized = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return sanitized.replaceAll(RegExp(r'^0+'), '');
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isArabic ? "تفاصيل العمل" : 'وردکاری کار',
            style: TextStyle(
              fontFamily: 'NotoKufi',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
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
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: CustomDrawer(),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color.fromARGB(255, 245, 244, 244),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildFilterRow(isArabic),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontFamily: 'NotoKufi',
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _currentWorkUsers.isEmpty
                            ? Center(
                                child: Text(
                                  isArabic
                                      ? "لم يتم العثور على مستخدمين"
                                      : 'ج تشت بەر دەست نینن نوکە.',
                                  style: TextStyle(
                                    fontFamily: 'NotoKufi',
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _currentWorkUsers.length,
                                itemBuilder: (context, index) =>
                                    _buildWorkUserCard(
                                        _currentWorkUsers[index], isArabic),
                              ),
              ),
              _buildFooter(isArabic),
            ],
          ),
        ),
        bottomNavigationBar:
            FooterMenu(), // no args → selectedIndex defaults to –1
      ),
    );
  }

  Widget _buildFilterRow(bool isArabic) {
    return Row(
      children: [
        Expanded(child: _buildDropdownFilter(isArabic)),
        SizedBox(width: 12),
        Expanded(child: _buildCityDropdown(isArabic)),
      ],
    );
  }

  Widget _buildDropdownFilter(bool isArabic) {
    return DropdownButtonFormField<String>(
      value: _selectedSubcategoryId?.isEmpty == true
          ? null
          : _selectedSubcategoryId,
      hint: Text(
        isArabic ? "اختر القسم" : 'هه‌موو به‌شان',
        style: TextStyle(fontFamily: 'NotoKufi'),
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(
            isArabic ? "جميع الأقسام" : 'هه‌موو به‌شان',
            style: TextStyle(fontFamily: 'NotoKufi'),
          ),
        ),
        ..._subcategories.map((sub) => DropdownMenuItem(
              value: sub['id'].toString(),
              child:
                  Text(sub['name'], style: TextStyle(fontFamily: 'NotoKufi')),
            )),
      ],
      onChanged: _onSubcategoryChanged,
    );
  }

  Widget _buildCityDropdown(bool isArabic) {
    return DropdownButtonFormField<String>(
      value: _selectedCity?.isEmpty == true ? null : _selectedCity,
      hint: Text(
        isArabic ? "اختر مدينة" : 'هه‌موو شاران',
        style: TextStyle(fontFamily: 'NotoKufi'),
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(
            isArabic ? "جميع المدن" : 'هه‌موو شاران',
            style: TextStyle(fontFamily: 'NotoKufi'),
          ),
        ),
        ..._cities.map((city) => DropdownMenuItem(
              value: city,
              child: Text(city, style: TextStyle(fontFamily: 'NotoKufi')),
            )),
      ],
      onChanged: _onCityChanged,
    );
  }

  Widget _buildWorkUserCard(Map<String, dynamic> user, bool isArabic) {
    String subcat = _subcategoryMap[user['subcategory_id']?.toString()] ??
        (isArabic ? "قسم غير متوفر" : 'به‌ش ته‌واوه‌ نیه‌');
    String mainCat = user['main_category'] ??
        (isArabic ? "فئة رئيسية غير متوفرة" : 'به‌ش سەرەکی نیه‌');
    int views = int.tryParse(user['view_count']?.toString() ?? '') ?? 0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetails(user),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent, width: 1)),
                child: ClipOval(child: _buildUserImage(user['photo_url'])),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & categories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            user['name'] ??
                                (isArabic ? "اسم غير متوفر" : 'ناڤ نیه‌'),
                            style: TextStyle(
                              fontFamily: 'NotoKufi',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(subcat,
                                  style: TextStyle(
                                      fontFamily: 'NotoKufi',
                                      fontSize: 10,
                                      color: Colors.white)),
                            ),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(mainCat,
                                  style: TextStyle(
                                      fontFamily: 'NotoKufi',
                                      fontSize: 10,
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    // Location & phone & icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  user['location'] ??
                                      (isArabic ? "غير محدد" : 'شوێن نەدروست'),
                                  style: TextStyle(
                                      fontFamily: 'NotoKufi',
                                      fontSize: 12,
                                      color: Colors.blueAccent),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.phone, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () => _launchPhoneDialer(
                                      user['phone_number'] ?? ''),
                                  child: Text(
                                    user['phone_number'] ??
                                        (isArabic ? "غير متوفر" : 'ژمارە نیه‌'),
                                    style: TextStyle(
                                        fontFamily: 'NotoKufi',
                                        fontSize: 12,
                                        color: Colors.blueAccent,
                                        decoration: TextDecoration.underline),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye,
                                size: 20, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(views.toString(),
                                style: TextStyle(
                                    fontFamily: 'NotoKufi',
                                    fontSize: 12,
                                    color: Colors.blueAccent)),
                            SizedBox(width: 8),
                            GestureDetector(
                                onTap: () => _onWhatsAppClicked(user),
                                child: Icon(FontAwesomeIcons.whatsapp,
                                    size: 20, color: Colors.green)),
                            SizedBox(width: 8),
                            GestureDetector(
                                onTap: () => _navigateToDetails(user),
                                child: Icon(Icons.info_outline,
                                    size: 20, color: Colors.blue)),
                          ],
                        ),
                      ],
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

  Widget _buildFooter(bool isArabic) {
    return Container(
      height: kToolbarHeight,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rows‐per‐page selector
          Row(
            children: [
              Text(isArabic ? "عدد الصفوف:" : 'ژمارا رێسا:',
                  style: TextStyle(
                      fontFamily: 'NotoKufi',
                      fontSize: 14,
                      color: Colors.white)),
              SizedBox(width: 8),
              DropdownButton<int>(
                value: _rowsPerPage,
                dropdownColor: Colors.blueAccent,
                iconEnabledColor: Colors.white,
                style: TextStyle(fontFamily: 'NotoKufi', color: Colors.white),
                underline: SizedBox(),
                items: [5, 10, 20, 50]
                    .map((r) => DropdownMenuItem(value: r, child: Text('$r')))
                    .toList(),
                onChanged: _onRowsPerPageChanged,
              ),
            ],
          ),
          // Pagination controls
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.first_page, color: Colors.white),
                  onPressed: _currentPage > 1 ? () => _goToPage(1) : null),
              IconButton(
                  icon: Icon(Icons.navigate_before, color: Colors.white),
                  onPressed: _currentPage > 1
                      ? () => _goToPage(_currentPage - 1)
                      : null),
              Text(
                  isArabic
                      ? "صفحة $_currentPage/$_totalPages"
                      : "پەڕە $_currentPage/$_totalPages",
                  style: TextStyle(
                      fontFamily: 'NotoKufi',
                      fontSize: 14,
                      color: Colors.white)),
              IconButton(
                  icon: Icon(Icons.navigate_next, color: Colors.white),
                  onPressed: _currentPage < _totalPages
                      ? () => _goToPage(_currentPage + 1)
                      : null),
              IconButton(
                  icon: Icon(Icons.last_page, color: Colors.white),
                  onPressed: _currentPage < _totalPages
                      ? () => _goToPage(_totalPages)
                      : null),
            ],
          ),
        ],
      ),
    );
  }
}
