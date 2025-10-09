@tool
# 1. class name: fill the class name
class_name ZoomEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that represents a line

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var cam_pos: Vector2
@export var zoom_level: float
@export var zoom_duration: float

# TODO: add property variables
# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_class_name() -> String:
	return "ZoomEntity"

func get_editor_name() -> String:
	return "Zoom"

# Serialize to a dictionary format(.json) for saving.
func serialize() -> Dictionary:
	return {
		"entity_id": entity_id,
		"entity_type": get_class_name(),
		"position": {
			"x": cam_pos.x,
			"y": cam_pos.y
		},
		"zoom_level": zoom_level,
		"zoom_duration": zoom_duration
	}

# Load data from a dictionary format(.json) to resource(LineEntity).
func load_data(data: Dictionary) -> void:
	pass
	
# Compute the total real duration of the line based on the delays.
func compute_duration() -> void:
	pass

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
