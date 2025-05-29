@tool
# 1. class name: fill the class name
class_name ClassGroup
extends ClassNode


# 2. docs: use docstring (##) to generate docs for this file


# 3. signals: define signals here


# 4. enums: define enums here


# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var _name: String
@export var _childrens: Array[ClassNode] = []

# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func add_child(child):
	_childrens.append(child)

func get_class_name():
	return "ClassGroup"

func get_editor_name():
	return _name

func serialize():
	return {
		"name": _name,
		"type": get_class_name(),
		"childrens": _childrens.map(func(p): return p.serialize()),
	}

static func deserialize(data: Dictionary):
	var instance: ClassGroup = ClassGroup.new()
	instance._name = data["name"]
	for child_data in data["childrens"]:
		var child = ClassNode.deserialize(child_data)
		child.set_parent(instance)
		instance.add_child(child)

	var _class: String = instance.get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	var controller: GroupController = CustomClassDB.instantiate(_class)
	controller._class_node = instance
	controller._childrens = controller._class_node._childrens
	instance._node_controller = controller
	return instance

# 13. private methods: define all private methods here, use _ as preffix
func _validate():
	pass
	
# 14. subclasses: define all subclasses here
