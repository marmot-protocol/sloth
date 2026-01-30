# Slate Content Transitions Design

## Overview

Control blur/fade content transitions for WnSlate screens, preserving the Hero container morph animation while adding proper content transitions inside the slate.

## Design Decisions

- **All WnSlate screens** get content transitions automatically (encapsulated)
- **Route's animation** drives the transition (via `ModalRoute.of(context)`)
- **WnSlateContentTransition** becomes animation-driven (receives external animation, no internal controller)
- **Route-level transition removed** - WnSlate handles it internally
- **secondaryAnimation** out of scope for now - revisit if needed

## Animation Behavior

### Scenario A: Small slate → Full slate (e.g., ChatList → Settings)
- Hero: Empty container morphs from small/top to large/full
- Content: Destination content fades in (0%→100% opacity, 4px→0px blur) simultaneously
- Both driven by the same route animation (250ms, easeInOutCubicEmphasized)

### Scenario B: Full slate → Full slate (e.g., Settings → Edit Profile)
- Hero: Container morphs (may be minimal if sizes match)
- Content: Incoming content fades in
- Uses `animation` for incoming

### Scenario C: Full slate → Small slate (e.g., Settings → ChatList via back)
- Hero: Container morphs from large to small
- Content: Outgoing content fades out during morph
- Uses reverse of `animation` (since we're popping)

## Spec Reference

- Duration: 250ms
- Curve: easeInOutCubicEmphasized (flipped for reverse)
- Open: Opacity 0%→100%, Blur 4px→0px
- Close: Opacity 100%→0%, Blur 0px→4px

## Files to Modify

### 1. `lib/widgets/wn_slate_content_transition.dart`

**Changes:**
- Remove `StatefulWidget`, `AnimationController`, `SingleTickerProviderStateMixin`
- Accept `Animation<double> animation` parameter
- Apply curve internally, build blur/fade from animation value

**New API:**
```dart
WnSlateContentTransition({
  required Widget child,
  required Animation<double> animation,
})
```

### 2. `lib/widgets/wn_slate.dart`

**Changes:**
- Look up `ModalRoute.of(context)?.animation`
- Wrap content with `WnSlateContentTransition`
- Add `animateContent` parameter (default true) as escape hatch

**Implementation:**
```dart
final route = ModalRoute.of(context);
final animation = route?.animation ?? kAlwaysCompleteAnimation;

// Wrap content area with transition
WnSlateContentTransition(
  animation: animation,
  child: Stack(...),
)
```

### 3. `lib/routes.dart`

**Changes:**
- Simplify `_navigationTransition` to return child directly
- Keep duration for Hero timing

**New implementation:**
```dart
static CustomTransitionPage<void> _navigationTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: WnSlateContentTransition.duration,
    reverseTransitionDuration: WnSlateContentTransition.duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}
```

### 4. Tests

- Update `wn_slate_content_transition_test.dart` for new API
- Add tests for WnSlate content transition behavior
- Verify existing WnSlate tests still pass

## Out of Scope

- `secondaryAnimation` handling for outgoing screens (revisit if testing reveals issues)
