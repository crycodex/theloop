import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../validators/auth_validators.dart';
import 'auth_form_widgets.dart';
import 'selection_card.dart';

class GoalGrid extends StatelessWidget {
  const GoalGrid({
    super.key,
    required this.selectedIndex,
    required this.customGoalController,
    required this.onSelected,
  });

  final int selectedIndex;
  final TextEditingController customGoalController;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final goals = [
      (strings.goalBigTech, strings.goalBigTechDetail),
      (strings.goalConsulting, strings.goalConsultingDetail),
      (strings.goalBanking, strings.goalBankingDetail),
      (strings.goalStartup, strings.goalStartupDetail),
      (strings.goalProductManager, strings.goalProductManagerDetail),
      ('+ ${strings.goalCustom}', strings.goalCustomDetail),
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.18,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final selected = selectedIndex == index;
            return SelectionCard(
              selected: selected,
              onTap: () => onSelected(index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    goals[index].$1,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? Colors.white : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    goals[index].$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.82)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: selectedIndex == 5
              ? Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: AuthField(
                    label: strings.customGoalLabel,
                    hint: strings.customGoalHint,
                    controller: customGoalController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    validator: (value) =>
                        AuthValidators.required(value, strings),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
