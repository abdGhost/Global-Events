import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/event.dart';
import '../../../providers/search_events_provider.dart';
import '../../home/presentation/widgets/event_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always load all events from backend search, then filter in-memory
    // by what the user types.
    final AsyncValue<List<EventListItem>> results =
        ref.watch(searchEventsProvider(const SearchParams()));

    return Scaffold(
      body: Stack(
        children: [
          // Match Home screen gradient background.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.06),
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.2, 1.0],
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.horizontalPadding(context),
                    Responsive.spacing(context, 10),
                    Responsive.horizontalPadding(context),
                    Responsive.spacing(context, 10),
                  ),
                  child: _SearchInput(
                    controller: _controller,
                    query: _query,
                    onChanged: (v) => setState(() => _query = v),
                    onSubmitted: (v) => setState(() => _query = v),
                    onClear: () => setState(() {
                      _controller.clear();
                      _query = '';
                    }),
                  ),
                ),
              ),
              Expanded(
                child: results.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.horizontalPadding(context),
                      ),
                      child: Text(
                        'Something went wrong while loading events.\n$e',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ),
                  ),
                  data: (allEvents) {
                    final q = _query.trim().toLowerCase();
                    final filtered = q.isEmpty
                        ? allEvents
                        : allEvents.where((e) {
                            final title = e.title.toLowerCase();
                            final category = e.category?.toLowerCase() ?? '';
                            final city = e.city?.toLowerCase() ?? '';
                            return title.contains(q) ||
                                category.contains(q) ||
                                city.contains(q);
                          }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.magnifyingGlassChart,
                              size: Responsive.iconSize(context, 64),
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(
                                height: Responsive.spacing(context, 16)),
                            Text(
                              q.isEmpty
                                  ? 'No events available'
                                  : 'No events found',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(
                          Responsive.horizontalPadding(context)),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => Padding(
                        padding: EdgeInsets.only(
                            bottom: Responsive.spacing(context, 12)),
                        child: EventCard(event: filtered[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final radius = Responsive.value(context, 22);
    final chipBg = AppColors.primary.withValues(alpha: 0.10);
    final chipBorder = AppColors.primary.withValues(alpha: 0.25);
    final chipText = AppColors.primaryDark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: Responsive.searchBarHeight(context),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: chipBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              SizedBox(
                width: Responsive.value(context, 40),
                child: Center(
                  child: Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: Responsive.iconSize(context, 18),
                    color: chipText,
                  ),
                ),
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      filled: true,
                      fillColor: Colors.transparent,
                      hintStyle: TextStyle(
                        color: chipText.withValues(alpha: 0.7),
                        fontSize: Responsive.fontSize(context, compact ? 14 : 15),
                      ),
                    ),
                    style: TextStyle(
                      color: chipText,
                      fontSize: Responsive.fontSize(context, compact ? 14 : 15),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                  ),
                ),
              ),
              if (query.isNotEmpty)
                IconButton(
                  icon: Icon(FontAwesomeIcons.xmark, size: Responsive.iconSize(context, 14), color: chipText),
                  onPressed: onClear,
                )
              else
                SizedBox(width: Responsive.value(context, 8)),
            ],
          ),
        ),
      ),
    );
  }
}
