# 1. class name: fill the class name
class_name ClassNode
extends Resource

# 2. docs: use docstring (##) to generate docs for this file


# 3. signals: define signals here

# 4. enums: define enums here


# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var _parent: ClassNode

var _node_controller: NodeController

# 7. public variables: define all public variables here


# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here

# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_parent_controller():
	if _parent != null:
		return _parent._node_controller
	return null

func set_parent(parent):
	_parent = parent

func get_class_name() -> String:
	return "ClassNode"

func get_editor_name() -> String:
	return "Class_Node"

func serialize() -> Dictionary:
	return {
		"type": get_class_name()
	}

static func deserialize(data: Dictionary) -> ClassNode:
	var instance: ClassNode = CustomClassDB.instantiate(data["type"]).deserialize(data)
	return instance

func self_delete() -> void:
	pass

func child_delete(child: ClassNode) -> void:
	pass


# 13. private methods: define all private methods here, use _ as preffix
func _validate():
	pass


# 14. subclasses: define all subclasses here
