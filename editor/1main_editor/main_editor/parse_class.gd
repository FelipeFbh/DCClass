class_name ParseClassEditor
extends Node

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

var file: String
var entities: Dictionary
@export var class_index: ClassIndex

@onready var root_node_controller: Node = %NodeClass
@onready var root_audio_controller: Node2D = %AudioClass

var root_tree_structure: ClassNode
var _current_node: ClassNode

var zip_file: ZIPReader

func _ready():
	_bus_core.current_node_changed.connect(_current_node_changed)
	_bus.add_class_leaf_entity.connect(_add_class_leaf_entity)
	_bus.add_class_leaf.connect(_add_class_leaf)
	_bus.add_class_group.connect(_add_class_group)
	NodeController.root_node_controller = root_node_controller
	NodeController.root_audio_controller = root_audio_controller


	if !_parse():
		push_error("Error parsing file: " + file)
		return
	if !_instantiate():
		push_error("Error instantiating class: " + class_index.name)
		return
	print("parse._ready")


func _parse() -> bool:
	var zip_path := PersistenceEditor.class_path
	var dir_tmp := "user://tmp/class_editor/"

	if decompress_zip(zip_path, dir_tmp):
		print("Temporal Class Path: ", dir_tmp)
	else:
		push_error("Error %d opening file: " % zip_path)
		return false

	#zip_file = ZIPReader.new()
	#if file == null or file.is_empty():
	#	file = PersistenceEditor.class_path
	#print("File: " + file)
	#if file == null or file.is_empty():
	#	push_error("Error: file not set")
	#	return false
	#var err := zip_file.open(file)
	#if err != OK:
	#	push_error("Error %d opening file: " % err)
	#	return false
	#if !zip_file.file_exists("index.json"):
	#	push_error("Error: index.json not found in zip file")
	#	return false
	
	var index_path = dir_tmp.path_join("index.json")
	var file = FileAccess.open(index_path, FileAccess.READ)
	
	#var index_string := zip_file.read_file("index.json").get_string_from_utf8()
	var index_string := file.get_as_text()
	file.close()
	
	var index = JSON.parse_string(index_string)
	if index == null or typeof(index) != TYPE_DICTIONARY:
		return false
	class_index = ClassIndex.deserialize(index)
	return class_index != null


func _instantiate() -> bool:
	entities = class_index.entities
	root_tree_structure = class_index.tree_structure
	_current_node = root_tree_structure
	return true

func _current_node_changed(current_node):
	_current_node = current_node

func _add_class_leaf_entity(entity: Entity, entity_properties) -> void:
	if entity == null:
		return

	var entity_id: int = entities.size()
	entity.entity_id = entity_id
	entities[entity_id] = entity

	var data_new = {
		"type": "ClassLeaf",
		"entity_id": entity_id,
		"entity_properties": entity_properties
	}
	var class_node = ClassLeaf.deserialize(data_new)
	

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
	_bus.seek_node.emit(class_node)


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
	_bus.seek_node.emit(class_node)

func _add_class_group(class_node: ClassNode, back: bool) -> void:
	if class_node == null:
		return
	
	if _current_node is ClassLeaf:
		var parent_node = _current_node._parent
		if parent_node is ClassGroup:
			class_node.set_parent(parent_node)
			var _current_class_group_childrens = parent_node._childrens
			var index_current = _current_class_group_childrens.find(_current_node)
			_current_class_group_childrens.insert(index_current + 1, class_node)

	if _current_node is ClassGroup:
		class_node.set_parent(_current_node)
		var _current_class_group_childrens = _current_node._childrens
		if back:
			var index_current = _current_class_group_childrens.find(_current_node)
			_current_class_group_childrens.insert(index_current + 1, class_node)
		else:
			var index_current = _current_class_group_childrens.size()
			_current_class_group_childrens.insert(index_current, class_node)
	
	_bus.update_treeindex.emit()
	_bus_core.current_node_changed.emit(class_node)


func decompress_zip(__zip_path: String, __dir_tmp: String) -> bool:
	var reader := ZIPReader.new()
	var err := reader.open(__zip_path)
	if err != OK:
		return false

	if not __dir_tmp.ends_with("/"):
		__dir_tmp += "/"

	if DirAccess.dir_exists_absolute(__dir_tmp):                                             
		_remove_dir_recursively(__dir_tmp)

	DirAccess.make_dir_recursive_absolute(__dir_tmp)                                         

	for internal_path in reader.get_files():
		var absolute_path := __dir_tmp + internal_path
		if internal_path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(absolute_path) 
			continue

		DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())                 

		var file := FileAccess.open(absolute_path, FileAccess.WRITE)
		if not file:
			reader.close()
			return false
		file.store_buffer(reader.read_file(internal_path))
		file.close()

	reader.close()
	return true


func _remove_dir_recursively(ruta: String) -> void:
	for sub_dir in DirAccess.get_directories_at(ruta):                                       
		_remove_dir_recursively(ruta.path_join(sub_dir) + "/")

	for file_name in DirAccess.get_files_at(ruta):                                            
		DirAccess.remove_absolute(ruta.path_join(file_name))                                  

	DirAccess.remove_absolute(ruta)      
