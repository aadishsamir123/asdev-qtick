# Testing the Update System in Debug Environment

## Quick Testing Setup

### 1. **Enable Debug Mode**

In `lib/services/update_service.dart`, set:

```dart
static const bool debugForceUpdate = true; // Set to true for testing
```

When `debugForceUpdate = true`, the app will show the update dialog every time it launches, regardless of actual update availability.

### 2. **Access Debug Screen**

Add this to any screen where you want to test (like in your admin panel or settings):

```dart
// Add this import
import 'screens/debug_update_screen.dart';

// Add this button somewhere in your UI
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DebugUpdateScreen()),
    );
  },
  child: const Text('Debug Updates'),
)
```

### 3. **Test Scenarios**

#### **Scenario 1: Force Update Dialog on Launch**

1. Set `debugForceUpdate = true`
2. Hot restart the app
3. Wait 2.5 seconds after loading screen
4. Update dialog should appear automatically

#### **Scenario 2: Manual Testing**

1. Navigate to Debug Update Screen
2. Test individual dialogs:
   - Update Available Dialog
   - Progress Dialog
   - Restart Dialog
   - Play Store Fallback

#### **Scenario 3: Real Update Testing**

For testing actual Play Store updates:

1. **Prepare versions:**

   ```yaml
   # In pubspec.yaml, start with lower version
   version: 1.5.0+1
   ```

2. **Build and upload to Play Store:**

   ```bash
   flutter build appbundle
   ```

   Upload to Play Store Internal Testing

3. **Create newer version:**

   ```yaml
   # Update pubspec.yaml
   version: 1.5.1+2
   ```

4. **Install older version on test device**
5. **Launch app and test update flow**

### 4. **Debug Console Output**

When testing, watch the debug console for messages like:

```
DEBUG: Forcing update dialog for testing
Error checking for updates: ...
```

### 5. **Reset Testing State**

To reset the "don't show again" state:

```dart
// Call this in debug to reset update prompts
await Upgrader.clearSavedSettings();
```

## Production Setup

### **Before Release:**

1. Set `debugForceUpdate = false`
2. Remove debug navigation to DebugUpdateScreen
3. Test with actual Play Store versions

### **Recommended Testing Flow:**

1. ✅ Debug mode testing (UI components)
2. ✅ Internal testing track (real updates)
3. ✅ Staged rollout (production-like)
4. ✅ Full release

## Common Issues & Solutions

### **Issue: Update dialog not showing**

- Check `debugForceUpdate` is `true`
- Verify network connection
- Check debug console for errors

### **Issue: In-app update fails**

- Normal behavior - will fallback to Play Store
- Only works with signed releases from Play Store
- Debug builds may not support in-app updates

### **Issue: "Later" button dismisses forever**

- This is expected behavior (once per day)
- Use `Upgrader.clearSavedSettings()` to reset

## Testing Checklist

- [ ] Debug mode shows dialog on launch
- [ ] Update dialog appears correctly
- [ ] "Later" button works
- [ ] "Update" button triggers progress
- [ ] Progress dialog shows correctly
- [ ] Restart dialog appears after update
- [ ] Play Store fallback works
- [ ] No crashes or exceptions
- [ ] Works on both debug and release builds
