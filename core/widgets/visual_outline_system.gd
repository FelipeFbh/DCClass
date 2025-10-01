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
var sigs_actives:=false

func _ready() -> void:
	_bus.status_playback_stop.connect(_status_playback_stop)
	pass


# Clean all and assign new outiline to the node
func _current_node_changed(node) -> void:
	current_node = node
	clear_all_outlines()


# Clear all outlines on playing class and reset signal connections
func _status_playback_stop(active: bool) -> void:
	is_editing_mode = active
	if active and not sigs_actives: # Connect editor signals
		_bus_core.current_node_changed.connect(_current_node_changed)
		_bus.execute_after_rendering.connect(add_widget_outline)
		_bus.class_node_selected.connect(_on_class_node_selected)
		_bus.clear_outlines.connect(clear_all_outlines)
		_bus.show_outlines.connect(add_widget_outline)
		_bus.clear_selection.connect(_clear_selection)
		sigs_actives = true
	elif not active:
		clear_all_outlines()
		_bus_core.current_node_changed.disconnect(_current_node_changed)
		_bus.execute_after_rendering.disconnect(add_widget_outline)
		_bus.class_node_selected.disconnect(_on_class_node_selected)
		_bus.clear_outlines.disconnect(clear_all_outlines)
		_bus.show_outlines.disconnect(add_widget_outline)
		_bus.clear_selection.disconnect(_clear_selection)
		sigs_actives = false


# Add or remove outline to selected or unselected nodes
func _on_class_node_selected(node: ClassNode, selected: bool) -> void:
	if node == current_node:
		return
	var controller = node._node_controller
	if node is ClassLeaf: # Case ClassLeaf
		if selected:
			# If is already outlined
			if node in outline_nodes.keys(): 
				return
			
			# Render selected nodes that appears after current node on tree
			if not controller.leaf_value or &"widget_finished" not in controller.leaf_value.get_groups():
				controller.skip_to_end()
				controller.add_to_group(&"skipped_before_play")
			add_widget_outline(node, false)
		else:
			remove_widget_outline(node)
			if &"skipped_before_play" in controller.get_groups():
				controller.clear_before_play()


# Add an outline to a Class Node
func add_widget_outline(node:=current_node, recursive:=true) -> void:
	if not is_editing_mode:
		return
	
	if not node:
		return
	
	# Groups case (add to children)
	if node._node_controller is GroupController and recursive:
		for child in node._node_controller._childrens:
			add_widget_outline(child, false)
		return
	if node._node_controller is not LeafController:
		return

	var widget = node._node_controller.leaf_value
	if not widget:
		return
	
	if node in outline_nodes:
		return

	var outline = _create_outline(widget)
	if not outline:
		return
	widget.add_child(outline)
	outline_nodes[node] = outline


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
		if is_instance_valid(outline):
			outline.queue_free()
	outline_nodes.clear()

# Clear all selected nodes (not considering current)
func _clear_selection():
	clear_all_outlines()
	add_widget_outline()
