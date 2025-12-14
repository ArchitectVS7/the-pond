## test_data_content.gd
## Unit tests for Epic-004: Environmental Data Content
## Tests verify all data logs exist, load correctly, and meet content requirements

extends GutTest

## Test that all 7 markdown data log files exist
func test_all_markdown_logs_exist() -> void:
	var log_files := [
		"01_corporate_memo",
		"02_lab_report",
		"03_whistleblower",
		"04_inspection",
		"05_safety_report",
		"06_pr_strategy",
		"07_financial"
	]

	for log_file in log_files:
		var path := "res://conspiracy_board/content/data_logs/" + log_file + ".md"
		assert_true(FileAccess.file_exists(path), "Missing markdown file: " + path)


## Test that all 7 DataLogResource files exist and load correctly
func test_all_resources_load() -> void:
	for i in range(1, 8):
		var path := "res://conspiracy_board/resources/data_logs/data_log_%02d.tres" % i
		var res := load(path)
		assert_not_null(res, "Failed to load resource: " + path)
		assert_true(res is DataLogResource, "Resource is not DataLogResource: " + path)


## Test that all resources have non-empty titles
func test_logs_have_titles() -> void:
	for i in range(1, 8):
		var path := "res://conspiracy_board/resources/data_logs/data_log_%02d.tres" % i
		var res := load(path) as DataLogResource
		assert_not_null(res.title, "Title is null: " + path)
		assert_gt(res.title.length(), 0, "Title is empty: " + path)


## Test that all resources have TL;DR summaries within word limit
func test_logs_have_tldr() -> void:
	for i in range(1, 8):
		var path := "res://conspiracy_board/resources/data_logs/data_log_%02d.tres" % i
		var res := load(path) as DataLogResource

		# Summary must exist and not be empty
		assert_not_null(res.summary, "Summary is null: " + path)
		assert_gt(res.summary.length(), 0, "Summary is empty: " + path)

		# Summary must be <= 300 characters (roughly 50 words)
		assert_lte(res.summary.length(), 300, "Summary too long: " + path + " (" + str(res.summary.length()) + " chars)")


## Test that all resources have full text content
func test_logs_have_full_text() -> void:
	for i in range(1, 8):
		var path := "res://conspiracy_board/resources/data_logs/data_log_%02d.tres" % i
		var res := load(path) as DataLogResource

		# Full text must exist and not be empty
		assert_not_null(res.full_text, "Full text is null: " + path)
		assert_gt(res.full_text.length(), 0, "Full text is empty: " + path)

		# Full text should be substantial (minimum 500 characters)
		assert_gte(res.full_text.length(), 500, "Full text too short: " + path)


## Test that full text meets word count requirements (200-400 words minimum)
func test_logs_meet_word_count() -> void:
	for i in range(1, 8):
		var path := "res://conspiracy_board/resources/data_logs/data_log_%02d.tres" % i
		var res := load(path) as DataLogResource

		# Estimate word count (split by whitespace)
		var words := res.full_text.split(" ", false)
		var word_count := words.size()

		# Should have at least 200 words of content
		assert_gte(word_count, 200, "Word count too low: " + path + " (" + str(word_count) + " words)")


## Test that all resources have valid IDs
func test_logs_have_valid_ids() -> void:
	for i in range(1, 8):
		var path := "res://conspiracy_board/resources/data_logs/data_log_%02d.tres" % i
		var res := load(path) as DataLogResource

		# ID must match expected format
		var expected_id := "data_log_%02d" % i
		assert_eq(res.id, expected_id, "ID mismatch: " + path)


## Test that resources start as undiscovered
func test_logs_start_undiscovered() -> void:
	for i in range(1, 8):
		var path := "res://conspiracy_board/resources/data_logs/data_log_%02d.tres" % i
		var res := load(path) as DataLogResource

		# Logs should start undiscovered (player must find them)
		assert_false(res.discovered, "Log should start undiscovered: " + path)


## Test that resources have appropriate categories
func test_logs_have_categories() -> void:
	for i in range(1, 8):
		var path := "res://conspiracy_board/resources/data_logs/data_log_%02d.tres" % i
		var res := load(path) as DataLogResource

		# Category should exist (can be empty string, but not null)
		assert_not_null(res.category, "Category is null: " + path)


## Test specific content requirements for each log
func test_log_01_corporate_memo() -> void:
	var res := load("res://conspiracy_board/resources/data_logs/data_log_01.tres") as DataLogResource

	# Should mention cost savings
	assert_string_contains(res.full_text, "2.3", "Missing cost savings amount")

	# Should mention AgriCorp or similar corporation
	assert_true(
		res.full_text.contains("AgriCorp") or res.full_text.contains("Corp") or res.full_text.contains("VP"),
		"Missing corporate context"
	)


func test_log_02_lab_report() -> void:
	var res := load("res://conspiracy_board/resources/data_logs/data_log_02.tres") as DataLogResource

	# Should mention mercury
	assert_string_contains(res.full_text.to_lower(), "mercury", "Missing mercury reference")

	# Should mention EPA limits
	assert_string_contains(res.full_text, "EPA", "Missing EPA reference")

	# Should mention percentage exceedance
	assert_string_contains(res.full_text, "340%", "Missing exceedance percentage")


