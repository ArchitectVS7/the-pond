## PerformanceMonitor - Runtime performance tracking and validation
##
## COMBAT-012: Performance 60fps GTX 1060 validation
## PRD Requirements:
## - 60fps minimum on GTX 1060 @ 1080p
## - 90fps+ average (streaming headroom)
## - 500+ enemies on screen
##
## Features:
## - Real-time FPS and frame time tracking
## - Min/max/average statistics over time
## - Memory and object count monitoring
## - Performance report generation
## - Frame budget analysis
##
## Architecture Notes:
## - Designed as autoload singleton (optional)
## - Can also be instantiated for specific profiling sessions
## - Uses Engine performance counters
## - No significant overhead when not actively tracking
class_name PerformanceMonitor
extends Node

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when performance drops below target
signal performance_warning(current_fps: float, target_fps: float)

## Emitted each frame when tracking is active
signal frame_recorded(fps: float, frame_time_ms: float)

# =============================================================================
# EXPORTS (Tunable in Editor)
# =============================================================================

## Target FPS (PRD: 60fps minimum)
@export var target_fps: float = 60.0

## Warning threshold (emit signal if FPS drops below this)
@export var warning_threshold_fps: float = 55.0

## Whether to actively track statistics
@export var tracking_enabled: bool = false

## How many frames to average for smooth FPS display
@export var smoothing_frames: int = 30

# =============================================================================
# STATE
# =============================================================================

## Whether tracking is currently active
var _is_tracking: bool = false

## Tracked FPS values for averaging
var _fps_history: Array[float] = []

## Minimum FPS recorded during tracking
var _min_fps: float = 0.0

## Maximum FPS recorded during tracking
var _max_fps: float = 0.0

## Sum of all FPS values (for averaging)
var _fps_sum: float = 0.0

## Number of frames tracked
var _frame_count: int = 0

## Tracking start time
var _tracking_start_time: float = 0.0

# =============================================================================
# LIFECYCLE
# =============================================================================


func _ready() -> void:
	if tracking_enabled:
		start_tracking()


func _process(_delta: float) -> void:
	if not _is_tracking:
		return

	var fps := get_fps()
	var frame_time := get_frame_time_ms()

	# Update history for smoothing
	_fps_history.append(fps)
	if _fps_history.size() > smoothing_frames:
		_fps_history.pop_front()

	# Update statistics
	_frame_count += 1
	_fps_sum += fps

	if _min_fps == 0.0 or fps < _min_fps:
		_min_fps = fps
	if fps > _max_fps:
		_max_fps = fps

	# Emit signals
	frame_recorded.emit(fps, frame_time)

	if fps < warning_threshold_fps:
		performance_warning.emit(fps, target_fps)


# =============================================================================
# PUBLIC API - TRACKING CONTROL
# =============================================================================


## Start tracking performance statistics
func start_tracking() -> void:
	_is_tracking = true
	_tracking_start_time = Time.get_ticks_msec() / 1000.0
	reset_tracking()


## Stop tracking
func stop_tracking() -> void:
	_is_tracking = false


## Reset all tracked statistics
func reset_tracking() -> void:
	_fps_history.clear()
	_min_fps = 0.0
	_max_fps = 0.0
	_fps_sum = 0.0
	_frame_count = 0


## Check if tracking is active
func is_tracking() -> bool:
	return _is_tracking


# =============================================================================
# PUBLIC API - CURRENT VALUES
# =============================================================================


## Get current FPS from engine
func get_fps() -> float:
	return Engine.get_frames_per_second()


## Get current frame time in milliseconds
func get_frame_time_ms() -> float:
	var fps := get_fps()
	if fps > 0.0:
		return 1000.0 / fps
	return 0.0


## Get smoothed FPS (averaged over recent frames)
func get_smoothed_fps() -> float:
	if _fps_history.is_empty():
		return get_fps()

	var sum := 0.0
	for fps in _fps_history:
		sum += fps
	return sum / _fps_history.size()


