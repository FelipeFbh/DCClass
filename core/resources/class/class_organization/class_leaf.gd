@tool
# 1. class name: fill the class name
class_name ClassLeaf
extends ClassNode

# 2. docs: use docstring (##) to generate docs for this file


# 3. signals: define signals here


# 4. enums: define enums here


# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var _value : EntityWrapper
@export var _parent: ClassNode


# 7. public variables: define all public variables here


# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func set_parent(parent):
	_parent = parent

func get_class_name():
	return "ClassLeaf"

func get_editor_name(entities: Dictionary):
	return "Leaf > " + _value.get_editor_name(entities)

func serialize():
	pass

static func deserialize(data: Dictionary):
	var instance: ClassLeaf = ClassLeaf.new()
	instance._value = EntityWrapper.deserialize(data)
	return instance

# 13. private methods: define all private methods here, use _ as preffix
func _validate():
	pass
	
# 14. subclasses: define all subclasses here
