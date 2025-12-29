# Taskito

Taskito is a tiny MacOS utility app that helps combat procrastination and finish your tasks.

It's a focus timer that is simple, fast, poses no disruptions, and exists on the Mac's menu bar for quick access.

## Features

- **Tiny Menu Bar Application** - Lives in your menu bar, always accessible but never in the way
- **No Distractions** - No Dock icon, no fancy animations, no ads. Just a timer when you need it
- **Use It Your Way** - No forced Pomodoro technique or rigid workflows. Set any duration you want
- **Full Keyboard Support** - Comprehensive keyboard shortcuts for power users who hate reaching for the mouse
- **Global Shortcut** - Open Taskito from anywhere with a customizable system-wide keyboard shortcut
- **Preset Timers** - Save up to 5 frequently-used timer durations for one-click access
- **Privacy First** - All data stays on your Mac. No analytics, no tracking, no cloud sync

## Installation

The app is unsigned, so macOS requires these steps:

1. Download the DMG build artifact from the **latest release** at [the releases page](https://github.com/libekonst/Taskito/releases)
2. **Mount the DMG** and drag Taskito to Applications
3. **Remove quarantine flag** - Open Terminal and run:

   ```bash
   xattr -cr /Applications/Taskito.app
   ```

4. **Launch the app** - You can now open it normally from Applications

**Note:** If you get "damaged and can't be opened", you skipped step 3. The app isn't actually damaged, it's just macOS blocking unsigned apps.

### Why the "damaged" Error?

**The app isn't actually damaged** - this is macOS Gatekeeper blocking unsigned apps.

macOS has three security levels:

1. **App Store apps** - No warnings
2. **Notarized apps** (signed + approved by Apple) - One-time approval dialog
3. **Unsigned apps** (this app) - Blocked with misleading "damaged" error

When you download files from the internet, macOS adds a "quarantine" flag. The `xattr -cr` command removes this flag, allowing the unsigned app to run.

The xattr -cr command:

- -c = Clear all extended attributes (including quarantine)
- -r = Recursive (entire app bundle)

## Building

### Local Build

#### Prerequisites

- Xcode 15.3+
- macOS 14.2+
- Node.js (for creating DMG installers)

1. **Build the app:**

   ```bash
   xcodebuild -project Taskito.xcodeproj \
     -scheme Taskito \
     -configuration Release \
     -derivedDataPath build \
     CODE_SIGN_IDENTITY="" \
     CODE_SIGNING_REQUIRED=NO \
     CODE_SIGNING_ALLOWED=NO
   ```

2. **Create a DMG installer:**

   ```bash
   # Install appdmg (first time only)
   npm install -g appdmg

   # Create the DMG
   mkdir -p dist
   appdmg appdmg.json dist/Taskito.dmg
   ```

3. **Verify the DMG (optional):**

   ```bash
   hdiutil verify dist/Taskito.dmg
   ```

The built app will be at `build/Build/Products/Release/Taskito.app` and the installer at `dist/Taskito.dmg`.

### GitHub Action Build

The repository includes a GitHub Action that automatically builds and creates a DMG. You can trigger it two ways:

**Option 1: Create a Release (Recommended)**

1. Go to the GitHub repository
2. Click "Releases" → "Create a new release"
3. Tag version (e.g., `v1.0.0`)
4. Click "Publish release"
5. The action will run automatically and upload `Taskito.dmg` to the release

**Option 2: Manual Trigger**

1. Go to "Actions" tab in the GitHub repository
2. Select "Build and Release macOS App" workflow
3. Click "Run workflow"
4. Once complete, download the DMG from the workflow run's "Artifacts" section

## Usage

### Starting a Timer

**From the Menu Bar:**
1. Click the Taskito icon in your menu bar
2. Enter minutes and seconds (or click a preset button)
3. Press Enter or click START

**With Global Shortcut:**
1. Press your configured global shortcut (default: unset, configure in Settings)
2. Opens Quick Timer window from anywhere
3. Enter duration and press Enter

### Managing Running Timers

- **Play/Pause** - Space bar or click the play/pause button
- **Add Time** - Press `+` for 1 minute, `Shift +` for 3 minutes
- **Restart** - `⌘R` to restart from original duration
- **Cancel** - `⌃C` or click the X button

### Preset Timers

Save frequently-used durations in Settings:
- Maximum 5 presets
- Access with `⌘1` through `⌘5`
- Click to start immediately

## Keyboard Shortcuts

### Global (System-Wide)
| Shortcut | Action |
|----------|--------|
| Custom (set in Settings) | Open Taskito Quick Timer window |

### Timer Setup
| Shortcut | Action |
|----------|--------|
| `⌘1` - `⌘5` | Start preset timer (if configured) |
| `Enter` | Start timer with current values |

### Active Timer
| Shortcut | Action |
|----------|--------|
| `Space` | Play/Pause timer |
| `+` | Add 1 minute |
| `Shift +` | Add 3 minutes |
| `⌘R` | Restart timer |
| `⌃C` | Cancel timer |

See the full shortcuts reference in the app's Settings window.

## Settings

Access settings by clicking the gear icon in the menu bar interface:

- **Start on system startup** - Launch Taskito automatically when you log in
- **Play sound when timer completes** - Audio notification when countdown reaches zero
- **Enable global shortcut** - Toggle system-wide keyboard shortcut on/off
- **Customize shortcut** - Set your preferred global keyboard combination
- **Preset timers** - Configure up to 5 quick-access timer durations

## Credits

Taskito uses [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by [Sindre Sorhus](https://github.com/sindresorhus) for global keyboard shortcut registration.

## Testing

This project includes comprehensive unit and integration tests. See [TaskitoTests/TESTING_SUMMARY.md](TaskitoTests/TESTING_SUMMARY.md) for details on the testing strategy and implementation.

## Roadmap

<https://github.com/users/libekonst/projects/2/views/1>
