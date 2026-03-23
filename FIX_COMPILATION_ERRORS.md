# 🔧 Compilation Errors Fix Guide

## Issues Found

### 1. Person Model Property Name Mismatch
**Problem:** Code uses `.dob` but model has `.dateOfBirth`

**Files to Fix:**
- `lib/features/persons/presentation/screens/person_list_screen.dart`
- `lib/features/persons/presentation/screens/person_details_screen.dart`
- `lib/features/persons/presentation/screens/search_screen.dart`
- `lib/features/persons/presentation/screens/edit_person_screen.dart`

**Solution:** Replace all `.dob` with `.dateOfBirth`

---

### 2. Theme API Changes (Flutter 3.x)
**Problem:** `CardTheme` should be `CardThemeData`, `elevation` parameter removed

**Files to Fix:**
- `lib/core/theme/light_theme.dart`
- `lib/core/theme/dark_theme.dart`
- `lib/core/theme/app_theme.dart`

**Solution:** 
- Use `CardThemeData` instead of `CardTheme`
- Remove `elevation` parameter from `FloatingActionButtonTheme`

---

### 3. Import Path Issues
**Problem:** Incorrect relative imports throughout the project

**Solution:** All imports need to use correct relative paths from the feature directory structure

---

## Quick Fix Commands

Run these commands in PowerShell to fix automatically:

```powershell
# Fix 1: Replace .dob with .dateOfBirth
(Get-Content lib/features/persons/presentation/screens/person_list_screen.dart) -replace '\.dob', '.dateOfBirth' | Set-Content lib/features/persons/presentation/screens/person_list_screen.dart

(Get-Content lib/features/persons/presentation/screens/person_details_screen.dart) -replace '\.dob', '.dateOfBirth' | Set-Content lib/features/persons/presentation/screens/person_details_screen.dart

(Get-Content lib/features/persons/presentation/screens/search_screen.dart) -replace '\.dob', '.dateOfBirth' | Set-Content lib/features/persons/presentation/screens/search_screen.dart

(Get-Content lib/features/persons/presentation/screens/edit_person_screen.dart) -replace '\.dob', '.dateOfBirth' | Set-Content lib/features/persons/presentation/screens/edit_person_screen.dart

# Fix 2: Theme fixes will be done manually
```

---

## Manual Fixes Required

### Theme Files

**lib/core/theme/light_theme.dart:**
```dart
// Change line 19:
cardTheme: CardTheme(  // ❌
cardTheme: CardThemeData(  // ✅

// Remove elevation from FloatingActionButtonTheme (line 32)
FloatingActionButtonTheme(
  elevation: 4,  // ❌ Remove this line
  ...
)
```

**lib/core/theme/dark_theme.dart:**
```dart
// Same changes as light_theme.dart
cardTheme: CardThemeData(  // ✅
// Remove elevation from FAB theme
```

**lib/core/theme/app_theme.dart:**
```dart
// The issue is that lightTheme and darkTheme are not exported
// Add exports to theme.dart or import directly
import 'light_theme.dart';
import 'dark_theme.dart';
```

---

## Verification Steps

After fixes:
```bash
flutter clean
flutter pub get
flutter run
```

Should compile without errors.
