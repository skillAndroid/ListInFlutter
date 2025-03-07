// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/atributes_page.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/catalog_page.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/description_page.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CatalogPagerScreen extends StatefulWidget {
  const CatalogPagerScreen({super.key});

  @override
  State<CatalogPagerScreen> createState() => _CatalogPagerScreenState();
}

class _CatalogPagerScreenState extends State<CatalogPagerScreen> {
  late final PageController _pageController;
  late int _currentPage;
  late double _progressValue;
  final int _pageCount = 8;

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

  bool get _isLoading {
    final provider = Provider.of<PostProvider>(context, listen: false);
    return provider.postCreationState == PostCreationState.uploadingImages ||
        provider.postCreationState == PostCreationState.uploadingVideo ||
        provider.postCreationState == PostCreationState.creatingPost;
  }

  bool _validateCurrentPage(PostProvider provider) {
    switch (_currentPage) {
      case 3: // Title page
        return provider.postTitle.length >= 10;
      case 4: // Description page
        return provider.postDescription.length >= 45;
      case 5: // Price page
        return provider.price > 0;
      case 6: // Condition page
        // ignore: unnecessary_null_comparison
        return provider.productCondition != null;
      case 7: // Media page
        return provider.images.isNotEmpty;
      default:
        return true;
    }
  }

  String _getValidationErrorMessage() {
    switch (_currentPage) {
      case 3:
        return AppLocalizations.of(context)!.title_min_length_warning;
      case 4:
        return AppLocalizations.of(context)!.description_min_length_warning;
      case 5:
        return AppLocalizations.of(context)!.enter_valid_price;
      case 6:
        return AppLocalizations.of(context)!.select_condition;
      case 7:
        return AppLocalizations.of(context)!.add_at_least_one_image;
      default:
        return '';
    }
  }

  void _updateProgress(int pageIndex) {
    setState(() {
      _progressValue = (pageIndex + 1) / _pageCount;
    });
  }

  void _handleNextPage() {
    final provider = Provider.of<PostProvider>(context, listen: false);

    if (_isLoading) return;

    if (!_validateCurrentPage(provider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getValidationErrorMessage()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentPage < _pageCount - 1) {
      FocusScope.of(context).unfocus();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_isLoading) return false;

    if (_currentPage > 0) {
      _handleBackNavigation();
      return false;
    }

    context.pop();
    return false;
  }

  Widget _buildProgressIndicator() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: _progressValue, end: _progressValue),
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        backgroundColor: AppColors.containerColor.withOpacity(0.7),
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.lighterGray.withOpacity(0.3),
        ),
        minHeight: double.infinity,
      ),
    );
  }

  void _handleBackNavigation() {
    if (_isLoading) return;

    final provider = Provider.of<PostProvider>(context, listen: false);
    if (_currentPage == 0) {
      provider.clear();
      context.pop();
      return;
    }
    provider.resetUIState();

    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    if (_currentPage == 1) {
      provider.goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        final canProceed = _validateCurrentPage(provider);

        return WillPopScope(
          onWillPop: _onWillPop,
          child: AbsorbPointer(
            absorbing: _isLoading,
            child: Scaffold(
              backgroundColor: AppColors.white,
              appBar: _buildAppBar(context),
              body: Stack(
                children: [
                  _buildPageViewBody(context),
                  if (_currentPage >= 2)
                    _buildBottomButton(context, provider, canProceed),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

//
  Widget _buildPageViewBody(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.only(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CatalogListPage(
                  onCatalogSelected: (catalog) {
                    provider.selectCatalog(catalog);
                    _handleNextPage();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ChildCategoryListPage(
                  onChildCategorySelected: (childCategory) {
                    provider.selectChildCategory(childCategory);
                    _handleNextPage();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const AttributesPage(),
              ),
              const AddTitlePage(),
              const AddDescriptionPage(),
              const AddPricePage(),
              const ProductConditionPage(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const MediaPage(),
              ),
            ],
          ),
        );
      },
    );
  }



  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        AppLocalizations.of(context)!.create_post,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: Constants.Arial,
          fontSize: 20,
          color: AppColors.black,
        ),
      ),
      toolbarHeight: 56.0,
      automaticallyImplyLeading: false,
      flexibleSpace: _buildProgressIndicator(),
      leadingWidth: 56,
      leading: Transform.translate(
        offset: const Offset(10, 0),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CatalogBackButton(
            onTap: _handleBackNavigation,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(
      BuildContext context, PostProvider provider, bool canProceed) {
    final isLastPage = _currentPage == 7;
    final isLoading = _isLoading;

    Widget buttonChild;
    if (isLastPage && isLoading) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Transform.scale(
              scale: 0.8,
              child: CircularProgressIndicator(
                color: AppColors.black,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _getLoadingText(provider.postCreationState),
            style: const TextStyle(fontFamily: Constants.Arial),
          ),
        ],
      );
    } else {
      buttonChild = Text(
        isLastPage
            ? AppLocalizations.of(context)!.create_post
            : AppLocalizations.of(context)!.next,
        style: const TextStyle(fontFamily: Constants.Arial),
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
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor:
                canProceed ? AppColors.black : AppColors.lighterGray,
            foregroundColor: AppColors.white,
          ),
          onPressed: (!canProceed || isLoading)
              ? null
              : () async {
                  if (isLastPage) {
                    final result = await provider.createPost();
                    result.fold(
                      (failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.postCreationError ??
                                  AppLocalizations.of(context)!
                                      .post_creation_failed,
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      (success) {
                        context
                            .read<UserPublicationsBloc>()
                            .add(RefreshUserPublications());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.post_creation_success,
                              style: TextStyle(
                                fontFamily: Constants.Arial,
                              ),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                        context.pop();
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
  }

  String _getLoadingText(PostCreationState state) {
    switch (state) {
      case PostCreationState.uploadingImages:
        return AppLocalizations.of(context)!.uploading_images;
      case PostCreationState.uploadingVideo:
        return AppLocalizations.of(context)!.uploading_video;
      case PostCreationState.creatingPost:
        return AppLocalizations.of(context)!.creating_post;
      default:
        return AppLocalizations.of(context)!.please_wait;
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
