import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/presentation/pages/atributes_page.dart';
import 'package:list_in/features/post/presentation/pages/catalog_page.dart';
import 'package:list_in/features/post/presentation/pages/child_category_page.dart';
import 'package:list_in/features/post/presentation/provider/iii.dart';
import 'package:list_in/features/post/presentation/widgets/page_call_back_button.dart';
import 'package:provider/provider.dart';

// Optimized CatalogPagerScreen
class CatalogPagerScreen extends StatefulWidget {
  const CatalogPagerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CatalogPagerScreenState createState() => _CatalogPagerScreenState();
}

class _CatalogPagerScreenState extends State<CatalogPagerScreen> {
  late final PageController _pageController;
  late int _currentPage;
  late double _progressValue;

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
      _progressValue = (pageIndex + 1) / 3;
    });
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

    if (_currentPage == 2 || _currentPage == 1) {
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
        body: _buildPageViewBody(context),
      ),
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

  Widget _buildPageViewBody(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _updateProgress(index);
              });
            },
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CatalogListPage(
                onCatalogSelected: (catalog) {
                  provider.selectCatalog(catalog);
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              ChildCategoryListPage(
                onChildCategorySelected: (childCategory) {
                  provider.selectChildCategory(childCategory);
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              AttributesPage(
                onNextPressed: () {
                  
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
