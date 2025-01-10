// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/presentation/map/map.dart';
import 'package:list_in/features/profile/domain/entity/user_profile_entity.dart';
import 'package:list_in/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user_profile_event.dart';
import 'package:list_in/features/profile/presentation/bloc/user_profile_state.dart';
import 'package:list_in/features/profile/presentation/widgets/cutom_time_picker.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

import 'package:list_in/config/theme/app_colors.dart';

class ProfileEditor extends StatefulWidget {
  final UserProfileEntity userData;

  const ProfileEditor({super.key, required this.userData});

  @override
  _ProfileEditorState createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  String? _locationName;
  bool showExactLocation = false;
  bool isBusinessAccount = false;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  XFile? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _locationName = widget.userData.locationName ?? 'No Location';
    _nameController.text = widget.userData.nickName ?? '';
    _phoneController.text = widget.userData.phoneNumber ?? '';
    _profileImagePath = widget.userData.profileImagePath;
    isBusinessAccount = widget.userData.isBusinessAccount ?? false;
    showExactLocation = widget.userData.isGrantedForPreciseLocation ?? false;

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
    _phoneFocusNode.dispose();
    _nameController.dispose();
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
            title: Text('Error'),
            content: Text('Failed to pick image. Please try again.'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
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

    final updatedProfile = UserProfileEntity(
      nickName: _nameController.text,
      phoneNumber: _phoneController.text,
      isBusinessAccount: isBusinessAccount,
      isGrantedForPreciseLocation: showExactLocation,
      profileImagePath: _profileImagePath,
      fromTime: formattedFromTime,
      toTime: formattedToTime,
      longitude: widget.userData.longitude,
      latitude: widget.userData.latitude,
      locationName: widget.userData.locationName,
    );

    // Check if data has changed
    bool hasChanges = updatedProfile.nickName != widget.userData.nickName ||
        updatedProfile.phoneNumber != widget.userData.phoneNumber ||
        updatedProfile.isBusinessAccount != widget.userData.isBusinessAccount ||
        updatedProfile.isGrantedForPreciseLocation !=
            widget.userData.isGrantedForPreciseLocation ||
        updatedProfile.fromTime != widget.userData.fromTime ||
        updatedProfile.toTime != widget.userData.toTime ||
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
              title: Text('Error'),
              content: Text(state.errorMessage ?? 'An error occurred'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        } else if (state.status == UserProfileStatus.success) {
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
                backgroundColor: AppColors.bgColor,
                navigationBar: CupertinoNavigationBar(
                  backgroundColor: AppColors.white,
                  middle: Text('Edit Profile',
                      style: TextStyle(
                          color: AppColors.black, fontWeight: FontWeight.w600)),
                  trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _handleSave,
                      child: Text('Done',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600))),
                ),
                child: SafeArea(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    children: [
                      // Profile Photo Section
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
                                    color: AppColors.containerColor,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: _profileImagePath != null
                                        ? Image.file(
                                            File(_profileImagePath!),
                                            fit: BoxFit.cover,
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
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.camera_fill,
                                      color: AppColors.white,
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
                                'Change Profile Photo',
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

                      // Profile Info Section
                      _buildSection(
                        title: 'PROFILE INFORMATION',
                        children: [
                          _buildTextField('Name', 'Enter your name'),
                          _buildDivider(),
                          _buildTextField('Phone', 'Enter phone number',
                              isPhone: true),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Location Section
                      _buildSection(
                        title: 'LOCATION',
                        children: [
                          _buildSwitchRow(
                            'Show Exact Location',
                            showExactLocation,
                            (value) =>
                                setState(() => showExactLocation = value),
                          ),
                          _buildDivider(),
                          _buildTappableRow(
                              'Select Location',
                              showExactLocation
                                  ? _locationName.toString()
                                  : _locationName.toString(), onTap: () {
                            _showMapSelector(context);
                          }),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Working Hours Section
                      _buildSection(
                        title: 'WORKING HOURS',
                        children: [
                          _buildTappableRow(
                            'Opening Time',
                            openingTime?.format(context) ?? 'Select Time',
                            onTap: () => _showIOSTimePicker(true),
                          ),
                          _buildDivider(),
                          _buildTappableRow(
                            'Closing Time',
                            closingTime?.format(context) ?? 'Select Time',
                            onTap: () => _showIOSTimePicker(false),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Account Type Section
                      _buildSection(
                        title: 'ACCOUNT TYPE',
                        children: [
                          _buildSwitchRow(
                            'Business Account',
                            isBusinessAccount,
                            (value) =>
                                setState(() => isBusinessAccount = value),
                          ),
                        ],
                        footer: Text(
                          isBusinessAccount
                              ? 'Business features are currently active'
                              : 'Switch to business account to access additional features',
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
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.containerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        if (footer != null)
          Padding(
            padding: EdgeInsets.all(16),
            child: footer,
          ),
      ],
    );
  }

  Widget _buildTextField(String label, String placeholder,
      {bool isPhone = false}) {
    final focusNode = isPhone ? _phoneFocusNode : _nameFocusNode;
    final controller = isPhone ? _phoneController : _nameController;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                  color: AppColors.black,
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
                  fontFamily: "Poppins",
                  color: AppColors.lightText,
                  fontSize: 16,
                ),
                style: TextStyle(
                  color: AppColors.lightText,
                  fontFamily: "Poppins",
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                color: AppColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTappableRow(String label, String value, {VoidCallback? onTap}) {
    // Format the time display string
    String displayValue = value;
    if (label == "Opening Time" && openingTime != null) {
      displayValue = _formatTimeOfDay(openingTime!);
    } else if (label == "Closing Time" && closingTime != null) {
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
                  color: AppColors.black,
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
    final period = time.period == DayPeriod.am ? 'am' : 'pm';
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
              child: Text('Take Photo'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: Text('Choose from Library'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
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
      builder: (BuildContext context) => const FractionallySizedBox(
        heightFactor: 1.0,
        child: Scaffold(body: ListInMap()),
      ),
    );

    if (result != null) {
      setState(() {
        _locationName = result.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location updated to: ${result.name}")),
      );
    }
  }

  void _showIOSTimePicker(bool isOpeningTime) {
    final CustomTimePickerController controller = CustomTimePickerController();
    String currentPreset = isOpeningTime ? '9 am' : '5 pm';

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
      barrierColor: Colors.black54,
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
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 530,
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with title
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                              child: Icon(Icons.close, size: 20),
                            ),
                          ),
                          Text(
                            isOpeningTime ? 'Opening Time' : 'Closing Time',
                            style: TextStyle(
                              fontSize: 24,
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
                          CustomTimePicker(
                            controller: controller,
                            initialTime: initialTime,
                            onTimeChanged: onTimeChanged,
                          ),
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
                        ],
                      ),
                    ),

                    // Presets section
                    Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Presets',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
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
                            shape: SmoothRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 17,
                              color: AppColors.white,
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
        ? ['8 am', '9 am', '10 am', '11 am']
        : ['5 pm', '6 pm', '7 pm', '8 pm'];

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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.containerColor,
            width: isSelected ? 2.5 : 1.75,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
