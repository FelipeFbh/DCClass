class_name ConceptClassSceneEditor
extends Node2D

var WHITEBOARD_SIZE: Vector2i

var file: String
@export var class_index: ClassIndex
var entities: Array
var root_tree_structure: ClassNode
var root_tree_structure_controller: GroupController


@onready var root: Node2D = $Class

var zip_file: ZIPReader

var entry_point : NodeController


func _enter_tree():
	WHITEBOARD_SIZE = _load_whiteboard_size()

func _ready():
	if !_parse():
		push_error("Error parsing file: " + file)
		return
	if !_instantiate():
		push_error("Error instantiating class: " + class_index.name)
		return
	zip_file.close()
	print("parse_and_play._ready")


func _load_whiteboard_size() -> Vector2i:
	return ProjectSettings.get_setting("display/whiteboard/size") as Vector2i


func _parse() -> bool:
	zip_file = ZIPReader.new()
	if file == null or file.is_empty():
		file = Persistence.class_path
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
	var root_group: GroupController = GroupController.instantiate(root_tree_structure, entities)
	root_tree_structure_controller = root_group
	entry_point = root_tree_structure_controller
	var node: Node2D = Node2D.new()
	node.add_child(entry_point)
	root.add_child(node)
	return true


func compute_duration() -> void:
	return


func play():
	if !is_instance_valid(entry_point):
		push_error("Error playing content: entry_point is not valid")
		return
	entry_point.play()
