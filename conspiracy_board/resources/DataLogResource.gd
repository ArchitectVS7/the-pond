## DataLogResource.gd
## Resource class for data log entries on the conspiracy board
## Stores metadata, content, and discovery state for each data log

class_name DataLogResource extends Resource

## Unique identifier for this data log
@export var id: String = ""

## Display title of the data log
@export var title: String = ""

## Short summary/preview text (TL;DR version)
@export var summary: String = ""

## Full content text of the data log
@export_multiline var full_text: String = ""

## Whether this data log has been discovered by the player
@export var discovered: bool = false

## Optional category/tag for grouping data logs
@export var category: String = ""

## Optional connection IDs to other data logs or entities
@export var connections: Array[String] = []


## Initialize a new data log resource
func _init(
	p_id: String = "",
	p_title: String = "",
	p_summary: String = "",
	p_full_text: String = "",
	p_discovered: bool = false
) -> void:
	id = p_id
	title = p_title
	summary = p_summary
	full_text = p_full_text
	discovered = p_discovered


## Get truncated summary for preview
func get_preview(max_chars: int = 80) -> String:
	if summary.length() <= max_chars:
		return summary
	return summary.substr(0, max_chars - 3) + "..."


## Mark this data log as discovered
func discover() -> void:
	discovered = true


## Check if this data log is connected to another
func is_connected_to(other_id: String) -> bool:
	return other_id in connections


## Add a connection to another data log or entity
func add_connection(other_id: String) -> void:
	if not is_connected_to(other_id):
		connections.append(other_id)


## Remove a connection
func remove_connection(other_id: String) -> void:
	var index = connections.find(other_id)
	if index >= 0:
		connections.remove_at(index)
