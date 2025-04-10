// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/presentation/map/map.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_event.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_state.dart';
import 'package:list_in/features/profile/presentation/widgets/cutom_time_picker.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileEditor extends StatefulWidget {
  final UserProfileEntity userData;

  const ProfileEditor({super.key, required this.userData});

  @override
  _ProfileEditorState createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  String? _locationName;
  double? _latitude;
  double? _longitude;
  String? country;
  String? state;
  String? county;

  bool showExactLocation = false;
  bool isBusinessAccount = false;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _bioFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  XFile? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _latitude = widget.userData.latitude;
    _longitude = widget.userData.longitude;
    _locationName = widget.userData.locationName ?? "";
    _nameController.text = widget.userData.nickName ?? '';
    _bioController.text = widget.userData.biography ?? '';
    _phoneController.text = widget.userData.phoneNumber ?? '';
    _profileImagePath = widget.userData.profileImagePath;
    isBusinessAccount = widget.userData.isBusinessAccount ?? false;
    showExactLocation = widget.userData.isGrantedForPreciseLocation ?? false;
    country = widget.userData.country;
    state = widget.userData.state;
    county = widget.userData.county;
    if (widget.userData.fromTime != null) {
      final parts = widget.userData.fromTime!.split(':');
      openingTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    if (widget.userData.toTime != null) {
      final parts = widget.userData.toTime!.split(':');
      closingTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        _phoneFocusNode.unfocus();
      }
    });

    _bioFocusNode.addListener(() {
      if (_bioFocusNode.hasFocus) {
        _bioFocusNode.unfocus;
      }
    });

    _phoneFocusNode.addListener(() {
      if (_phoneFocusNode.hasFocus) {
        _nameFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _nameFocusNode.dispose();
    _bioFocusNode.dispose();
    _phoneFocusNode.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _unfocusAll() {
    _focusScopeNode.unfocus();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
          _selectedImageFile = image;
        });
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(AppLocalizations.of(context)!.image_pick_failed),
            actions: [
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleSave() {
    String? formattedFromTime;
    String? formattedToTime;

    if (openingTime != null) {
      final hour = openingTime!.hour.toString().padLeft(2, '0');
      final minute = openingTime!.minute.toString().padLeft(2, '0');
      formattedFromTime = '$hour:$minute';
    }

    if (closingTime != null) {
      final hour = closingTime!.hour.toString().padLeft(2, '0');
      final minute = closingTime!.minute.toString().padLeft(2, '0');
      formattedToTime = '$hour:$minute';
    }
    final cleanedLocationName = cleanLocationName(_locationName.toString());

    debugPrint("✅user country: $country");
    debugPrint("✅user state: $state");
    debugPrint("✅user county: $county");
    final updatedProfile = UserProfileEntity(
      nickName: _nameController.text,
      phoneNumber: _phoneController.text,
      biography: _bioController.text.isEmpty ? null : _bioController.text,
      isBusinessAccount: isBusinessAccount,
      isGrantedForPreciseLocation: showExactLocation,
      profileImagePath: _profileImagePath,
      fromTime: formattedFromTime,
      toTime: formattedToTime,
      longitude: _longitude,
      latitude: _latitude,
      county: county,
      state: state,
      country: country,
      locationName: cleanedLocationName,
    );

    // Update the hasChanges check to include location changes
    bool hasChanges = updatedProfile.nickName != widget.userData.nickName ||
        updatedProfile.phoneNumber != widget.userData.phoneNumber ||
        updatedProfile.biography != widget.userData.biography ||
        updatedProfile.isBusinessAccount != widget.userData.isBusinessAccount ||
        updatedProfile.isGrantedForPreciseLocation !=
            widget.userData.isGrantedForPreciseLocation ||
        updatedProfile.fromTime != widget.userData.fromTime ||
        updatedProfile.toTime != widget.userData.toTime ||
        updatedProfile.longitude !=
            widget.userData.longitude || // Add location checks
        updatedProfile.latitude != widget.userData.latitude ||
        updatedProfile.locationName != widget.userData.locationName ||
        updatedProfile.country != widget.userData.country ||
        updatedProfile.state != widget.userData.state ||
        updatedProfile.county != widget.userData.county ||
        _selectedImageFile != null;

    if (!hasChanges) {
      Navigator.pop(context);
      return;
    }

    context.read<UserProfileBloc>().add(
          UpdateUserProfileWithImage(
            profile: updatedProfile,
            imageFile: _selectedImageFile,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state.status == UserProfileStatus.failure) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text(AppLocalizations.of(context)!.error),
              content: Text(state.errorMessage ??
                  AppLocalizations.of(context)!.an_error_occurred),
              actions: [
                CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.ok),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        } else if (state.status == UserProfileStatus.success ||
            state.status == UserProfileStatus.failure) {
          // Navigate back on success
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: FocusScope(
            node: _focusScopeNode,
            child: GestureDetector(
              onTap: _unfocusAll,
              child: CupertinoPageScaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                navigationBar: CupertinoNavigationBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  middle: Text(
                    AppLocalizations.of(context)!.edit_profile,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: state.status == UserProfileStatus.loading
                      ? Text(
                          AppLocalizations.of(context)!.updating,
                          style: TextStyle(
                            color: AppColors.primary,
                          ),
                        )
                      : CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: state.status == UserProfileStatus.loading
                              ? null // Disable button while loading
                              : _handleSave,
                          child: Text(
                            AppLocalizations.of(context)!.done,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                child: SafeArea(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor,
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: _selectedImageFile != null
                                        // Show locally selected image
                                        ? Image.file(
                                            File(_selectedImageFile!.path),
                                            fit: BoxFit.cover,
                                          )
                                        // Show network image or default icon
                                        : _profileImagePath != null
                                            ? CachedNetworkImage(
                                                imageUrl:
                                                    "https://$_profileImagePath",
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  CupertinoIcons.person_fill,
                                                  size: 60,
                                                  color: AppColors.grey,
                                                ),
                                              )
                                            : Icon(
                                                CupertinoIcons.person_fill,
                                                size: 60,
                                                color: AppColors.grey,
                                              ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.camera_fill,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _showPhotoOptions,
                              child: Text(
                                AppLocalizations.of(context)!
                                    .change_profile_photo,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildSection(
                        title: AppLocalizations.of(context)!.your_biography,
                        children: [
                          _buildBioTextField(),
                        ],
                      ),

                      SizedBox(height: 24),
                      // Profile Info Section
                      _buildSection(
                        title: AppLocalizations.of(context)!.profile_info,
                        children: [
                          _buildTextField(
                            AppLocalizations.of(context)!.name,
                            AppLocalizations.of(context)!.enter_name,
                          ),
                          _buildDivider(),
                          _buildTextField(AppLocalizations.of(context)!.phone,
                              AppLocalizations.of(context)!.enterPhoneNumber,
                              isPhone: true),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Location Section
                      _buildSection(
                        title: AppLocalizations.of(context)!.location_bg,
                        children: [
                          _buildSwitchRow(
                            AppLocalizations.of(context)!.show_exact_location,
                            showExactLocation,
                            (value) =>
                                setState(() => showExactLocation = value),
                          ),
                          _buildDivider(),
                          _buildTappableRow(
                              AppLocalizations.of(context)!.location,
                              showExactLocation
                                  ? cleanLocationName(_locationName.toString())
                                  : _locationName.toString(), onTap: () {
                            _showMapSelector(context);
                          }),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Working Hours Section
                      _buildSection(
                        title: AppLocalizations.of(context)!.working_hours,
                        children: [
                          _buildTappableRow(
                            AppLocalizations.of(context)!.opening_time,
                            openingTime?.format(context) ??
                                AppLocalizations.of(context)!.select_time,
                            onTap: () => _showIOSTimePicker(true),
                          ),
                          _buildDivider(),
                          _buildTappableRow(
                            AppLocalizations.of(context)!.closing_time,
                            closingTime?.format(context) ??
                                AppLocalizations.of(context)!.select_time,
                            onTap: () => _showIOSTimePicker(false),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Account Type Section
                      _buildSection(
                        title: AppLocalizations.of(context)!.account_type,
                        children: [
                          _buildSwitchRow(
                            AppLocalizations.of(context)!.business_account,
                            isBusinessAccount,
                            (value) =>
                                setState(() => isBusinessAccount = value),
                          ),
                        ],
                        footer: Text(
                          isBusinessAccount
                              ? AppLocalizations.of(context)!
                                  .business_features_active
                              : AppLocalizations.of(context)!
                                  .switch_to_business,
                          style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Widget? footer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipSmoothRect(
            radius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 1,
            ),
            child: Container(
              color: Theme.of(context).cardColor,
              child: Column(children: children),
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: EdgeInsets.all(16),
            child: footer,
          ),
      ],
    );
  }

  Widget _buildBioTextField() {
    debugPrint("😉😉Here is the BIO TEXT : ${_bioController.text}");
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField.borderless(
            controller: _bioController,
            focusNode: _bioFocusNode,
            maxLength: 70,
            maxLines: 3,
            minLines: 1,
            placeholder: AppLocalizations.of(context)!.write_about_yourself,
            placeholderStyle: TextStyle(
              color: AppColors.lightText,
              fontSize: 16,
              fontFamily: Constants.Arial,
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
              fontFamily: Constants.Arial,
            ),
            onChanged: (value) {
              // Force refresh to update character count
              setState(() {});
            },
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_bioController.text.length}/70',
              style: TextStyle(
                color: _bioController.text.length >= 70
                    ? AppColors.primary
                    : AppColors.lightText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder,
      {bool isPhone = false}) {
    final focusNode = isPhone ? _phoneFocusNode : _nameFocusNode;
    final controller = isPhone ? _phoneController : _nameController;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  // Unfocus the other field when this one gets focus
                  if (isPhone) {
                    _nameFocusNode.unfocus();
                  } else {
                    _phoneFocusNode.unfocus();
                  }
                }
              },
              child: CupertinoTextField.borderless(
                controller: controller,
                focusNode: focusNode,
                placeholder: placeholder,
                keyboardType:
                    isPhone ? TextInputType.phone : TextInputType.text,
                placeholderStyle: TextStyle(
                  fontFamily: Constants.Arial,
                  color: AppColors.lightText,
                  fontSize: 16,
                ),
                style: TextStyle(
                  color: AppColors.lightText,
                  fontFamily: Constants.Arial,
                  fontSize: 16,
                ),
                onTap: () {
                  // Unfocus the other field when this one is tapped
                  if (isPhone) {
                    _nameFocusNode.unfocus();
                  } else {
                    _phoneFocusNode.unfocus();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTappableRow(String label, String value, {VoidCallback? onTap}) {
    // Format the time display string
    String displayValue = value;
    if (label == AppLocalizations.of(context)!.opening_time &&
        openingTime != null) {
      displayValue = _formatTimeOfDay(openingTime!);
    } else if (label == AppLocalizations.of(context)!.closing_time &&
        closingTime != null) {
      displayValue = _formatTimeOfDay(closingTime!);
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    displayValue,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: AppColors.lightText,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Add this helper method to format TimeOfDay
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am
        ? AppLocalizations.of(context)!.am
        : AppLocalizations.of(context)!.pm;
    return '$hour:$minute $period';
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.lightGray,
      margin: EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _showPhotoOptions() {
    _unfocusAll();
    Future.delayed(Duration(milliseconds: 10), () {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: Text(AppLocalizations.of(context)!.take_photo),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: Text(AppLocalizations.of(context)!.choose_from_library),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ),
      );
    });
  }

  Future<void> _showMapSelector(BuildContext context) async {
    _unfocusAll();
    final result = await showModalBottomSheet<LocationEntity>(
      useRootNavigator: true,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (BuildContext context) => FractionallySizedBox(
        heightFactor: 1.0,
        child: Scaffold(
          body: ListInMap(
            coordinates: LatLng(_latitude ?? 41.2995, _longitude ?? 69.2401),
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _locationName = result.name;
        _latitude = result.coordinates.latitude;
        _longitude = result.coordinates.longitude;
        final locationDetails = parseLocationName(_locationName.toString());
        country = locationDetails['country'];
        state = locationDetails['state'];
        county = locationDetails['county'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "${AppLocalizations.of(context)!.location_updated} ${result.name}")),
      );
    }
  }

  void _showIOSTimePicker(bool isOpeningTime) {
    final CustomTimePickerController controller = CustomTimePickerController();
    String currentPreset = isOpeningTime
        ? AppLocalizations.of(context)!.am_9
        : AppLocalizations.of(context)!.pm_5;

    // Set initial time for the controller
    TimeOfDay? initialTime = isOpeningTime ? openingTime : closingTime;
    if (initialTime != null) {
      controller.selectedHour = initialTime.hourOfPeriod;
      controller.selectedMinute = initialTime.minute;
      controller.isAM = initialTime.period == DayPeriod.am;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void onTimeChanged(TimeOfDay newTime) {
              setState(() {
                if (isOpeningTime) {
                  openingTime = newTime;
                } else {
                  closingTime = newTime;
                }
              });
              setModalState(() {}); // Update modal state if needed
            }

            return SmoothClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 530,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with title
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.8),
                              ),
                              child: Icon(Icons.close_rounded, size: 20),
                            ),
                          ),
                          Text(
                            isOpeningTime
                                ? AppLocalizations.of(context)!.opening_time
                                : AppLocalizations.of(context)!.closing_time,
                            style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 40), // For balance
                        ],
                      ),
                    ),

                    // Time Picker
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: SmoothClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 48,
                                    color: AppColors.darkGray.withOpacity(0.1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          CustomTimePicker(
                            controller: controller,
                            initialTime: initialTime,
                            onTimeChanged: onTimeChanged,
                          ),
                        ],
                      ),
                    ),

                    // Presets section
                    Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.presets,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),

                    // Preset buttons
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _buildPresetButtons(
                          isOpeningTime,
                          currentPreset,
                          (String preset) {
                            controller.setFromPreset(preset);
                            onTimeChanged(controller.getSelectedTime());
                            setModalState(() {
                              currentPreset = preset;
                            });
                          },
                        ),
                      ),
                    ),

                    // Done button
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // shape: SmoothRectangleBorder(
                            //   borderRadius: BorderRadius.circular(12),
                            // ),
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.done,
                            style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            final selectedTimeOfDay =
                                controller.getSelectedTime();

                            // Update the parent widget's state
                            setState(() {
                              // Use the parent's setState
                              if (isOpeningTime) {
                                openingTime = selectedTimeOfDay;
                              } else {
                                closingTime = selectedTimeOfDay;
                              }
                            });

                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPresetButtons(
    bool isOpeningTime,
    String currentPreset,
    Function(String) onTap,
  ) {
    final List<String> presets = isOpeningTime
        ? [
            AppLocalizations.of(context)!.am_8,
            AppLocalizations.of(context)!.am_9,
            AppLocalizations.of(context)!.am_10,
            AppLocalizations.of(context)!.am_11,
          ]
        : [
            AppLocalizations.of(context)!.pm_5,
            AppLocalizations.of(context)!.pm_6,
            AppLocalizations.of(context)!.pm_7,
            AppLocalizations.of(context)!.pm_8,
          ];

    return presets
        .map((preset) => _buildPresetButton(
              preset,
              currentPreset == preset,
              onTap,
            ))
        .toList();
  }

  Widget _buildPresetButton(
      String time, bool isSelected, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(time),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
            width: isSelected ? 2.25 : 1.75,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).colorScheme.secondary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
