import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isVirtual = false;
  bool _isFree = true;
  double _maxAttendees = 100;
  String? _selectedCategory;
  static const _categories = <String>[
    'Meetup',
    'Workshop',
    'Conference',
    'Webinar',
    'Party',
  ];
  DateTime? _startAt;
  DateTime? _endAt;
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _locationController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _pickedBanner;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startAt : _endAt) ?? now;
    final first = now.subtract(const Duration(days: 1));
    final last = now.add(const Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: const Color(0xFF121214),
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  surface: const Color(0xFF121214),
                  onSurface: Colors.white,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: const Color(0xFF121214),
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  surface: const Color(0xFF121214),
                  onSurface: Colors.white,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final localizations = MaterialLocalizations.of(context);
    final dateStr = localizations.formatMediumDate(combined);
    final timeStr = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(combined),
      alwaysUse24HourFormat: false,
    );

    setState(() {
      if (isStart) {
        _startAt = combined;
        _startController.text = '$dateStr · $timeStr';
      } else {
        _endAt = combined;
        _endController.text = '$dateStr · $timeStr';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    final isCompact = Responsive.isCompact(context);
    const darkBg = Color(0xFF121214);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: darkBg,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    pad,
                    Responsive.spacing(context, 10),
                    pad,
                    Responsive.spacing(context, 10),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        iconSize: Responsive.iconSize(context, 18),
                        icon: const FaIcon(
                          FontAwesomeIcons.xmark,
                          color: Colors.white,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      SizedBox(width: Responsive.spacing(context, 4)),
                      Text(
                        'Create event',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  Responsive.fontSize(context, isCompact ? 16 : 18),
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        pad,
                        0,
                        pad,
                        Responsive.spacing(context, 24),
                      ),
                      children: [
                        Text(
                          'Event banner',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 8)),
                        GestureDetector(
                          onTap: () async {
                            final file = await _imagePicker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (file != null) {
                              setState(() {
                                _pickedBanner = file;
                              });
                            }
                          },
                          child: Container(
                            height: Responsive.value(context, 170),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                  Responsive.value(context, 18)),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.35),
                              ),
                              image: _pickedBanner != null
                                  ? DecorationImage(
                                      image: NetworkImage(_pickedBanner!.path),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _pickedBanner == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.image,
                                        size: Responsive.iconSize(
                                            context, isCompact ? 26 : 32),
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(
                                          height:
                                              Responsive.spacing(context, 8)),
                                      Text(
                                        'Tap to upload or paste URL',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white60),
                                      ),
                                    ],
                                  )
                                : Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          Responsive.spacing(context, 8)),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Responsive.value(context, 8),
                                          vertical:
                                              Responsive.value(context, 4),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          'Change image',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 20)),
                        TextFormField(
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Responsive.value(context, 14)),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.7,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Responsive.value(context, 14)),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.7,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Responsive.value(context, 14)),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.6),
                                width: 0.9,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                        SizedBox(height: Responsive.spacing(context, 14)),
                        TextFormField(
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Responsive.value(context, 14)),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.7,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Responsive.value(context, 14)),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.7,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Responsive.value(context, 14)),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.6),
                                width: 0.9,
                              ),
                            ),
                          ),
                          maxLines: 4,
                        ),
                        SizedBox(height: Responsive.spacing(context, 14)),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _startController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  labelText: 'Start date & time',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                  suffixIcon: const Icon(
                                    FontAwesomeIcons.calendarDays,
                                    size: 18,
                                    color: Colors.white70,
                                  ),
                                  filled: false,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Responsive.value(context, 14)),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 0.7,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Responsive.value(context, 14)),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 0.7,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Responsive.value(context, 14)),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.6),
                                      width: 0.9,
                                    ),
                                  ),
                                ),
                                readOnly: true,
                                onTap: () => _pickDateTime(isStart: true),
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 10)),
                            Expanded(
                              child: TextFormField(
                                controller: _endController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  labelText: 'End date & time',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                  suffixIcon: const Icon(
                                    FontAwesomeIcons.calendarDays,
                                    size: 18,
                                    color: Colors.white70,
                                  ),
                                  filled: false,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Responsive.value(context, 14)),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 0.7,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Responsive.value(context, 14)),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 0.7,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Responsive.value(context, 14)),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.6),
                                      width: 0.9,
                                    ),
                                  ),
                                ),
                                readOnly: true,
                                onTap: () => _pickDateTime(isStart: false),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.spacing(context, 14)),
                        Row(
                          children: [
                            Expanded(
                              child: _SmallToggleChip(
                                label: 'Virtual',
                                value: _isVirtual,
                                onChanged: (v) =>
                                    setState(() => _isVirtual = v),
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 10)),
                            Expanded(
                              child: _SmallToggleChip(
                                label: 'Free event',
                                value: _isFree,
                                onChanged: (v) =>
                                    setState(() => _isFree = v),
                              ),
                            ),
                          ],
                        ),
                        if (!_isVirtual) ...[
                          SizedBox(height: Responsive.spacing(context, 6)),
                          TextFormField(
                            controller: _locationController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Location',
                              hintText: 'Search Google Maps',
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                              suffixIcon: const Icon(
                                FontAwesomeIcons.locationDot,
                                size: 18,
                                color: Colors.white70,
                              ),
                              filled: false,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Responsive.value(context, 14)),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 0.7,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Responsive.value(context, 14)),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 0.7,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Responsive.value(context, 14)),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 0.9,
                                ),
                              ),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final result =
                                  await context.push<Map<String, dynamic>>(
                                '/pick-location',
                              );
                              if (result != null) {
                                setState(() {
                                  final address = result['address'] as String?;
                                  _locationController.text =
                                      address ?? 'Custom location selected';
                                });
                              }
                            },
                          ),
                        ],
                        SizedBox(height: Responsive.spacing(context, 14)),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _categories
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                          dropdownColor: const Color(0xFF121214),
                          iconEnabledColor: Colors.white70,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Responsive.value(context, 14)),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.7,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Responsive.value(context, 14)),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.7,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Responsive.value(context, 14)),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.6),
                                width: 0.9,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Max attendees',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              _maxAttendees >= 1000
                                  ? 'No limit'
                                  : '${_maxAttendees.round()} people',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.spacing(context, 4)),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                              pressedElevation: 0,
                            ),
                            overlayShape:
                                const RoundSliderOverlayShape(overlayRadius: 12),
                            valueIndicatorTextStyle: const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          child: Slider(
                            value: _maxAttendees,
                            min: 10,
                            max: 1000,
                            divisions: 99,
                            label: _maxAttendees >= 1000
                                ? 'No limit'
                                : _maxAttendees.round().toString(),
                            onChanged: (v) => setState(() => _maxAttendees = v),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 2)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '10',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white, fontSize: 11),
                            ),
                            Text(
                              '100',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white, fontSize: 11),
                            ),
                            Text(
                              '500',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white, fontSize: 11),
                            ),
                            Text(
                              '1000+',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.spacing(context, 8)),
                        SizedBox(height: Responsive.spacing(context, 24)),
                        FilledButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              context.pop();
                            }
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Create event'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallToggleChip extends StatelessWidget {
  const _SmallToggleChip({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final radius = Responsive.value(context, compact ? 18 : 20);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.value(context, compact ? 12 : 16),
            vertical: Responsive.value(context, compact ? 6 : 8),
          ),
          decoration: BoxDecoration(
            color: value
                ? AppColors.primaryDark
                : AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: value
                  ? AppColors.primaryDark
                  : AppColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize:
                      Responsive.fontSize(context, compact ? 12 : 13),
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  color: value ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
