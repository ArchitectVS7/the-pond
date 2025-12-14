# Steam Store Setup

This is the critical path. Without a Steam App ID, you can't properly test Steam features like achievements, cloud saves, or the overlay. The $100 fee and app creation takes 30 minutes. Review can take days. Start now.

---

## Prerequisites

Before you begin, have ready:
- $100 USD (Steam Direct fee, non-refundable)
- Tax information (W-9 for US, W-8BEN for international)
- Bank account for payment (or PayPal in some regions)
- A game name (can be changed later, but pick something)
- A brief description (paragraph is fine)

---

## Step 1: Create Steamworks Account

**Time**: 15-30 minutes

1. Go to https://partner.steamgames.com/
2. Click "Join Steam" if you don't have a Steam account
3. Click "Become a Steamworks Partner"
4. Fill out the partner application:
   - Company name (can be your personal name for solo devs)
   - Tax information
   - Payment details
5. Pay the $100 Steam Direct fee per app
6. Wait for approval (usually instant, sometimes 1-2 business days)

**Note**: The $100 is recoupable after your game earns $1,000 in revenue. It's not a pure fee - it's an advance against royalties.

---

## Step 2: Create Your App

**Time**: 10-15 minutes

1. Log into Steamworks partner site
2. Click "Create New App"
3. Choose "Game"
4. Enter your game name: "The Pond" (or your title)
5. Note your **App ID** - this is critical

**Your App ID** looks like a 6-7 digit number (e.g., `1234567`). Write this down. You'll use it everywhere.

The default test App ID is `480` (Spacewar). Once you have your real ID, replace all instances of `480` in your code.

---

## Step 3: Configure Store Page

**Time**: 1-2 hours

### Required Information

| Field | What to Enter |
|-------|--------------|
| Game Name | The Pond |
| Developer | Your name/studio |
| Publisher | Your name/studio (can be same) |
| Release Date | Choose "Coming Soon" if not ready |
| Supported Platforms | Windows (add Mac/Linux if supported) |
| Genre | Action Roguelike, Indie |
| Tags | Roguelike, Bullet Hell, Environmental, Conspiracy |

### Required Assets

See [Art Asset Checklist](art-asset-checklist.md) for full specifications.

| Asset | Size | Purpose |
|-------|------|---------|
| Header Capsule | 460x215 | Store page header, search results |
| Small Capsule | 231x87 | Wishlist, recommendations |
| Main Capsule | 616x353 | Large store feature |
| Hero Image | 3840x1240 | Store page background |
| Screenshots | 1920x1080 | At least 5 required |
| Library Capsule | 600x900 | Steam library |

**Screenshot tip**: Capture actual gameplay. Steam requires that screenshots represent the actual game. Mockups or concept art in screenshots can get you rejected.

### Description

Write your store description. Key sections:

1. **Opening hook** (1-2 sentences): What makes this game unique?
2. **Core gameplay** (paragraph): What do players do?
3. **Features list** (bullet points): Key selling points
4. **About section**: More detail, story context

Example opening:
> You're a frog. The water is poisoned. Someone did this on purpose. In The Pond, you'll fight through waves of mutated creatures, build your conspiracy board of evidence, and expose the corporate villains destroying your home.

---

## Step 4: Install GodotSteam

**Time**: 30-60 minutes

GodotSteam is the plugin that lets Godot communicate with Steam.

### Download

1. Go to https://godotsteam.com/
2. Download the version matching your Godot version (4.2+)
3. There are two options:
   - **GDNative plugin**: Add to existing project (recommended)
   - **Pre-compiled editor**: Godot with Steam built in

### Install (GDNative method)

1. Extract the download
2. Copy the `addons/godotsteam` folder to your project's `addons/` folder
3. Copy `steam_api64.dll` (Windows) or equivalent to your project root
4. Create `steam_appid.txt` in your project root containing just your App ID:
   ```
   1234567
   ```

### Verify Installation

```gdscript
func _ready():
    var init_result = Steam.steamInit()
    print("Steam Init: ", init_result)

    if Steam.isSteamRunning():
        print("Steam is running")
        print("Steam ID: ", Steam.getSteamID())
    else:
        print("Steam not running - features will be simulated")
```

**Important**: Steam features only work when:
- Steam client is running
- Game is launched through Steam (or has steam_appid.txt)
- GodotSteam is properly installed

---

## Step 5: Configure Achievements

**Time**: 30-60 minutes

### In Steamworks Dashboard

1. Go to your app's page in Steamworks
2. Navigate to Stats & Achievements > Achievements
3. Click "Add Achievement"

For each achievement:
| Field | Example |
|-------|---------|
| API Name | `FIRST_KILL` (internal, no spaces) |
| Display Name | "First Blood" |
| Description | "Defeat your first enemy" |
| Icon (Unlocked) | 64x64 PNG |
| Icon (Locked) | 64x64 PNG (grayed version) |
| Hidden | Check if spoilery |

### In Code

```gdscript
# Unlock achievement
func unlock_achievement(achievement_name: String) -> void:
    if Steam.isSteamRunning():
        Steam.setAchievement(achievement_name)
        Steam.storeStats()
        print("Achievement unlocked: ", achievement_name)

# Check if already unlocked
func is_achievement_unlocked(achievement_name: String) -> bool:
    if Steam.isSteamRunning():
        return Steam.getAchievement(achievement_name)
    return false

# Usage
unlock_achievement("FIRST_KILL")
```

