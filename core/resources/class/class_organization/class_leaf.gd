# 1. class name: fill the class name
class_name ClassLeaf
extends ClassNode

# 2. docs: use docstring (##) to generate docs for this file


# 3. signals: define signals here


# 4. enums: define enums here


# 5. constants: define constants here
static var entities: Dictionary

# 6. export variables: define all export variables in groups here
var entity_id
@export var entity: Entity = null
@export var entity_properties: Array[EntityProperty] = []

# 7. public variables: define all public variables here


# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here


func get_class_name():
	return "ClassLeaf"

func get_editor_name() -> String:
	return entity.get_editor_name()

func serialize() -> Dictionary:
	return {
		"type": get_class_name(),
		"entity_id": entity_id,
		"entity_properties": entity_properties.map(func(p): return p.serialize()),
	}

static func deserialize(data: Dictionary) -> ClassLeaf:
	var instance: ClassLeaf = ClassLeaf.new()
	instance.entity_id = data["entity_id"]
	instance.entity = entities[instance.entity_id]
	for property_data in data["entity_properties"]:
		instance.entity_properties.append(EntityProperty.deserialize(property_data))
	return instance

func _setup_controller(is_child_root : bool) -> void:
	var _class: String = get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	var controller: LeafController = CustomClassDB.instantiate(_class)

	_node_controller = controller
	controller._setup(self)
	if is_child_root:
		controller._add_child_root()

## Return a dictionary with all the properties of the entity.
## Keys with the same name will be overwritten.
func get_properties() -> Dictionary:
	var _properties: Dictionary = {}
	for property in entity_properties:
		var _prop: Dictionary = property.get_property()
		_properties.merge(_prop, true)
	return _properties


func self_delete() -> void:
	if entity_id is int and entity_id in entities:
		entity.self_delete()
		entities.erase(entity_id)
	
	if _parent == null:
		return
	_parent.child_delete(self)
	_node_controller.self_delete()

func copy_tmp() -> ClassLeaf:
	var new_leaf: ClassLeaf = ClassLeaf.new()
	new_leaf.entity = entity.copy_tmp()
	new_leaf.entity_properties = []
	for property in entity_properties:
		new_leaf.entity_properties.append(property.copy_tmp())
	return new_leaf

# 13. private methods: define all private methods here, use _ as preffix
func _validate():
	pass
	
# 14. subclasses: define all subclasses here