func test_log_03_whistleblower() -> void:
	var res := load("res://conspiracy_board/resources/data_logs/data_log_03.tres") as DataLogResource

	# Should be a sworn testimony or affidavit
	assert_true(
		res.full_text.contains("Affidavit") or res.full_text.contains("Testimony") or res.full_text.contains("sworn"),
		"Missing legal testimony context"
	)

	# Should mention illegal dumping
	assert_true(
		res.full_text.to_lower().contains("dump") or res.full_text.to_lower().contains("discharge"),
		"Missing dumping reference"
	)


func test_log_04_inspection_report() -> void:
	var res := load("res://conspiracy_board/resources/data_logs/data_log_04.tres") as DataLogResource

	# Should have redactions
	assert_string_contains(res.full_text, "REDACTED", "Missing redactions")

	# Should mention EPA or government agency
	assert_string_contains(res.full_text, "EPA", "Missing EPA reference")


func test_log_05_safety_report() -> void:
	var res := load("res://conspiracy_board/resources/data_logs/data_log_05.tres") as DataLogResource

	# Should mention Tank 7-B or similar infrastructure
	assert_true(
		res.full_text.contains("Tank") or res.full_text.contains("infrastructure"),
		"Missing infrastructure reference"
	)

	# Should mention cost of repairs
	assert_true(
		res.full_text.contains("850") or res.full_text.contains("million") or res.full_text.contains("cost"),
		"Missing cost reference"
	)


func test_log_06_pr_strategy() -> void:
	var res := load("res://conspiracy_board/resources/data_logs/data_log_06.tres") as DataLogResource

	# Should mention budget
	assert_true(
		res.full_text.contains("1.2M") or res.full_text.contains("Budget") or res.full_text.contains("$"),
		"Missing budget reference"
	)

	# Should mention PR or communications
	assert_true(
		res.full_text.contains("PR") or res.full_text.contains("Communications") or res.full_text.contains("campaign"),
		"Missing PR context"
	)


func test_log_07_financial_analysis() -> void:
	var res := load("res://conspiracy_board/resources/data_logs/data_log_07.tres") as DataLogResource

	# Should have cost comparison
	assert_true(
		res.full_text.contains("Scenario A") or res.full_text.contains("Scenario B"),
		"Missing scenario comparison"
	)

	# Should mention savings
	assert_true(
		res.full_text.contains("savings") or res.full_text.contains("cheaper") or res.full_text.contains("cost"),
		"Missing financial analysis"
	)

	# Should be approved
	assert_string_contains(res.full_text, "APPROVED", "Missing approval stamp")


## Test research notes file exists
func test_research_notes_exist() -> void:
	var path := "res://conspiracy_board/content/research_notes.md"
	assert_true(FileAccess.file_exists(path), "Research notes file missing")


## Test bibliography exists
func test_bibliography_exists() -> void:
	var path := "res://conspiracy_board/content/bibliography.md"
	assert_true(FileAccess.file_exists(path), "Bibliography file missing")


## Test outreach template exists (blocked story)
func test_outreach_template_exists() -> void:
	var path := "res://conspiracy_board/content/outreach_template.md"
	assert_true(FileAccess.file_exists(path), "NGO outreach template file missing")


## Test that bibliography contains APA citations
func test_bibliography_has_citations() -> void:
	var path := "res://conspiracy_board/content/bibliography.md"
	var file := FileAccess.open(path, FileAccess.READ)

	assert_not_null(file, "Failed to open bibliography")

	var content := file.get_as_text()
	file.close()

	# Should contain APA style citations (years in parentheses)
	assert_true(
		content.contains("(20") or content.contains("[20"),
		"Bibliography missing date citations"
	)

	# Should contain DOI or URL references
	assert_true(
		content.contains("https://") or content.contains("doi.org"),
		"Bibliography missing URLs/DOIs"
	)


## Test data log connections
func test_log_connections() -> void:
	# Log 02 should connect to logs 01 and 07
	var log_02 := load("res://conspiracy_board/resources/data_logs/data_log_02.tres") as DataLogResource
	assert_true(log_02.connections.size() > 0, "Log 02 should have connections")

	# Log 07 should connect to multiple logs (it's the financial summary)
	var log_07 := load("res://conspiracy_board/resources/data_logs/data_log_07.tres") as DataLogResource
	assert_true(log_07.connections.size() >= 2, "Log 07 should connect to multiple logs")


## Test discovery flow (optional - game logic dependent)
func test_discovery_state_can_toggle() -> void:
	var res := load("res://conspiracy_board/resources/data_logs/data_log_01.tres") as DataLogResource

	# Should start undiscovered
	assert_false(res.discovered, "Should start undiscovered")

	# Can be discovered
	res.discover()
	assert_true(res.discovered, "Discover() should set discovered=true")


## Performance test: Load all resources quickly
func test_all_resources_load_quickly() -> void:
	var start_time := Time.get_ticks_msec()

	for i in range(1, 8):
		var path := "res://conspiracy_board/resources/data_logs/data_log_%02d.tres" % i
		var res := load(path)
		assert_not_null(res)

	var elapsed := Time.get_ticks_msec() - start_time

	# Loading 7 resources should take < 100ms
	assert_lt(elapsed, 100, "Resource loading too slow: " + str(elapsed) + "ms")
