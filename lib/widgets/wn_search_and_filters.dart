import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/widgets/wn_filter_chip.dart';
import 'package:whitenoise/widgets/wn_search_field.dart';

enum ChatFilter { chats, archive }

class WnSearchAndFilters extends HookWidget {
  const WnSearchAndFilters({
    super.key,
    this.onSearchChanged,
    this.onFilterChanged,
  });

  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<ChatFilter>? onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedFilter = useState(ChatFilter.chats);
    final searchController = useTextEditingController();

    void handleFilterSelected(ChatFilter filter) {
      selectedFilter.value = filter;
      onFilterChanged?.call(filter);
    }

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        key: const Key('search_and_filters'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WnSearchField(
            placeholder: l10n.search,
            controller: searchController,
            onChanged: onSearchChanged,
          ),
          SizedBox(height: 8.h),
          Row(
            key: const Key('filter_chips_row'),
            children: [
              WnFilterChip(
                key: const Key('filter_chip_chats'),
                label: l10n.filterChats,
                selected: selectedFilter.value == ChatFilter.chats,
                onSelected: (_) => handleFilterSelected(ChatFilter.chats),
              ),
              SizedBox(width: 6.w),
              WnFilterChip(
                key: const Key('filter_chip_archive'),
                label: l10n.filterArchive,
                selected: selectedFilter.value == ChatFilter.archive,
                onSelected: (_) => handleFilterSelected(ChatFilter.archive),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
