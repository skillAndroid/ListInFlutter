// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/presentation/widgets/page_call_back_button.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_state.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';
import 'package:list_in/features/profile/presentation/widgets/description_widget.dart';
import 'package:list_in/features/profile/presentation/widgets/media_widget.dart';
import 'package:list_in/features/profile/presentation/widgets/price_widget.dart';
import 'package:list_in/features/profile/presentation/widgets/product_condition_page.dart';
import 'package:list_in/features/profile/presentation/widgets/title_widget.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PublicationsEditorPage extends StatefulWidget {
  const PublicationsEditorPage({super.key});

  @override
  State<PublicationsEditorPage> createState() => _PublicationsEditorPageState();
}

class _PublicationsEditorPageState extends State<PublicationsEditorPage> {
  late final PageController _pageController;
  late int _currentPage;
  late double _progressValue;
  final int _pageCount = 5;
  bool get _isUpdating =>
      context.read<PublicationUpdateBloc>().state.updatingState !=
      PublicationUpdatingState.initial;

  bool _isTitleValid(PublicationUpdateState state) {
    return state.title.length >= 7;
  }

  bool _isDescriptionValid(PublicationUpdateState state) {
    return state.description.length >= 30;
  }

  bool _isPriceValid(PublicationUpdateState state) {
    return state.price > 0;
  }

  bool _isConditionValid(PublicationUpdateState state) {
    return state.condition.isNotEmpty;
  }

  bool _hasValidMedia(PublicationUpdateState state) {
    final hasExistingImages = state.imageUrls?.isNotEmpty ?? false;
    final hasNewImages = state.newImages.isNotEmpty;
    return hasExistingImages || hasNewImages;
  }

  bool _canProceedToNextPage(PublicationUpdateState state) {
    switch (_currentPage) {
      case 0:
        return _isTitleValid(state);
      case 1:
        return _isDescriptionValid(state);
      case 2:
        return _isPriceValid(state);
      case 3:
        return _isConditionValid(state);
      case 4:
        return _hasValidMedia(state);
      default:
        return false;
    }
  }

  String _getValidationMessage(PublicationUpdateState state) {
    switch (_currentPage) {
      case 0:
        return AppLocalizations.of(context)!.title_min_length;
      case 1:
        return AppLocalizations.of(context)!.description_min_length;
      case 2:
        return AppLocalizations.of(context)!.enter_valid_price;
      case 3:
        return AppLocalizations.of(context)!.select_condition;
      case 4:
        return AppLocalizations.of(context)!.add_at_least_one_image;
      default:
        return '';
    }
  }

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
    context.read<PublicationUpdateBloc>().add(ClearPublicationState());
    super.dispose();
  }

  void _updateProgress(int pageIndex) {
    setState(() {
      _progressValue = (pageIndex + 1) / _pageCount;
    });
  }

  void _handleNextPage() {
    final state = context.read<PublicationUpdateBloc>().state;

    if (!_canProceedToNextPage(state)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getValidationMessage(state)),
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

  void _handleBackNavigation() {
    if (_isUpdating) return; // Prevent back navigation during update

    if (_currentPage == 0) {
      context.pop();
      return;
    }

    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<bool> _onWillPop() async {
    if (_isUpdating) return false; // Prevent back navigation during update
    if (_currentPage > 0) {
      _handleBackNavigation();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PublicationUpdateBloc, PublicationUpdateState>(
      listenWhen: (previous, current) =>
          previous.isSuccess != current.isSuccess ||
          previous.error != current.error,
      listener: (context, state) {
        if (state.isSuccess) {
          context.read<UserPublicationsBloc>().add(RefreshUserPublications());
          context.read<PublicationUpdateBloc>().add(ClearPublicationState());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.publication_updated,
                style: TextStyle(fontFamily: Constants.Arial),
              ),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.of(context).pop();
          context.pop();
        } else if (state.error != null) {
          context.read<PublicationUpdateBloc>().add(ClearPublicationState());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final shouldBlockUI =
            state.isSubmitting && !state.isSuccess && state.error == null;
        return WillPopScope(
          onWillPop: _onWillPop,
          child: AbsorbPointer(
            absorbing: shouldBlockUI, // Prevent all interactions during update
            child: Scaffold(
              backgroundColor: AppColors.bgColor,
              appBar: _buildAppBar(context),
              body: Stack(
                children: [
                  _buildPageViewBody(context),
                  _buildBottomButton(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageViewBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 0.0,
        right: 0.0,
        bottom: _currentPage >= 2 ? 80.0 : 8,
      ),
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
            _updateProgress(index);
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          AddTitleWidget(),
          AddDescriptionWidget(),
          AddPriceWidget(),
          ProductConditionWidget(),
          MediaWidget(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        AppLocalizations.of(context)!.update_post,
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

  Widget _buildProgressIndicator() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: _progressValue, end: _progressValue),
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        backgroundColor: AppColors.containerColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.lighterGray.withOpacity(0.5),
        ),
        minHeight: double.infinity,
      ),
    );
  }

  Widget _buildBottomButton(
      BuildContext context, PublicationUpdateState state) {
    final isLastPage = _currentPage == _pageCount - 1;
    // Only show loading if submitting and not yet successful
    final isLoading = state.isSubmitting && !state.isSuccess;
    final canProceed = _canProceedToNextPage(state);

    Widget buttonChild;
    if (isLastPage) {
      buttonChild = isLoading
          ? Row(
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
                  AppLocalizations.of(context)!.updating,
                  style: const TextStyle(fontFamily: Constants.Arial),
                ),
              ],
            )
          : Text(
              'Update',
              style: const TextStyle(
                fontFamily: Constants.Arial,
              ),
            );
    } else {
      buttonChild = Text(
        AppLocalizations.of(context)!.next,
        style: const TextStyle(
          fontFamily: Constants.Arial,
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
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor:
                canProceed ? AppColors.black : AppColors.lighterGray,
            foregroundColor: AppColors.white,
          ),
          onPressed: (!canProceed || isLoading)
              ? null
              : () {
                  if (isLastPage) {
                    context
                        .read<PublicationUpdateBloc>()
                        .add(SubmitPublicationUpdate());
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
}
