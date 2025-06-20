@tool
# 1. class name: fill the class name
class_name PausePlaybackEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## Represents an infinite pause

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here

# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here
func _init() -> void:
	entity_id = "PausePlayback"


# 11. virtual methods: define other virtual methos here
func get_class_name() -> String:
	return "PausePlaybackEntity"

func get_editor_name() -> String:
	return "Pause"

func serialize() -> Dictionary:
	return {
		"entity_id": entity_id,
		"entity_type": get_class_name(),
		"duration": duration
	}

func load_data(data: Dictionary) -> void:
	pass

# 12. public methods: define all public methods here

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
