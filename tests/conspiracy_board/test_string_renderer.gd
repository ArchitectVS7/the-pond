extends GutTest
## Test suite for StringRenderer bezier curve connections

var string_renderer: StringRenderer

func before_each() -> void:
	string_renderer = StringRenderer.new()
	add_child_autofree(string_renderer)

func after_each() -> void:
	string_renderer = null

## Test that string connects two points correctly
func test_string_connects_points() -> void:
	var start := Vector2(0, 0)
	var end := Vector2(100, 100)

	string_renderer.set_endpoints(start, end)

	var points_array := string_renderer.points
	assert_true(points_array.size() > 0, "String should have points")
	assert_eq(points_array[0], start, "First point should be start")
	assert_eq(points_array[points_array.size() - 1], end, "Last point should be end")

## Test that string has a curve (not a straight line)
func test_string_has_curve() -> void:
	var start := Vector2(0, 100)
	var end := Vector2(200, 100)

	string_renderer.set_endpoints(start, end)

	var points_array := string_renderer.points
	assert_true(points_array.size() > 2, "Should have intermediate points")

	# Check that middle point is not on the straight line
	var mid_point := points_array[points_array.size() / 2]
	var expected_straight_y := 100.0  # Both points at y=100, straight line would be y=100

	assert_ne(mid_point.y, expected_straight_y, "Middle point should deviate from straight line")

## Test that string updates when endpoints change
func test_string_updates_on_move() -> void:
	var start1 := Vector2(0, 0)
	var end1 := Vector2(100, 100)

	string_renderer.set_endpoints(start1, end1)
	var initial_points := string_renderer.points.size()

	var start2 := Vector2(50, 50)
	var end2 := Vector2(150, 150)

	string_renderer.set_endpoints(start2, end2)

	assert_eq(string_renderer.points.size(), initial_points, "Should maintain same point count")
	assert_eq(string_renderer.points[0], start2, "Should update to new start")
	assert_eq(string_renderer.points[string_renderer.points.size() - 1], end2, "Should update to new end")

## Test anti-aliasing is enabled
func test_antialiasing_enabled() -> void:
	assert_true(string_renderer.antialiased, "Anti-aliasing should be enabled")

## Test default color
func test_default_color() -> void:
	assert_eq(string_renderer.default_color, Color.RED, "Default color should be red")

## Test width configuration
func test_width_configuration() -> void:
	assert_eq(string_renderer.width, 2.0, "Default width should be 2.0")

	string_renderer.set_string_width(5.0)
	assert_eq(string_renderer.width, 5.0, "Width should update to 5.0")

## Test color configuration
func test_color_configuration() -> void:
	var new_color := Color.BLUE
	string_renderer.set_string_color(new_color)
	assert_eq(string_renderer.default_color, new_color, "Color should update to blue")

## Test bezier curve amount affects shape
func test_bezier_amount_affects_shape() -> void:
	var start := Vector2(0, 100)
	var end := Vector2(200, 100)

	string_renderer.bezier_curve_amount = 50.0
	string_renderer.set_endpoints(start, end)
	var mid_point_1 := string_renderer.points[string_renderer.points.size() / 2]

	string_renderer.set_bezier_amount(100.0)
	var mid_point_2 := string_renderer.points[string_renderer.points.size() / 2]

	assert_ne(mid_point_1.y, mid_point_2.y, "Bezier amount should affect curve shape")

## Test segment count affects smoothness
func test_segment_count() -> void:
	string_renderer.string_segments = 10
	string_renderer.set_endpoints(Vector2(0, 0), Vector2(100, 100))

	assert_eq(string_renderer.points.size(), 11, "Should have segments + 1 points")

## Test curve length calculation
func test_curve_length() -> void:
	string_renderer.set_endpoints(Vector2(0, 0), Vector2(100, 0))
	var length := string_renderer.get_curve_length()

	assert_gt(length, 0.0, "Curve length should be positive")
	# With bezier curve, length should be greater than straight distance
	assert_gt(length, 100.0, "Curved length should exceed straight distance")

## Test get point at distance
func test_get_point_at_distance() -> void:
	var start := Vector2(0, 0)
	var end := Vector2(100, 100)
	string_renderer.set_endpoints(start, end)

	var point_at_start := string_renderer.get_point_at_distance(0.0)
	var point_at_end := string_renderer.get_point_at_distance(1.0)
	var point_at_mid := string_renderer.get_point_at_distance(0.5)

	assert_almost_eq(point_at_start.distance_to(start), 0.0, 1.0, "Point at 0.0 should be near start")
	assert_almost_eq(point_at_end.distance_to(end), 0.0, 1.0, "Point at 1.0 should be near end")
	assert_true(point_at_mid != start and point_at_mid != end, "Mid point should be different")

## Test negative bezier amount creates upward curve
func test_negative_bezier_creates_upward_curve() -> void:
	var start := Vector2(0, 100)
	var end := Vector2(200, 100)

	string_renderer.set_bezier_amount(-50.0)
	string_renderer.set_endpoints(start, end)

	var mid_point := string_renderer.points[string_renderer.points.size() / 2]
	assert_lt(mid_point.y, 100.0, "Negative bezier should create upward curve")

## Test zero bezier amount creates near-straight line
func test_zero_bezier_amount() -> void:
	var start := Vector2(0, 100)
	var end := Vector2(200, 100)

	string_renderer.set_bezier_amount(0.0)
	string_renderer.set_endpoints(start, end)

	var mid_point := string_renderer.points[string_renderer.points.size() / 2]
	# Should be very close to straight line at y=100
	assert_almost_eq(mid_point.y, 100.0, 5.0, "Zero bezier should be nearly straight")

## Test ready function initializes properties
func test_ready_initializes_properties() -> void:
	var new_renderer := StringRenderer.new()
	new_renderer.string_width = 3.0
	new_renderer.string_color = Color.GREEN
	add_child_autofree(new_renderer)

	assert_eq(new_renderer.width, 3.0, "Width should be set in ready")
	assert_eq(new_renderer.default_color, Color.GREEN, "Color should be set in ready")
	assert_true(new_renderer.antialiased, "Antialiasing should be enabled in ready")
