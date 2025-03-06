import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneSettingsPage extends StatefulWidget {
  const PhoneSettingsPage({super.key});

  @override
  State<PhoneSettingsPage> createState() => _PhoneSettingsPageState();
}

class _PhoneSettingsPageState extends State<PhoneSettingsPage> {
  late TextEditingController _phoneController;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PostProvider>(context, listen: false);
    _phoneController = TextEditingController(text: provider.phoneNumber);
    _startTime = provider.callStartTime;
    _endTime = provider.callEndTime;

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        _validatePhone(_phoneController.text);
      });
    });
  }

  String? _validatePhone(String value) {
    if (value.isEmpty) {
      _errorText = AppLocalizations.of(context)!.phone_number_not_required;
    } else if (value.length != 12 || !value.startsWith('+998')) {
      _errorText = AppLocalizations.of(context)!.enter_valid_uzbekistan_number;
    } else {
      _errorText = null;
    }
    return _errorText;
  }

  // Inside _PhoneSettingsPageState class
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showThemedTimePicker(
      context: context,
      initialTime: isStartTime
          ? _startTime ?? TimeOfDay.now()
          : _endTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });

      if (mounted) {
        final provider = Provider.of<PostProvider>(context, listen: false);
        provider.setCallTime(_startTime!, _endTime!);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information Card
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: AppColors.containerColor,
              shape: SmoothRectangleBorder(
                smoothness: 1,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.contact_information,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: Constants.Arial,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.update_contact_info,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: null,
                      isSemanticButton: false,
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(AppColors.white)),
                      child: Text(
                        AppLocalizations.of(context)!.update_profile_settings,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: Constants.Arial,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              AppLocalizations.of(context)!.phone_number_optional,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: Constants.Arial,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: SmoothClipRRect(
                smoothness: 1,
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: _errorText != null ? Colors.red : AppColors.black,
                  width: 2,
                  style: _isFocused ? BorderStyle.solid : BorderStyle.none,
                ),
                child: TextField(
                  controller: _phoneController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    fillColor: AppColors.containerColor,
                    border: OutlineInputBorder(),
                    hintText: '+998XXXXXXXXX',
                    contentPadding: EdgeInsets.all(14),
                  ),
                  onChanged: (value) {
                    _validatePhone(value);
                    if (_errorText == null) {
                      provider.setPhoneNumber(value);
                    }
                  },
                ),
              ),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Call Settings
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: AppColors.containerColor,
              shape: SmoothRectangleBorder(
                smoothness: 1,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.call_settings,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: Constants.Arial,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Allow Calls Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.allow_calls,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CupertinoSwitch(
                          value: provider.allowCalls,
                          onChanged: (value) => provider.setAllowCalls(value),
                        ),
                      ],
                    ),

                    // Call Time Settings
                    if (provider.allowCalls) ...[
                      const Divider(
                        color: AppColors.lightGray,
                      ),
                      Text(
                        AppLocalizations.of(context)!.preferred_call_time,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(AppColors.white),
                              ),
                              onPressed: () => _selectTime(context, true),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  '${AppLocalizations.of(context)!.from} ${_startTime?.format(context) ?? AppLocalizations.of(context)!.select}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(AppColors.white),
                              ),
                              onPressed: () => _selectTime(context, false),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  '${AppLocalizations.of(context)!.to}: ${_endTime?.format(context) ?? AppLocalizations.of(context)!.select}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom Material Time Picker
Future<TimeOfDay?> showThemedTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.white,
            hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
            dayPeriodBorderSide:
                const BorderSide(color: Colors.black, width: 1),
            dayPeriodShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Button text color
            ),
          ),
          colorScheme: const ColorScheme.light(
            primary: Colors.black, // Selected time color
            onPrimary: Colors.white, // Selected time text color
            onSurface: Colors.black, // Dial text color
            surface: Colors.white, // Dial background color
          ),
        ),
        child: child!,
      );
    },
  );
}

// Custom Cupertino Time Picker Bottom Sheet
Future<TimeOfDay?> showCupertinoTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  TimeOfDay? selectedTime = initialTime;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          children: [
            Container(
              height: 6,
              width: 50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child:  Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child:  Text(
                    AppLocalizations.of(context)!.confirm,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.pop(context, selectedTime),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  2024,
                  1,
                  1,
                  initialTime.hour,
                  initialTime.minute,
                ),
                onDateTimeChanged: (DateTime newDateTime) {
                  selectedTime = TimeOfDay(
                    hour: newDateTime.hour,
                    minute: newDateTime.minute,
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  return selectedTime;
}
