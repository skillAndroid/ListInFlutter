// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/atributes_page.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/catalog_page.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/contacts_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/description_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/location_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/media_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/price_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/product_condition_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/title_page.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:list_in/features/post/presentation/widgets/page_call_back_button.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class CatalogPagerScreen extends StatefulWidget {
  const CatalogPagerScreen({super.key});

  @override
  State<CatalogPagerScreen> createState() => _CatalogPagerScreenState();
}

class _CatalogPagerScreenState extends State<CatalogPagerScreen> {
  late final PageController _pageController;
  late int _currentPage;
  late double _progressValue;
  final int _pageCount = 10;

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
    final provider = Provider.of<PostProvider>(context, listen: false);

    if (_currentPage > 0) {
      _handleBackNavigation(provider);
      return false;
    }

    context.pop();
    return false;
  }

  void _handleBackNavigation(PostProvider provider) {
    if (_currentPage == 0) {
      provider.clear();
      context.pop();
      return;
    }
    provider.resetUIState();

    if (_currentPage == 9 ||
        _currentPage == 8 ||
        _currentPage == 7 ||
        _currentPage == 6 ||
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            _buildPageViewBody(context),
            if (_currentPage >= 2) _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

//
  Widget _buildPageViewBody(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: _currentPage >= 2 ? 80.0 : 8,
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
              const ProductConditionPage(),
              const MediaPage(),
              _buildPage(child: const PhoneSettingsPage()),
              _buildPage(
                child: const LocationSelectionPage(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPage({
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        child,
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'Create Post',
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: "Syne",
            fontSize: 21,
            color: AppColors.black),
      ),
      toolbarHeight: 56.0,
      automaticallyImplyLeading: false,
      flexibleSpace: _buildProgressIndicator(),
      leadingWidth: 56,
      leading: Transform.translate(
        offset: const Offset(10, 0),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CatalogBackButton(onTap: () {
            final provider = Provider.of<PostProvider>(context, listen: false);
            _handleBackNavigation(provider);
          }),
        ),
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
        valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.lighterGray.withOpacity(0.5)),
        minHeight: double.infinity,
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        final isLastPage = _currentPage == 9;
        final isLoading = provider.postCreationState ==
                PostCreationState.uploadingImages ||
            provider.postCreationState == PostCreationState.uploadingVideo ||
            provider.postCreationState == PostCreationState.creatingPost;

        Widget buttonChild;
        if (isLastPage) {
          buttonChild = isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.black,
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getLoadingText(provider.postCreationState),
                      style: const TextStyle(fontFamily: "Syne"),
                    ),
                  ],
                )
              : const Text(
                  'Create Post',
                  style: TextStyle(fontFamily: "Syne"),
                );
        } else {
          buttonChild = const Text(
            'Next',
            style: TextStyle(
              fontFamily: "Syne",
            ),
          );
        }

        return Positioned(
          left: 0,
          right: 0,
          bottom: 22,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: SmoothRectangleBorder(
                  smoothness: 1,
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (isLastPage) {
                        final result = await provider.createPost();
                        result.fold(
                          (failure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.postCreationError ??
                                    'Failed to create post'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          (success) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: const Text('Success'),
                                content: const Text(
                                    'Your post has been created successfully!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<UserPublicationsBloc>()
                                          .add(RefreshUserPublications());
                                      Navigator.of(context).pop();
                                      context.pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        _handleNextPage();
                      }
                    },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: buttonChild,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLoadingText(PostCreationState state) {
    switch (state) {
      case PostCreationState.uploadingImages:
        return 'Uploading Images...';
      case PostCreationState.uploadingVideo:
        return 'Uploading Video...';
      case PostCreationState.creatingPost:
        return 'Creating Post...';
      default:
        return 'Please wait...';
    }
  }
}

enum PostCreationState {
  initial,
  uploadingImages,
  uploadingVideo,
  creatingPost,
  success,
  error
}
