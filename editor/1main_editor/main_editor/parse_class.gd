class_name ParseClassEditor
extends Node2D

@onready var _bus : EditorEventBus = Engine.get_singleton(&"EditorSignals")

var file: String
var entities: Array
@export var class_index: ClassIndex


var root_tree_structure: ClassNode
var tree_manager: TreeManagerEditor
var _current_node_leaf: ClassNode

var zip_file: ZIPReader

func _ready():
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
	return true
