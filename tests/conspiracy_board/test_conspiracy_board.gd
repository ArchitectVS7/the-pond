## Unit tests for ConspiracyBoard scene
extends GutTest

const CONSPIRACY_BOARD_SCENE = preload("res://conspiracy_board/scenes/ConspiracyBoard.tscn")
const EXPECTED_WIDTH = 1920
const EXPECTED_HEIGHT = 1080

var board: ConspiracyBoard = null


func before_each():
	board = CONSPIRACY_BOARD_SCENE.instantiate()
	add_child_autofree(board)


func after_each():
	if board and is_instance_valid(board):
		board.queue_free()
	board = null


## Test: Scene loads without error
func test_corkboard_loads():
	assert_not_null(board, "ConspiracyBoard scene should load successfully")
	assert_true(board is ConspiracyBoard, "Scene should be a ConspiracyBoard instance")
	assert_true(board is Control, "ConspiracyBoard should extend Control")


## Test: Correct viewport size
func test_corkboard_dimensions():
	# Wait one frame for scene to initialize
	await get_tree().process_frame

	var viewport = board.get_node_or_null("ViewportContainer/BoardViewport")
	assert_not_null(viewport, "BoardViewport should exist")

	var size = viewport.size
	assert_eq(size.x, EXPECTED_WIDTH, "Viewport width should be 1920")
	assert_eq(size.y, EXPECTED_HEIGHT, "Viewport height should be 1080")


## Test: Background exists and has correct color
func test_background_exists():
	var background = board.get_node_or_null("Background")
	assert_not_null(background, "Background ColorRect should exist")
	assert_true(background is ColorRect, "Background should be a ColorRect")

	# Check for warm brown tone (approximate values)
	var color = background.color
	assert_true(color.r > 0.5 and color.r < 0.6, "Red channel should be warm brown")
	assert_true(color.g > 0.3 and color.g < 0.4, "Green channel should be warm brown")
	assert_true(color.b > 0.2 and color.b < 0.3, "Blue channel should be warm brown")


## Test: Vignette shader material exists
func test_vignette_shader_exists():
	var background = board.get_node_or_null("Background")
	assert_not_null(background, "Background should exist")

	var material = background.material
	assert_not_null(material, "Background should have material")
	assert_true(material is ShaderMaterial, "Material should be ShaderMaterial")


## Test: Vignette strength parameter
func test_vignette_strength_parameter():
	# Default value
	assert_almost_eq(board.vignette_strength, 0.2, 0.01, "Default vignette strength should be 0.2")

	# Set new value
	board.set_vignette_strength(0.5)
	assert_almost_eq(board.vignette_strength, 0.5, 0.01, "Vignette strength should update to 0.5")

	# Test clamping
	board.set_vignette_strength(1.5)
	assert_almost_eq(board.vignette_strength, 1.0, 0.01, "Vignette strength should clamp to 1.0")

	board.set_vignette_strength(-0.5)
	assert_almost_eq(board.vignette_strength, 0.0, 0.01, "Vignette strength should clamp to 0.0")


## Test: Vignette radius parameter
func test_vignette_radius_parameter():
	# Default value
	assert_almost_eq(board.vignette_radius, 0.8, 0.01, "Default vignette radius should be 0.8")

	# Set new value
	board.set_vignette_radius(0.6)
	assert_almost_eq(board.vignette_radius, 0.6, 0.01, "Vignette radius should update to 0.6")

	# Test clamping
	board.set_vignette_radius(1.5)
	assert_almost_eq(board.vignette_radius, 1.0, 0.01, "Vignette radius should clamp to 1.0")

	board.set_vignette_radius(-0.5)
	assert_almost_eq(board.vignette_radius, 0.0, 0.01, "Vignette radius should clamp to 0.0")


## Test: Background color getter and setter
func test_background_color_methods():
	var test_color = Color(1.0, 0.0, 0.0, 1.0)

	board.set_background_color(test_color)
	var result_color = board.get_background_color()

	assert_almost_eq(result_color.r, test_color.r, 0.01, "Red channel should match")
	assert_almost_eq(result_color.g, test_color.g, 0.01, "Green channel should match")
	assert_almost_eq(result_color.b, test_color.b, 0.01, "Blue channel should match")
	assert_almost_eq(result_color.a, test_color.a, 0.01, "Alpha channel should match")


## Test: Board fills the parent control
func test_board_fills_viewport():
	await get_tree().process_frame

	# Check anchors are set to fill
	assert_eq(board.anchor_left, 0.0, "Left anchor should be 0")
	assert_eq(board.anchor_top, 0.0, "Top anchor should be 0")
	assert_eq(board.anchor_right, 1.0, "Right anchor should be 1")
	assert_eq(board.anchor_bottom, 1.0, "Bottom anchor should be 1")


## Test: Background z-index for proper rendering order
func test_background_z_index():
	var background = board.get_node_or_null("Background")
	assert_not_null(background, "Background should exist")
	assert_eq(background.z_index, -1, "Background should have z_index of -1")
