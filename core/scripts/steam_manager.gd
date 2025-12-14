## steam_manager.gd
## PLATFORM-001: GodotSteam Plugin Setup (STUB)
## PLATFORM-002: Steam Authentication (STUB)
## PLATFORM-004: Steam Overlay Support (STUB)
##
## Integration with GodotSteam pending - stubs for now
## Documentation: https://godotsteam.com/

extends Node
class_name SteamManager

## Signals
signal steam_initialized(success: bool)
signal authentication_complete(steam_id: int)
signal authentication_failed(error: String)
signal overlay_activated(active: bool)
signal achievement_unlocked(achievement_id: String)

## Steam SDK state
var is_steam_available: bool = false
var steam_app_id: int = 0  # Replace with actual Steam App ID
var steam_user_id: int = 0
var steam_username: String = ""
var is_overlay_enabled: bool = false

## Initialization flags
var _initialization_attempted: bool = false
var _is_initialized: bool = false

func _ready() -> void:
	# Attempt to initialize Steam
	_initialize_steam()

## PLATFORM-001: Initialize GodotSteam plugin (STUB)
func _initialize_steam() -> void:
	if _initialization_attempted:
		return

	_initialization_attempted = true

	# Check if Steam is available (GodotSteam plugin check)
	# STUB: Replace with actual GodotSteam.isSteamRunning() when integrated
	is_steam_available = _check_steam_available()

	if not is_steam_available:
		push_warning("SteamManager: Steam not available. Running in offline mode.")
		_is_initialized = true
		steam_initialized.emit(false)
		return

	# Initialize Steam API
	# STUB: Replace with Steam.steamInit() when integrated
	var init_result = _stub_steam_init()

	if init_result:
		_is_initialized = true
		_setup_callbacks()
		push_warning("SteamManager: Steam initialized successfully (STUB MODE)")
		steam_initialized.emit(true)
	else:
		push_error("SteamManager: Failed to initialize Steam")
		steam_initialized.emit(false)

## STUB: Check if Steam is available
func _check_steam_available() -> bool:
	# STUB: Replace with Steam.isSteamRunning()
	# For now, check if running on Steam Deck or if STEAM_RUNTIME env exists
	if OS.has_environment("STEAM_RUNTIME"):
		return true
	return false

## STUB: Initialize Steam SDK
func _stub_steam_init() -> bool:
	# STUB: Replace with actual Steam.steamInit()
	# Simulate successful initialization
	steam_app_id = 480  # Stub App ID (Spacewar)
	return true

## Setup Steam callbacks
func _setup_callbacks() -> void:
	# STUB: Connect to actual Steam callbacks when integrated
	# Steam.connect("steam_user_stats_received", _on_user_stats_received)
	# Steam.connect("overlay_toggled", _on_overlay_toggled)
	pass

## PLATFORM-002: Steam Authentication (STUB)
func authenticate_user() -> void:
	if not is_steam_available:
		authentication_failed.emit("Steam not available")
		return

	# STUB: Replace with Steam.getSteamID() and Steam.getPersonaName()
	steam_user_id = _stub_get_steam_id()
	steam_username = _stub_get_username()

	if steam_user_id > 0:
		push_warning("SteamManager: User authenticated (STUB): %s [%d]" % [steam_username, steam_user_id])
		authentication_complete.emit(steam_user_id)
	else:
		authentication_failed.emit("Failed to get Steam user ID")

## STUB: Get Steam user ID
func _stub_get_steam_id() -> int:
	# STUB: Replace with Steam.getSteamID()
	return 76561197960287930  # Stub ID

## STUB: Get Steam username
func _stub_get_username() -> String:
	# STUB: Replace with Steam.getPersonaName()
	return "StubUser"

## Get current Steam user ID
func get_steam_id() -> int:
	return steam_user_id

## Get current Steam username
func get_username() -> String:
	return steam_username

## Check if Steam is initialized and available
func is_initialized() -> bool:
	return _is_initialized and is_steam_available

## PLATFORM-004: Steam Overlay Support (STUB)
func activate_overlay(dialog: String = "") -> void:
	if not is_steam_available:
		push_warning("SteamManager: Cannot activate overlay - Steam not available")
		return

	# STUB: Replace with Steam.activateGameOverlay(dialog)
	push_warning("SteamManager: Activating overlay (STUB): %s" % dialog)
	# Valid dialog options: "Friends", "Community", "Players", "Settings", "OfficialGameGroup", "Stats", "Achievements"

## Check if overlay is enabled
func is_overlay_active() -> bool:
	if not is_steam_available:
		return false

	# STUB: Replace with Steam.isOverlayEnabled()
	return is_overlay_enabled

## STUB: Overlay toggled callback
func _on_overlay_toggled(active: bool) -> void:
	is_overlay_enabled = active
	overlay_activated.emit(active)

	# Pause game when overlay is active
	if active:
		get_tree().paused = true
	else:
		get_tree().paused = false

## Unlock achievement (delegates to AchievementManager)
func unlock_achievement(achievement_id: String) -> void:
	if not is_steam_available:
		push_warning("SteamManager: Cannot unlock achievement - Steam not available")
		return

	# STUB: Replace with Steam.setAchievement(achievement_id)
	push_warning("SteamManager: Unlocking achievement (STUB): %s" % achievement_id)
	achievement_unlocked.emit(achievement_id)

## Process Steam callbacks
func _process(_delta: float) -> void:
	if is_steam_available:
		# STUB: Replace with Steam.run_callbacks()
		pass

## Cleanup on exit
func _exit_tree() -> void:
	if is_steam_available:
		# STUB: Replace with Steam.steamShutdown()
		push_warning("SteamManager: Shutting down Steam (STUB)")
