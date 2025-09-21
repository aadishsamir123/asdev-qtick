# App Update System Documentation

## Overview

This QR Attendance app includes an automatic update system that combines two packages:

- `upgrader`: For checking app updates on the Play Store
- `in_app_update`: For performing seamless in-app updates (Android only)

## How it Works

### 1. Update Check on App Launch

When the app launches, it automatically checks for updates in the background:

- The check happens 2.5 seconds after the app loads (after the loading screen)
- Updates are checked once per day to avoid being too intrusive

### 2. Update Flow

1. **Update Detection**: The `upgrader` package checks the Play Store for new versions
2. **Custom Dialog**: If an update is available, a custom dialog appears asking the user to update
3. **In-App Update**: When the user presses "Update", the app attempts an in-app update:
   - **Immediate Update**: Full-screen update that blocks the app until complete
   - **Flexible Update**: Background download with app restart prompt
   - **Fallback**: If in-app update fails, opens the Play Store

### 3. Platform Support

- **Android**: Full support with in-app updates
- **iOS**: Falls back to standard upgrade dialog (opens App Store)

## Key Features

### Graceful Fallbacks

- If in-app update fails → Opens Play Store
- If update check fails → Shows standard upgrader dialog
- If no internet → No disruption to app functionality

### User Experience

- Non-intrusive: Only checks once per day
- Quick: In-app updates are faster than Play Store navigation
- Reliable: Multiple fallback mechanisms ensure users can always update

### Error Handling

- All async operations include proper error handling
- BuildContext usage is protected with mounted checks
- Debug logging helps with troubleshooting

## Testing

### Development Testing

1. **Version Bump**: Increase version in `pubspec.yaml`
2. **Play Store**: Upload new version to Play Store (internal testing track)
3. **Test Device**: Install older version and test update flow

### Test Scenarios

- [x] Update available with immediate update allowed
- [x] Update available with only flexible update allowed
- [x] Update available but in-app update not supported
- [x] No update available
- [x] Network error during update check
- [x] In-app update download failure

## Configuration

### Update Frequency

Current setting: Once per day

```dart
durationUntilAlertAgain: const Duration(days: 1)
```

### Debug Mode

Debug logging is enabled for troubleshooting:

```dart
debugLogging: true
```

## Files Modified

1. **pubspec.yaml** - Added dependencies:

   - `upgrader: ^10.3.0`
   - `in_app_update: ^4.2.3`

2. **lib/services/update_service.dart** - New service handling update logic

3. **lib/screens/loading_screen.dart** - Added update check after app launch

4. **lib/main.dart** - Wrapped app with update service

## Future Enhancements

- [ ] Custom update progress UI for flexible updates
- [ ] Update preferences in settings screen
- [ ] Update notifications for background updates
- [ ] Beta channel support for testing updates
