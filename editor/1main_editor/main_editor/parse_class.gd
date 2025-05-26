class_name ParseClassEditor
extends Node2D

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

var file: String
var entities: Dictionary
@export var class_index: ClassIndex


var root_tree_structure: ClassNode
var _current_node: ClassNode

var zip_file: ZIPReader

func _ready():
	_bus_core.current_node_changed.connect(_current_node_changed)
	_bus.add_class_leaf_entity.connect(_add_class_leaf_entity)
	_bus.add_class_leaf.connect(_add_class_leaf)
	_bus.add_class_group.connect(_add_class_group)


	if !_parse():
		push_error("Error parsing file: " + file)
		return
	if !_instantiate():
		push_error("Error instantiating class: " + class_index.name)
		return
	zip_file.close()
	print("parse._ready")


func _parse() -> bool:
	zip_file = ZIPReader.new()
	if file == null or file.is_empty():
		file = PersistenceEditor.class_path
	print("File: " + file)
	if file == null or file.is_empty():
		push_error("Error: file not set")
		return false
	var err := zip_file.open(file)
	if err != OK:
		push_error("Error %d opening file: " % err)
		return false
	if !zip_file.file_exists("index.json"):
		push_error("Error: index.json not found in zip file")
		return false
	var index_string := zip_file.read_file("index.json").get_string_from_utf8()
	var index = JSON.parse_string(index_string)
	if index == null or typeof(index) != TYPE_DICTIONARY:
		return false
	Widget.zip_file = zip_file
	class_index = ClassIndex.deserialize(index)
	return class_index != null


func _instantiate() -> bool:
	entities = class_index.entities
	root_tree_structure = class_index.tree_structure
	_current_node = root_tree_structure
	return true

func _current_node_changed(current_node):
	_current_node = current_node

func _add_class_leaf_entity(entity: Entity) -> void:
	if entity == null:
		return

	var entity_id: int = entities.size()
	entity.entity_id = entity_id
	entities[entity_id] = entity

	var data_new = {
		"entity_id": entity_id,
		"entity_properties": [],
	}
	var entity_wrapper_new: EntityWrapper = EntityWrapper.deserialize(data_new)
	var class_node = ClassLeaf.new()
	class_node._value = entity_wrapper_new
	

	if _current_node is ClassGroup:
		class_node.set_parent(_current_node)
		var _current_class_group_childrens = _current_node._childrens
		var index_current = _current_class_group_childrens.find(_current_node)
		_current_class_group_childrens.insert(index_current + 1, class_node)
		

	if _current_node is ClassLeaf:
		var parent_node = _current_node._parent
		if parent_node is ClassGroup:
			class_node.set_parent(parent_node)
			var _current_class_group_childrens = parent_node._childrens
			var index_current = _current_class_group_childrens.find(_current_node)
			_current_class_group_childrens.insert(index_current + 1, class_node)
	
	_bus.update_treeindex.emit()
	_bus_core.current_node_changed.emit(class_node)


func _add_class_leaf(class_node: ClassNode) -> void:
	if class_node == null:
		return

	if _current_node is ClassGroup:
		class_node.set_parent(_current_node)
		var _current_class_group_childrens = _current_node._childrens
		var index_current = _current_class_group_childrens.find(_current_node)
		_current_class_group_childrens.insert(index_current + 1, class_node)
		

	if _current_node is ClassLeaf:
		var parent_node = _current_node._parent
		if parent_node is ClassGroup:
			class_node.set_parent(parent_node)
			var _current_class_group_childrens = parent_node._childrens
			var index_current = _current_class_group_childrens.find(_current_node)
			_current_class_group_childrens.insert(index_current + 1, class_node)
	
	_bus.update_treeindex.emit()
	_bus_core.current_node_changed.emit(class_node)


func _add_class_group(class_node: ClassNode, order: bool) -> void:
	if class_node == null:
		return
	
	if _current_node is ClassLeaf or order:
		_add_class_leaf(class_node)
		return
	
	class_node.set_parent(_current_node)
	var _current_class_group_childrens = _current_node._childrens
	var index_current = _current_class_group_childrens.size()
	
	_current_class_group_childrens.insert(index_current, class_node)
	
	_bus.update_treeindex.emit()
	_bus_core.current_node_changed.emit(class_node)
