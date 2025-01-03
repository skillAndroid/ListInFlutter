// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

import 'package:list_in/config/theme/app_colors.dart';

class ProfileEditor extends StatefulWidget {
  const ProfileEditor({super.key});

  @override
  _ProfileEditorState createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
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
  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes
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

  @override
  Widget build(BuildContext context) {
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
                child: Text('Done',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                onPressed: () {
                  _unfocusAll();
                  Navigator.of(context).pop();
                },
              ),
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
                                  color: AppColors.primaryLight,
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
                        (value) => setState(() => showExactLocation = value),
                      ),
                      _buildDivider(),
                      _buildTappableRow(
                        'Select Location',
                        showExactLocation ? 'Current Location' : 'Region Only',
                        onTap: _showMapSelector,
                      ),
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
                        (value) => setState(() => isBusinessAccount = value),
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
              color: AppColors.darkGray,
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
              ),
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
                  color: AppColors.lightText,
                  fontSize: 16,
                ),
                style: TextStyle(
                  color: AppColors.black,
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
            ),
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
              ),
            ),
            Row(
              children: [
                Text(
                  displayValue,
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 16,
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

  void _showMapSelector() {
    _unfocusAll();
    Future.delayed(Duration(milliseconds: 10), () {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.lightGray),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Select Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text('Map View'),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CupertinoButton.filled(
                    child: Text('Confirm Location'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showIOSTimePicker(bool isOpeningTime) {
    final CustomTimePickerController controller = CustomTimePickerController();
    String currentPreset = isOpeningTime ? '9 am' : '5 pm';

    // Set initial time for the controller
    if (isOpeningTime && openingTime != null) {
      controller.selectedHour = openingTime!.hourOfPeriod;
      controller.selectedMinute = openingTime!.minute;
      controller.isAM = openingTime!.period == DayPeriod.am;
    } else if (!isOpeningTime && closingTime != null) {
      controller.selectedHour = closingTime!.hourOfPeriod;
      controller.selectedMinute = closingTime!.minute;
      controller.isAM = closingTime!.period == DayPeriod.am;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                            initialTime:
                                isOpeningTime ? openingTime : closingTime,
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
                        children: isOpeningTime
                            ? [
                                _buildPresetButton(
                                    '8 am', currentPreset == '8 am', (preset) {
                                  setState(() {
                                    currentPreset = preset;
                                    controller.setFromPreset(preset);
                                  });
                                }),
                                _buildPresetButton(
                                    '9 am', currentPreset == '9 am', (preset) {
                                  setState(() {
                                    currentPreset = preset;
                                    controller.setFromPreset(preset);
                                  });
                                }),
                                _buildPresetButton(
                                    '10 am', currentPreset == '10 am',
                                    (preset) {
                                  setState(() {
                                    currentPreset = preset;
                                    controller.setFromPreset(preset);
                                  });
                                }),
                                _buildPresetButton(
                                    '11 am', currentPreset == '11 am',
                                    (preset) {
                                  setState(() {
                                    currentPreset = preset;
                                    controller.setFromPreset(preset);
                                  });
                                }),
                              ]
                            : [
                                _buildPresetButton(
                                    '5 pm', currentPreset == '5 pm', (preset) {
                                  setState(() {
                                    currentPreset = preset;
                                    controller.setFromPreset(preset);
                                  });
                                }),
                                _buildPresetButton(
                                    '6 pm', currentPreset == '6 pm', (preset) {
                                  setState(() {
                                    currentPreset = preset;
                                    controller.setFromPreset(preset);
                                  });
                                }),
                                _buildPresetButton(
                                    '7 pm', currentPreset == '7 pm', (preset) {
                                  setState(() {
                                    currentPreset = preset;
                                    controller.setFromPreset(preset);
                                  });
                                }),
                                _buildPresetButton(
                                    '8 pm', currentPreset == '8 pm', (preset) {
                                  setState(() {
                                    currentPreset = preset;
                                    controller.setFromPreset(preset);
                                  });
                                }),
                              ],
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

class CustomTimePickerController {
  int selectedHour = TimeOfDay.now().hourOfPeriod;
  int selectedMinute = TimeOfDay.now().minute;
  bool isAM = TimeOfDay.now().period == DayPeriod.am;

  void setFromPreset(String preset) {
    final parts = preset.split(' ');
    final hour = int.parse(parts[0]);
    final isPM = parts[1].toLowerCase() == 'pm';

    selectedHour = hour;
    selectedMinute = 0;
    isAM = !isPM;
  }

  TimeOfDay getSelectedTime() {
    final hour = selectedHour + (isAM ? 0 : 12);
    return TimeOfDay(hour: hour == 24 ? 0 : hour, minute: selectedMinute);
  }
}

class CustomTimePicker extends StatefulWidget {
  final CustomTimePickerController controller;
  final TimeOfDay? initialTime;

  const CustomTimePicker({
    super.key,
    required this.controller,
    this.initialTime,
  });

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  @override
  void initState() {
    super.initState();

    // Initialize with current time or initial time if provided
    final time = widget.initialTime ?? TimeOfDay.now();
    widget.controller.selectedHour = time.hourOfPeriod;
    widget.controller.selectedMinute = time.minute;
    widget.controller.isAM = time.period == DayPeriod.am;

    // Initialize scroll controllers with initial positions
    _hourController = FixedExtentScrollController(
        initialItem: widget.controller.selectedHour - 1);
    _minuteController = FixedExtentScrollController(
        initialItem: widget.controller.selectedMinute);
    _periodController = FixedExtentScrollController(
        initialItem: widget.controller.isAM ? 0 : 1);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hours wheel
          SizedBox(
            width: 70,
            child: ListWheelScrollView.useDelegate(
              controller: _hourController,
              itemExtent: 40,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  widget.controller.selectedHour = index + 1;
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 12,
                builder: (context, index) {
                  return _TimePickerItem(
                    text: '${index + 1}',
                    isSelected: widget.controller.selectedHour == index + 1,
                  );
                },
              ),
            ),
          ),
          Text(
            ':',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          // Minutes wheel
          SizedBox(
            width: 70,
            child: ListWheelScrollView.useDelegate(
              controller: _minuteController,
              itemExtent: 40,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  widget.controller.selectedMinute = index;
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 60,
                builder: (context, index) {
                  return _TimePickerItem(
                    text: index.toString().padLeft(2, '0'),
                    isSelected: widget.controller.selectedMinute == index,
                  );
                },
              ),
            ),
          ),
          // AM/PM wheel
          SizedBox(
            width: 70,
            child: ListWheelScrollView.useDelegate(
              controller: _periodController,
              itemExtent: 40,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  widget.controller.isAM = index == 0;
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 2,
                builder: (context, index) {
                  return _TimePickerItem(
                    text: index == 0 ? 'am' : 'pm',
                    isSelected: (index == 0) == widget.controller.isAM,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePickerItem extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _TimePickerItem({
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSelected ? 30 : 20,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? Colors.black : Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
