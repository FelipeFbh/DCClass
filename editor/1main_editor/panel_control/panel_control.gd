class_name PanelControl
extends MarginContainer

@export var detach_window: PackedScene

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

signal pen_toggled(active: bool)
signal request_detach

@onready var btn_pen: Button = %PenButton
@onready var btn_detach: Button = %DetachButton
@onready var btn_add_group: Button = %AddGroupButton
@onready var btn_add_clear: Button = %ClearButton
@onready var btn_remove: Button = %RemoveButton
@onready var btn_push_group: Button = %PushGroupButton

@onready var index_tree_parent: Control = %IndexClass


var _parse_class: ParseClassEditor
var tree_manager: TreeManagerEditor
var _current_node: ClassNode
var _class_index: ClassIndex


func _ready() -> void:
	_bus_core.current_node_changed.connect(_current_node_changed)
	_bus.update_treeindex.connect(_setup_index_class)
	
	btn_pen.toggle_mode = true
	btn_pen.toggled.connect(_on_button_pen_toggled)
	btn_detach.pressed.connect(_on_button_detach_pressed)
	btn_add_clear.pressed.connect(_on_button_add_clear_pressed)
	btn_add_group.pressed.connect(_on_button_add_group_pressed)
	btn_push_group.pressed.connect(_on_button_push_group_pressed)


func _setup_parse_class(parse_class: ParseClassEditor = _parse_class):
	_parse_class = parse_class
	_setup_index_class()
	_current_node_changed(parse_class._current_node)

func _setup_index_class():
	_class_index = _parse_class.class_index
	var entities = _class_index.entities
	var root_tree_structure = _class_index.tree_structure
	if tree_manager != null:
		index_tree_parent.remove_child(tree_manager.tree_manager_index)
		tree_manager.queue_free()
		tree_manager = null

	tree_manager = TreeManagerEditor.new()
	tree_manager.build(root_tree_structure, entities)
	index_tree_parent.add_child(tree_manager.tree_manager_index)
	tree_manager.tree_manager_index.item_activated.connect(_on_item_activated)

func _on_button_pen_toggled(active: bool) -> void:
	_bus.pen_toggled.emit(active)

func _on_button_detach_pressed() -> void:
	_bus.request_detach.emit()


var current_item_tree
func _current_node_changed(current_node):
	if current_item_tree != null:
		current_item_tree.set_custom_color(0, Color.GRAY)
	current_item_tree = tree_manager.find_item_by_node(current_node)
	tree_manager.tree_manager_index.scroll_to_item(current_item_tree, true)
	current_item_tree.set_custom_color(0, Color.LIME_GREEN)
	_current_node = current_node

func _on_item_activated() -> void:
	var item = tree_manager.tree_manager_index.get_selected()
	var node = item.get_metadata(0)
	_bus_core.current_node_changed.emit(node)

func _on_button_add_clear_pressed() -> void:
	var entity_clear = ClearEntity.new()
	var class_node = ClassLeaf.new()
	var entity_wrapper_new = EntityWrapper.new()
	entity_wrapper_new.entity_id = entity_clear.entity_id

	class_node._value = entity_wrapper_new
	_bus.add_class_leaf.emit(class_node)

func _on_button_add_group_pressed() -> void:
	var class_node = ClassGroup.new()
	_bus.add_class_group.emit(class_node, true)

func _on_button_push_group_pressed() -> void:
	var class_node = ClassGroup.new()
	_bus.add_class_group.emit(class_node, false)
