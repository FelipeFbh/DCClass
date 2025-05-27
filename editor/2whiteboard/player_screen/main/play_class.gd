class_name ClassSceneEditor
extends Node2D

var WHITEBOARD_SIZE: Vector2i
@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")

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
	_bus_core.current_node_changed.connect(_current_node_changed)

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
	Widget.zip_file = zip_file
	class_index = ClassUIEditor.context.parse_class.class_index
	return class_index != null


func _instantiate() -> bool:
	entities = class_index.entities
	root_tree_structure = class_index.tree_structure
	#root_tree_structure_controller = GroupController.instantiate(root_tree_structure, entities)
	print(ClassUIEditor.context.parse_class)
	root_tree_structure_controller = ClassUIEditor.context.parse_class.root_tree_structure._node_controller
	var snapshot_visual : Node2D = Node2D.new()
	root.add_child(snapshot_visual)
	NodeController.root_visual_controller_snapshot = snapshot_visual
	entry_point = root_tree_structure_controller
	#tree_manager = TreeManagerEditor.new()
	#tree_manager.build(root_tree_structure, entities)
	return true


func compute_duration() -> void:
	return


func play():
	if !is_instance_valid(entry_point):
		push_error("Error playing content: entry_point is not valid")
		return
	#entry_point = entry_point.get_first_leaf()
	#entry_point = entry_point.get_next_audio_after()
	NodeController.root_visual_controller = root
	entry_point.play_preorden()

func _current_node_changed(current_node):
	_current_node = current_node

var current_item_tree
func _current_node_changed_deprecated(current_node):
	var color_boolean = false
	if _current_node == null:
		color_boolean = true
		current_item_tree = tree_manager.find_item_by_node(current_node)
		current_item_tree.set_custom_color(0, Color.LIME_GREEN if color_boolean else Color.WHITE)
	else:
		current_item_tree.set_custom_color(0, Color.LIME_GREEN if color_boolean else Color.WHITE)
		current_item_tree = tree_manager.get_next_item(_current_node)
		if current_item_tree != null:
			color_boolean = true
			current_item_tree.set_custom_color(0, Color.LIME_GREEN if color_boolean else Color.WHITE)
	
	_current_node = current_node
