
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';

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
  final Function(TimeOfDay) onTimeChanged;

  const CustomTimePicker({
    super.key,
    required this.controller,
    required this.initialTime,
    required this.onTimeChanged,
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
    
    _hourController = FixedExtentScrollController(
      initialItem: widget.controller.selectedHour - 1
    );
    _minuteController = FixedExtentScrollController(
      initialItem: widget.controller.selectedMinute
    );
    _periodController = FixedExtentScrollController(
      initialItem: widget.controller.isAM ? 0 : 1
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _notifyTimeChanged() {
    widget.onTimeChanged(widget.controller.getSelectedTime());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                  _notifyTimeChanged();
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
              color: AppColors.black,
            ),
          ),
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
                  _notifyTimeChanged();
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
                  _notifyTimeChanged();
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
          color: isSelected ? AppColors.black : AppColors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
//