import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeTreeCubit, HomeTreeState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(state),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final currentSearchText =
        context.read<HomeTreeCubit>().state.initialSearchText;
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
                                child: TextField(
                                  controller: _searchController,
                                  cursorRadius: const Radius.circular(2),
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (value) async {
                                    if (value.isNotEmpty) {
                                      context
                                          .read<HomeTreeCubit>()
                                          .handleInitialSearch(value);
                                      context.pop();
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    hintStyle:
                                        TextStyle(color: AppColors.darkGray),
                                    contentPadding: EdgeInsets.zero,
                                    hintText: "Search...",
                                    border: InputBorder.none,
                                  ),
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
