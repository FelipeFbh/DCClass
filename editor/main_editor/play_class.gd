class_name ClassSceneEditor
extends Node2D

var WHITEBOARD_SIZE: Vector2i

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

var file: String
@export var class_index: ClassIndex
var entities: Dictionary
var root_tree_structure: ClassNode


var root_tree_structure_controller: NodeController
var tree_manager: TreeManagerEditor
var entry_point: NodeController
var _current_node: ClassNode

@onready var root: Node2D = $Class

var zip_file: ZIPReader


func _enter_tree():
	WHITEBOARD_SIZE = _load_whiteboard_size()

func _ready():
	_bus.seek_node.connect(_seek_node)
	_bus.seek_play.connect(_seek_play)

func _setup_play():
	if !_parse():
		push_error("Error parsing file: " + file)
		return

	if !_instantiate():
		push_error("Error instantiating class: " + class_index.name)
		return
	#zip_file.close()

	print("play._ready")


func _load_whiteboard_size() -> Vector2i:
	return ProjectSettings.get_setting("display/whiteboard/size") as Vector2i


func _parse() -> bool:
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
	#Widget.zip_file = zip_file
	Widget.dir_class = "user://tmp/class_editor/"
	class_index = PersistenceEditor.resources_class.class_index
	return class_index != null


func _instantiate() -> bool:
	entities = class_index.entities
	root_tree_structure = class_index.tree_structure
	root_tree_structure_controller = PersistenceEditor.resources_class.root_tree_structure._node_controller
	var snapshot_visual: Node2D = Node2D.new()
	NodeController.root_visual_controller = root
	root.add_child(snapshot_visual)
	NodeController.root_visual_controller_snapshot = snapshot_visual
	entry_point = root_tree_structure_controller
	return true


func compute_duration() -> void:
	return


func play():
	if !is_instance_valid(entry_point):
		push_error("Error playing content: entry_point is not valid")
		return
	
	entry_point.play_tree()

func _seek_play():
	entry_point = PersistenceEditor.resources_class._current_node._node_controller
	entry_point.play_seek()

func _seek_node(node_seek: ClassNode) -> void:
	get_tree().call_group(&"widget_finished", "clear")
	var node_seek_controller: NodeController = node_seek._node_controller
	var last_clear: LeafController = node_seek_controller.get_last_clear()
	entry_point = root_tree_structure_controller
	if last_clear != null:
		entry_point = last_clear
	entry_point.seek(node_seek_controller, entry_point)
