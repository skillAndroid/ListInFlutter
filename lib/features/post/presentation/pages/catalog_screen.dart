import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/atributes_page.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/catalog_page.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/description_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/image_picker_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/price_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/title_page.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:list_in/features/post/presentation/widgets/page_call_back_button.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

// Optimized CatalogPagerScreen
class CatalogPagerScreen extends StatefulWidget {
  const CatalogPagerScreen({super.key});

  @override
  State<CatalogPagerScreen> createState() => _CatalogPagerScreenState();
}

class _CatalogPagerScreenState extends State<CatalogPagerScreen> {
  late final PageController _pageController;
  late int _currentPage;
  late double _progressValue;
  int _pageCount = 7;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPage = 0;
    _progressValue = 0.0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateProgress(int pageIndex) {
    setState(() {
      _progressValue = (pageIndex + 1) / _pageCount;
    });
  }

  void _handleNextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> _onWillPop() async {
    final provider = Provider.of<CatalogProvider>(context, listen: false);

    if (_currentPage > 0) {
      _handleBackNavigation(provider);
      return false;
    }

    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return false;
  }

  void _handleBackNavigation(CatalogProvider provider) {
    provider.resetUIState();

    if (_currentPage == 6 ||
        _currentPage == 5 ||
        _currentPage == 4 ||
        _currentPage == 3 ||
        _currentPage == 3 ||
        _currentPage == 2 ||
        _currentPage == 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      if (_currentPage == 1) {
        provider.goBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            _buildPageViewBody(context),
            // Conditional Next Button
            if (_currentPage >= 2)
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        smoothness: 1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: _handleNextPage,
                    child: const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text('Next'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageViewBody(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: _currentPage >= 2 ? 70.0 : 8,
          ),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(
                () {
                  _currentPage = index;
                  _updateProgress(index);
                },
              );
            },
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CatalogListPage(
                onCatalogSelected: (catalog) {
                  provider.selectCatalog(catalog);
                  _handleNextPage();
                },
              ),
              ChildCategoryListPage(
                onChildCategorySelected: (childCategory) {
                  provider.selectChildCategory(childCategory);
                  _handleNextPage();
                },
              ),
              const AttributesPage(),
              const AddTitlePage(),
              const AddDescriptionPage(),
              const AddPricePage(),
              const GalleryImagePicker(),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'Create Post',
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: "Poppins",
            fontSize: 21,
            color: AppColors.black),
      ),
      toolbarHeight: 56.0,
      automaticallyImplyLeading: false,
      flexibleSpace: _buildProgressIndicator(),
      leadingWidth: 56,
      leading: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          return Visibility(
            visible: _currentPage >= 0,
            child: Transform.translate(
              offset: const Offset(10, 0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: CatalogBackButton(
                  onTap: () => _handleBackNavigation(provider),
                  isVisible: provider.selectedChildCategory != null ||
                      provider.selectedCatalog != null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: _progressValue, end: _progressValue),
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        backgroundColor: AppColors.containerColor,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lighterGray),
        minHeight: double.infinity,
      ),
    );
  }
}
