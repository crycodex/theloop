import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/loop_colors.dart';
import 'selection_card.dart';

class ExperienceOptions extends StatelessWidget {
  const ExperienceOptions({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final options = [
      (strings.experienceNone, strings.experienceNoneDetail),
      (strings.experienceSome, strings.experienceSomeDetail),
      (strings.experienceAdvanced, strings.experienceAdvancedDetail),
    ];

    return Column(
      children: List.generate(options.length, (index) {
        final selected = selectedIndex == index;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == options.length - 1 ? 0 : 12,
          ),
          child: SelectionCard(
            selected: selected,
            onTap: () => onSelected(index),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white
                        : LoopColors.onboardingGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: LoopColors.onboardingGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        options[index].$1,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? Colors.white : null,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        options[index].$2,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.82)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
