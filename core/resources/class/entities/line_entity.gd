@tool
# 1. class name: fill the class name
class_name LineEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that represents a line

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var points: PackedVector2Array
var delays: Array

# TODO: add property variables
# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_class_name() -> String:
	return "LineEntity"

func get_editor_name() -> String:
	return "Line: " + str(len(points)) + " points"

func serialize() -> Dictionary:
	var points_array: Array = Array(points)
	return {
		"entity_type": get_class_name(),
		"points": points_array.map(func(v): return {"x": v.x, "y": v.y}),
		"delays": delays
	}

func load_data(data: Dictionary) -> void:
	var points_array: Array = []
	for point in data["points"]:
		points_array.append(Vector2(point["x"], point["y"]))
	points = PackedVector2Array(points_array)
	delays = data["delays"]
	duration = compute_duration()

func compute_duration() -> float:
	var total_duration: float = 0.0
	for delay in delays:
		total_duration += delay
	return total_duration 
# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
