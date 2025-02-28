// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<void> _onPop() async {
    context.read<HomeTreeCubit>().clearSearchText();
  }

  void _fetchInitialData() {
    context.read<HomeTreeCubit>().fetchCatalogs();
  }

  Widget _buildPredictionsList() {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        if (state.predictionsRequestState == RequestState.inProgress) {
          return const Progress();
        }

        if (state.predictions.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.predictions.length,
          separatorBuilder: (context, index) => Padding(
            padding:
                const EdgeInsets.only(top: 4), // Add some space above divider
            child: Divider(
              height: 1,
              thickness: 1, // Make divider thicker
              color: AppColors.containerColor, // Subtle grey color
            ),
          ), // Make divider more compact
          itemBuilder: (context, index) {
            final prediction = state.predictions[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.black),
              visualDensity:
                  VisualDensity(vertical: -4), // Reduce vertical padding
              minLeadingWidth: 0, // Minimize leading width
              title: Text(
                prediction.childAttributeValue ?? '',
                style: TextStyle(fontSize: 14), // Adjust font size if needed
              ),
              subtitle: Text(
                state.predictions[index].categoryName
                    .toString(), // Add subtitle as shown in image
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.activeGreen,
                ),
              ),
              onTap: () {
                _searchController.text = prediction.childAttributeValue ?? '';
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _searchController.text.length),
                );
                context
                    .read<HomeTreeCubit>()
                    .handlePredictionSelection(prediction, context);
                FocusScope.of(context).unfocus();
              },
            );
          },
        );
      },
    );
  }

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _onPop();
        return true; // Allow pop to proceed
      },
      child: BlocConsumer<HomeTreeCubit, HomeTreeState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: _buildAppBar(state),
            body: _buildPredictionsList(),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 50), () {
        _searchFocusNode.requestFocus();
      });
    });
    final currentSearchText = context.read<HomeTreeCubit>().state.searchText;
    if (currentSearchText != null) {
      _searchController.text = currentSearchText;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar(HomeTreeState state) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.bgColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SmoothClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.containerColor,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  AppIcons.searchIcon,
                                  width: 24,
                                  height: 24,
                                  color: AppColors.black,
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    TextField(
                                      focusNode: _searchFocusNode,
                                      controller: _searchController,
                                      cursorRadius: const Radius.circular(2),
                                      textInputAction: TextInputAction.search,
                                      onChanged: (value) {
                                        context.read<HomeTreeCubit>()
                                          ..updateSearchText(value)
                                          ..getPredictions();
                                      },
                                      onSubmitted: (value) async {
                                        if (value.isNotEmpty) {
                                          context.replaceNamed(
                                            RoutesByName.searchResult,
                                          );
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        hintStyle: TextStyle(
                                            color: AppColors.darkGray),
                                        contentPadding: EdgeInsets.zero,
                                        hintText: "Search...",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 2),
                              if (state.searchText != null)
                                IconButton(
                                  color: AppColors.black,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<HomeTreeCubit>()
                                        .clearSearchText();
                                    context.read<HomeTreeCubit>();
                                    context
                                        .read<HomeTreeCubit>()
                                        .clearPrediction();
                                    context.read<HomeTreeCubit>();
                                  },
                                ),
                              const SizedBox(width: 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Cansel',
                        style: TextStyle(
                          fontFamily: Constants.Arial,
                          color: CupertinoColors.activeGreen,
                        ),
                      ),
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
}
