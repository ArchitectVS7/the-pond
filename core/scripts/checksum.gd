## SAVE-002: CRC32 checksum validation
## Provides data integrity checking for save files
extends RefCounted
class_name Checksum

## CRC32 lookup table
static var _crc_table: PackedInt32Array = []
static var _table_initialized := false

## Initialize CRC32 lookup table (called once)
static func _ensure_table_initialized() -> void:
	if _table_initialized:
		return

	_crc_table.resize(256)
	for i in range(256):
		var crc := i
		for _j in range(8):
			if crc & 1:
				crc = (crc >> 1) ^ 0xEDB88320
			else:
				crc = crc >> 1
		_crc_table[i] = crc

	_table_initialized = true

## Calculate CRC32 checksum for a string
static func calculate_crc32(data: String) -> String:
	_ensure_table_initialized()

	var crc := 0xFFFFFFFF
	var bytes := data.to_utf8_buffer()

	for byte in bytes:
		var table_index := (crc ^ byte) & 0xFF
		crc = (_crc_table[table_index] ^ (crc >> 8)) & 0xFFFFFFFF

	crc = crc ^ 0xFFFFFFFF
	return "%08x" % crc

## Validate data against checksum
static func validate(data: String, expected_checksum: String) -> bool:
	var calculated := calculate_crc32(data)
	return calculated == expected_checksum

## Calculate checksum for SaveData
static func calculate_for_save(save_data: SaveData) -> String:
	return calculate_crc32(save_data.to_json_string())

## Validate SaveData checksum
static func validate_save(save_data: SaveData) -> bool:
	if save_data.checksum.is_empty():
		return false
	return validate(save_data.to_json_string(), save_data.checksum)
