# GUT (Godot Unit Test) Installation

## Quick Install

1. Open Godot Editor
2. Go to **AssetLib** tab (top center)
3. Search for "GUT"
4. Click **Download** on "Gut - Godot Unit Testing"
5. Click **Install**
6. Go to **Project → Project Settings → Plugins**
7. Enable "Gut" plugin

## Alternative: Manual Install

1. Download from: https://github.com/bitwes/Gut/releases
2. Extract to `addons/gut/` folder
3. Enable plugin in Project Settings

## Verify Installation

After installation, you should be able to:
- Run tests from the GUT panel (bottom dock)
- Run tests via command line:
  ```bash
  godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
  ```

## Documentation

- GitHub: https://github.com/bitwes/Gut
- Wiki: https://gut.readthedocs.io/
