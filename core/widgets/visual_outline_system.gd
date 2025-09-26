class_name VisualOutlineSystem
extends Node

const OUTLINE_COLOR := Color.CYAN
const OUTLINE_WIDTH := 2.0
const OUTLINE_DASHED := true

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

var outline_nodes: Dictionary[ClassNode, Node2D]
var is_editing_mode: bool = true
var current_node: ClassNode

func _ready() -> void:
	_bus_core.current_node_changed.connect(_current_node_changed)
	_bus.execute_after_rendering.connect(add_widget_outline)
	_bus.status_playback_stop.connect(_disabled_toggle_select_item_index)
	pass


# Clean all and assign new outiline to the node
func _current_node_changed(node):
	current_node = node
	clear_all_outlines()


# Clear all outlines on playing class
func _disabled_toggle_select_item_index(active: bool):
	is_editing_mode = active
	clear_all_outlines()


# Add an outline to a Class Node
func add_widget_outline() -> void:
	if not is_editing_mode:
		return
	
	if not current_node:
		return
	if current_node._node_controller is not LeafController:
		return

	var widget = current_node._node_controller.leaf_value
	if not widget:
		return
	
	if current_node in outline_nodes:
		return

	var outline = _create_outline(widget)
	if not outline:
		return
	widget.add_child(outline)
	outline_nodes[current_node] = outline


# Create outline using the widget rect bound
func _create_outline(widget: Widget) -> Node2D:
	var line := Line2D.new()
	line.width = OUTLINE_WIDTH
	line.default_color = OUTLINE_COLOR
	line.closed = true

	var rect = widget.get_rect_bound()
	if not rect or rect.size == Vector2.ZERO:
		return
	
	# Crear los puntos del contorno
	line.add_point(Vector2(rect.position.x, rect.position.y))
	line.add_point(Vector2(rect.position.x + rect.size.x, rect.position.y))
	line.add_point(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y))
	line.add_point(Vector2(rect.position.x, rect.position.y + rect.size.y))

	return line


# Remove outline from given class node
func remove_widget_outline(class_node: ClassNode) -> void:
	if class_node not in outline_nodes:
		return

	outline_nodes[class_node].queue_free()
	outline_nodes.erase(class_node)


# Clear all active outlines
func clear_all_outlines() -> void:
	for outline in outline_nodes.values():
		outline.queue_free()
	outline_nodes.clear()
