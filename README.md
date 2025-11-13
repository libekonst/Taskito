# Taskito

Taskito is a tiny MacOS utility app that helps combat procrastination and finish your tasks.

It's a focus timer that is simple, fast, poses no disruptions, and exists on the Mac's menu bar for quick access.

## Building

### Prerequisites

- Xcode 15.3+
- macOS 14.2+
- Node.js (for creating DMG installers)

### Local Build

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

## Installation

The app is unsigned, so macOS requires these steps:

1. **Mount the DMG** and drag Taskito to Applications
2. **Remove quarantine flag** - Open Terminal and run:

   ```bash
   xattr -cr /Applications/Taskito.app
   ```

3. **Launch the app** - You can now open it normally from Applications

**Note:** If you get "damaged and can't be opened", you skipped step 2. The app isn't actually damaged - it's just macOS blocking unsigned apps.

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

### Roadmap

<https://github.com/users/libekonst/projects/2/views/1>
