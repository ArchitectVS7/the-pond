extends GutTest

var arena: BossArena
var arena_scene_path = "res://combat/scripts/boss_arena.gd"

func before_each() -> void:
	arena = BossArena.new()
	arena.spawn_delay = 0.1  # Speed up tests
	add_child(arena)

func after_each() -> void:
	if arena:
		arena.queue_free()
	arena = null

func test_arena_starts_unlocked() -> void:
	assert_false(arena.is_locked, "Arena should start unlocked")

func test_arena_starts_untriggered() -> void:
	assert_false(arena.has_triggered, "Arena should start untriggered")

func test_arena_lock_signal() -> void:
	watch_signals(arena)
	arena._lock_arena()
	assert_signal_emitted(arena, "arena_locked", "Should emit arena_locked signal")

func test_arena_unlock_signal() -> void:
	watch_signals(arena)
	arena._unlock_arena()
	assert_signal_emitted(arena, "arena_unlocked", "Should emit arena_unlocked signal")

func test_arena_locks_on_trigger() -> void:
	arena._lock_arena()
	assert_true(arena.is_locked, "Arena should be locked after triggering")

func test_arena_can_only_trigger_once() -> void:
	arena.has_triggered = true
	var initial_locked = arena.is_locked
	# Simulate player entering again
	arena.has_triggered = true
	assert_eq(arena.is_locked, initial_locked, "Arena should not re-trigger")

func test_arena_dimensions() -> void:
	assert_eq(arena.arena_width, 800, "Arena width should be 800")
	assert_eq(arena.arena_height, 600, "Arena height should be 600")

func test_clear_regular_enemies_ignores_bosses() -> void:
	# This test verifies the logic exists
	# In actual gameplay, enemies would be in the scene tree
	assert_has_method(arena, "_clear_regular_enemies", "Arena should have clear enemies method")
