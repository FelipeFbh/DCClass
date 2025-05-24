class_name PanelControl
extends MarginContainer

@export var detach_window: PackedScene

@onready var _bus : EditorEventBus = Engine.get_singleton("EditorSignals")

signal pen_toggled(active: bool)
signal request_detach

@onready var btn_pen     : Button  = %PenButton
@onready var btn_detach  : Button  = %DetachButton
@onready var index_tree_parent : Control = %IndexClass

var tree_manager: TreeManagerEditor
var _current_node_leaf: ClassNode


func _ready() -> void:
	_bus.current_node_leaf_changed.connect(_current_node_leaf_changed)
	btn_pen.toggle_mode = true
	btn_pen.toggled.connect(_on_button_pen_toggled)
	btn_detach.pressed.connect(_on_button_detach_pressed)

func _setup_index_class(class_index):
	var entities = class_index.entities
	var root_tree_structure = class_index.tree_structure
	tree_manager = TreeManagerEditor.new()
	tree_manager.build(root_tree_structure, entities)
	index_tree_parent.add_child(tree_manager.tree_manager_index)

func _on_button_pen_toggled(active: bool) -> void:
	_bus.pen_toggled.emit(active) 

func _on_button_detach_pressed() -> void:
	_bus.request_detach.emit() 


var current_item_tree
func _current_node_leaf_changed(current_node_leaf):
	if current_item_tree == null:
		tree_manager.reset_colors()
	else:
		current_item_tree.set_custom_color(0, Color.GRAY)
	current_item_tree = tree_manager.find_item_by_node(current_node_leaf)
	current_item_tree.set_custom_color(0, Color.LIME_GREEN)
	_current_node_leaf = current_node_leaf
