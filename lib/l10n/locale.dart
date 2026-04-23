import 'package:flutter/material.dart';

enum AppLocale { en, fr, nl }

final localeNotifier = ValueNotifier<AppLocale>(AppLocale.fr);

class LangSwitcher extends StatelessWidget {
  const LangSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: localeNotifier,
      builder: (_, current, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: AppLocale.values.map((locale) {
          final isActive = locale == current;
          return GestureDetector(
            onTap: () => localeNotifier.value = locale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFFF2800) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_flag(locale),
                  style: TextStyle(fontSize: isActive ? 14 : 12)),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _flag(AppLocale l) {
    switch (l) {
      case AppLocale.en: return '🇬🇧';
      case AppLocale.fr: return '🇫🇷';
      case AppLocale.nl: return '🇳🇱';
    }
  }
}
