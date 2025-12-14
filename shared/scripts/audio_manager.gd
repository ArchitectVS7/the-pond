## AudioManager - Manages combat sound effects
##
## COMBAT-011: Audio feedback wet thwap glorp
## PRD Requirement: "Audio feedback: wet thwap on hit, glorp on enemy death"
##
## Features:
## - Hit sound (wet thwap) on tongue hit
## - Death sound (glorp) on enemy kill
## - Pitch/volume variation for natural sound
## - AudioStreamPlayer pooling for performance
## - Master volume control
## - SFX toggle for accessibility
##
## Architecture Notes:
## - Designed as autoload singleton
## - Uses AudioStreamPlayer pool (not 2D positional)
## - Gracefully handles missing audio files
## - Pitch variation prevents repetitive feel
class_name AudioManager
extends Node

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when a sound is played
signal sound_played(sound_type: String)

# =============================================================================
# EXPORTS (Tunable in Editor - see DEVELOPERS_MANUAL.md)
# =============================================================================

## Whether sound effects are enabled (accessibility)
@export var sfx_enabled: bool = true

## Master volume (0.0 to 1.0)
@export_range(0.0, 1.0, 0.05) var master_volume: float = 1.0:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)

## Pitch variation range (+/- percentage)
## 0.1 = +/- 10% pitch change for variety
@export_range(0.0, 0.5, 0.05) var pitch_variation: float = 0.1

## Maximum simultaneous sounds (pool size)
@export var max_simultaneous_sounds: int = 16

# =============================================================================
# SOUND RESOURCES (Configure in Editor or via paths)
# =============================================================================

## Hit sound (wet thwap) - loaded from path or direct resource
@export var hit_sound: AudioStream = null

## Death sound (glorp) - loaded from path or direct resource
@export var death_sound: AudioStream = null

## Fallback paths if resources not set
@export var hit_sound_path: String = "res://assets/audio/sfx/hit_thwap.wav"
@export var death_sound_path: String = "res://assets/audio/sfx/death_glorp.wav"

# =============================================================================
# STATE
# =============================================================================

## Pool of audio players
var _player_pool: Array[AudioStreamPlayer] = []

## Index of next player to use (round-robin)
var _next_player_index: int = 0

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	# Initialize audio player pool
	for i in range(max_simultaneous_sounds):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"  # Use SFX bus if available
		add_child(player)
		_player_pool.append(player)

	# Try to load sounds from paths if not set
	_load_sounds()


## Load sounds from paths if not already set
func _load_sounds() -> void:
	if hit_sound == null and ResourceLoader.exists(hit_sound_path):
		hit_sound = load(hit_sound_path)

	if death_sound == null and ResourceLoader.exists(death_sound_path):
		death_sound = load(death_sound_path)


# =============================================================================
# PUBLIC API - COMBAT SOUNDS
# =============================================================================


## Play hit sound (wet thwap)
func play_hit() -> void:
	if not sfx_enabled:
		return

	_play_sound_with_variation(hit_sound)
	sound_played.emit("hit")


## Play death sound (glorp)
func play_death() -> void:
	if not sfx_enabled:
		return

	_play_sound_with_variation(death_sound)
	sound_played.emit("death")


## Play hit sound at position (for 2D audio - optional)
func play_hit_at(_position: Vector2) -> void:
	# For now, use non-positional audio
	# Can be extended to use AudioStreamPlayer2D if needed
	play_hit()


## Play death sound at position (for 2D audio - optional)
func play_death_at(_position: Vector2) -> void:
	play_death()


# =============================================================================
# PUBLIC API - GENERIC
# =============================================================================


## Play any sound effect by name
func play_sfx(sound_name: String) -> void:
	if not sfx_enabled:
		return

	match sound_name:
		"hit", "thwap":
			play_hit()
		"death", "glorp":
			play_death()
		_:
			# Unknown sound - emit signal but log warning
			push_warning("AudioManager: Unknown sound '%s'" % sound_name)
			sound_played.emit(sound_name)


## Play any sound at position
func play_sfx_at(sound_name: String, _position: Vector2) -> void:
	play_sfx(sound_name)


## Get count of currently playing sounds
func get_playing_count() -> int:
	var count := 0
	for player in _player_pool:
		if player.playing:
			count += 1
	return count


## Stop all sounds
func stop_all() -> void:
	for player in _player_pool:
		player.stop()


# =============================================================================
# INTERNAL
# =============================================================================


## Play a sound with pitch and volume variation
func _play_sound_with_variation(stream: AudioStream) -> void:
	if stream == null:
		# No audio file loaded - silently skip
		return

	# Get next player from pool (round-robin)
	var player := _player_pool[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _player_pool.size()

	# Stop if already playing (reuse player)
	if player.playing:
		player.stop()

	# Set stream and apply variation
	player.stream = stream
	player.volume_db = linear_to_db(master_volume)
	player.pitch_scale = _get_random_pitch()

	player.play()


## Get random pitch within variation range
func _get_random_pitch() -> float:
	if pitch_variation <= 0.0:
		return 1.0

	var min_pitch := 1.0 - pitch_variation
	var max_pitch := 1.0 + pitch_variation
	return randf_range(min_pitch, max_pitch)
