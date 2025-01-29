// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.predictions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.predictions.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final prediction = state.predictions[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(prediction.name ?? ''),
                subtitle: Text(prediction.categoryId ?? ''),
                onTap: () {
                  _searchController.text = prediction.name ?? '';
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _searchController.text.length),
                  );

                  // Handle the prediction selection and navigation
                  context
                      .read<HomeTreeCubit>()
                      .handlePredictionSelection(prediction, context);

                  FocusScope.of(context).unfocus();
                },
              );
            },
          ),
        );
      },
    );
  }

  final TextEditingController _searchController = TextEditingController();
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
    final currentSearchText = context.read<HomeTreeCubit>().state.searchText;
    if (currentSearchText != null) {
      _searchController.text = currentSearchText;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                    Transform.translate(
                      offset: const Offset(-10, 0),
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SmoothClipRRect(
                        smoothness: 1,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 48,
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
                                  color: AppColors.grey,
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    TextField(
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
                                              RoutesByName.searchResult);
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
                                    if (state.searchPublicationsRequestState ==
                                        RequestState.inProgress)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.grey),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const VerticalDivider(
                                color: AppColors.lightGray,
                                width: 1,
                                indent: 12,
                                endIndent: 12,
                              ),
                              const SizedBox(width: 2),
                              IconButton(
                                icon: Image.asset(
                                  AppIcons.filterIc,
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 2),
                            ],
                          ),
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
