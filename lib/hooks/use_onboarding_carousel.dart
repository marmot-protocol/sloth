import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const _slideCount = 3;
const _defaultAutoAdvanceInterval = Duration(seconds: 5);
const _virtualPageCount = 1000;
const _initialPage = (_virtualPageCount ~/ 2) - ((_virtualPageCount ~/ 2) % _slideCount);

({
  PageController pageController,
  int currentIndex,
  void Function(int) onPageChanged,
  void Function(int) goToPage,
})
useOnboardingCarousel({
  Duration autoAdvanceInterval = _defaultAutoAdvanceInterval,
}) {
  final pageController = usePageController(
    initialPage: _initialPage,
  );

  final currentIndex = useState(0);

  final autoAdvanceTimer = useRef<Timer?>(null);

  void startAutoAdvance() {
    autoAdvanceTimer.value?.cancel();
    autoAdvanceTimer.value = Timer.periodic(autoAdvanceInterval, (_) {
      if (pageController.hasClients) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void stopAutoAdvance() {
    autoAdvanceTimer.value?.cancel();
    autoAdvanceTimer.value = null;
  }

  useEffect(() {
    startAutoAdvance();
    return stopAutoAdvance;
  }, const []);

  void onPageChanged(int page) {
    currentIndex.value = page % _slideCount;
    startAutoAdvance();
  }

  void goToPage(int index) {
    if (!pageController.hasClients) return;

    final currentPage = pageController.page?.round() ?? 0;
    final currentModIndex = currentPage % _slideCount;
    final delta = index - currentModIndex;
    final targetPage = currentPage + delta;

    pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  return (
    pageController: pageController,
    currentIndex: currentIndex.value,
    onPageChanged: onPageChanged,
    goToPage: goToPage,
  );
}

int get onboardingCarouselSlideCount => _slideCount;
