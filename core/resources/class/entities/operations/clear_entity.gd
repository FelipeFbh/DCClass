@tool
# 1. class name: fill the class name
class_name ClearEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that holds the reference to an audio file

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here

# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_class_name() -> String:
	return "ClearEntity"

func get_editor_name() -> String:
	return "Clear"

func serialize() -> Dictionary:
	return {
		"entity_type": get_class_name()
	}

func load_data(data: Dictionary) -> void:
	pass

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