# =============================================================================
# PUBLIC API - TRACKED STATISTICS
# =============================================================================


## Get minimum FPS recorded during tracking
func get_min_fps() -> float:
	return _min_fps


## Get maximum FPS recorded during tracking
func get_max_fps() -> float:
	return _max_fps


## Get average FPS over tracking period
func get_average_fps() -> float:
	if _frame_count == 0:
		return 0.0
	return _fps_sum / _frame_count


## Get total tracking duration in seconds
func get_tracking_duration() -> float:
	if not _is_tracking:
		return 0.0
	return (Time.get_ticks_msec() / 1000.0) - _tracking_start_time


## Get total frames tracked
func get_frame_count() -> int:
	return _frame_count


# =============================================================================
# PUBLIC API - ANALYSIS
# =============================================================================


## Check if current frame time exceeds budget
func is_frame_budget_exceeded(frame_time_ms: float, budget_ms: float) -> bool:
	return frame_time_ms > budget_ms


## Check if performance is throttled (below target)
func is_performance_throttled(current_fps: float, target: float) -> bool:
	return current_fps < target


## Check if meeting PRD requirements (60fps minimum)
func is_meeting_prd_requirements() -> bool:
	return _min_fps >= target_fps


# =============================================================================
# PUBLIC API - SYSTEM STATISTICS
# =============================================================================


## Get comprehensive statistics dictionary
func get_statistics() -> Dictionary:
	return {
		"fps": get_fps(),
		"fps_smoothed": get_smoothed_fps(),
		"frame_time_ms": get_frame_time_ms(),
		"min_fps": _min_fps,
		"max_fps": _max_fps,
		"avg_fps": get_average_fps(),
		"frame_count": _frame_count,
		"duration_seconds": get_tracking_duration(),
		"memory_mb": get_memory_usage_mb(),
		"object_count": get_object_count(),
		"target_fps": target_fps,
		"meeting_target": is_meeting_prd_requirements()
	}


## Get current memory usage in MB
func get_memory_usage_mb() -> float:
	return Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0


## Get current object count
func get_object_count() -> int:
	return int(Performance.get_monitor(Performance.OBJECT_COUNT))


## Get node count
func get_node_count() -> int:
	return int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))


# =============================================================================
# PUBLIC API - REPORTING
# =============================================================================


## Generate performance report string
func generate_report() -> String:
	var stats := get_statistics()
	var lines: Array[String] = []

	lines.append("=== PERFORMANCE REPORT ===")
	lines.append("")
	lines.append("--- Current ---")
	lines.append("FPS: %.1f (smoothed: %.1f)" % [stats.fps, stats.fps_smoothed])
	lines.append("Frame Time: %.2f ms" % stats.frame_time_ms)
	lines.append("")
	lines.append("--- Tracking Period ---")
	lines.append("Duration: %.1f seconds" % stats.duration_seconds)
	lines.append("Frames: %d" % stats.frame_count)
	lines.append("Min FPS: %.1f" % stats.min_fps)
	lines.append("Max FPS: %.1f" % stats.max_fps)
	lines.append("Avg FPS: %.1f" % stats.avg_fps)
	lines.append("")
	lines.append("--- System ---")
	lines.append("Memory: %.1f MB" % stats.memory_mb)
	lines.append("Objects: %d" % stats.object_count)
	lines.append("Nodes: %d" % get_node_count())
	lines.append("")
	lines.append("--- PRD Validation ---")
	lines.append("Target: %.0f fps minimum" % target_fps)

	if stats.meeting_target:
		lines.append("Status: PASSING (min %.1f >= %.0f)" % [stats.min_fps, target_fps])
	else:
		lines.append("Status: FAILING (min %.1f < %.0f)" % [stats.min_fps, target_fps])

	lines.append("")
	lines.append("==========================")

	return "\n".join(lines)


## Print report to console
func print_report() -> void:
	print(generate_report())