**Achievement tip**: Don't go overboard. 15-25 achievements is typical. Include:
- Early game ("First enemy", "Complete tutorial")
- Progression ("Defeat first boss", "Unlock all mutations")
- Skill-based ("No-hit boss", "Complete in under 30 minutes")
- Hidden/secret ("Find the secret area", "Discover the true ending")

---

## Step 6: Configure Steam Cloud

**Time**: 15-30 minutes

### In Steamworks Dashboard

1. Go to Application > Steam Cloud
2. Enable Steam Cloud
3. Set quota:
   - Bytes per user: 1048576 (1 MB is plenty for save files)
   - Files per user: 10

4. Add file patterns:
   ```
   savegame.json
   settings.json
   ```

### In Code

The save system already has Steam Cloud stubs in `core/scripts/steam_cloud.gd`. When GodotSteam is installed, implement:

```gdscript
# Write to Steam Cloud
func write_to_cloud(filename: String, data: String) -> bool:
    if not Steam.isSteamRunning():
        return false
    return Steam.fileWrite(filename, data.to_utf8_buffer())

# Read from Steam Cloud
func read_from_cloud(filename: String) -> String:
    if not Steam.isSteamRunning():
        return ""
    var size = Steam.getFileSize(filename)
    if size > 0:
        var content = Steam.fileRead(filename, size)
        return content.get_string_from_utf8()
    return ""

# Check if file exists in cloud
func cloud_file_exists(filename: String) -> bool:
    if not Steam.isSteamRunning():
        return false
    return Steam.fileExists(filename)
```

---

## Step 7: Build and Upload

**Time**: Variable

### Export from Godot

1. Project > Export
2. Add Windows Desktop preset (and Mac/Linux if supporting)
3. Configure:
   - Export path: `builds/windows/ThePond.exe`
   - Include `steam_api64.dll`
   - Include `steam_appid.txt` (for development)
4. Export

### Upload via SteamPipe

SteamPipe is Steam's content delivery system.

1. Download Steamworks SDK from Steamworks site
2. Navigate to `sdk/tools/ContentBuilder/`
3. Configure your `app_build.vdf`:
   ```
   "appbuild"
   {
       "appid" "1234567"
       "desc" "The Pond build"
       "buildoutput" "./output/"
       "contentroot" "../../builds/"
       "setlive" "default"
       "depots"
       {
           "1234568"
           {
               "FileMapping"
               {
                   "LocalPath" "windows/*"
                   "DepotPath" "."
                   "recursive" "1"
               }
           }
       }
   }
   ```

4. Run the build:
   ```bash
   ./steamcmd.sh +login your_username +run_app_build ../scripts/app_build.vdf +quit
   ```

5. Check Steamworks for successful upload

### Set Build Live

1. Go to Steamworks > Builds
2. Find your uploaded build
3. Click the dropdown under "Set build live"
4. Choose "default" branch

---

## Step 8: Submit for Review

**Time**: 5 minutes active, days waiting

1. Complete all required store page fields
2. Upload at least 5 screenshots
3. Set content ratings via IARC questionnaire
4. Click "Submit for Review"

**Review timeline**: Usually 2-5 business days. Can be longer during busy periods (summer sales, holiday season).

**Common rejection reasons**:
- Missing or inadequate screenshots
- Incomplete store description
- Content rating not set
- Build doesn't launch

---

## Quick Reference

### Key Steamworks URLs

| Purpose | URL |
|---------|-----|
| Partner Dashboard | https://partner.steamgames.com/ |
| Documentation | https://partner.steamgames.com/doc/home |
| GodotSteam Docs | https://godotsteam.com/docs/ |
| Steamworks SDK | https://partner.steamgames.com/downloads |

### Your App Details (fill in when you have them)

| Detail | Value |
|--------|-------|
| App ID | _______ |
| Depot ID | _______ |
| Store Page | https://store.steampowered.com/app/_______ |

---

## Troubleshooting

### "Steam not running" in-game

- Ensure Steam client is open
- Ensure `steam_appid.txt` exists with correct ID
- Try running game from Steam library instead of editor

### Achievements not unlocking

- Check API name matches exactly (case-sensitive)
- Ensure you called `Steam.storeStats()` after setting
- Check Steamworks achievement is published

### Build upload fails

- Verify Depot ID matches your app
- Check file paths in VDF
- Ensure Steam credentials are correct
- Try logging in via browser first

---

## Status Checklist

| Step | Status | Notes |
|------|--------|-------|
| Steamworks account | Not Started | - |
| App created | Not Started | - |
| App ID noted | Not Started | ID: _______ |
| Store page configured | Not Started | - |
| GodotSteam installed | Not Started | - |
| Achievements set up | Not Started | - |
| Steam Cloud configured | Not Started | - |
| First build uploaded | Not Started | - |
| Review submitted | Not Started | - |
| Review approved | Not Started | - |

---

[Back to Human Steps Overview](overview.md) | [Previous: Audio Assets](audio-asset-checklist.md) | [Next: Hardware Testing](hardware-testing.md)
