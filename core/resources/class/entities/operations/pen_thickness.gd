@tool
# 1. class name: fill the class name
class_name PenThicknessEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that holds the reference to an audio file

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var thickness: float = 2.0

# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here

# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

func _init() -> void:
	entity_id = "PenThickness"

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_class_name() -> String:
	return "PenThicknessEntity"

func get_editor_name() -> String:
	return "Thickness: " + str(thickness)

# Serialize to a dictionary format(.json) for saving.
func serialize() -> Dictionary:
	return {
		"entity_id": entity_id,
		"entity_type": get_class_name(),
		"thickness": thickness,
	}
	
# Load data from a dictionary format(.json) to resource(ClearEntity).
func load_data(data: Dictionary) -> void:
	thickness = data.get("thickness", 2.0)


# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
