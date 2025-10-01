class_name SelectionArea
extends Area2D

signal widget_selected(class_node: ClassNode, selected: bool)

@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

var class_node: ClassNode
var collision_shape: CollisionShape2D
var is_selected: bool = false
var on_edit := true

func _ready():
	_bus.status_playback_stop.connect(status_playback_stop)
	
	# Area2D settings
	monitoring = true
	monitorable = true
	collision_layer = 1  # selection layer
	collision_mask = 0  

	# Mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	
	# Collision
	collision_shape = CollisionShape2D.new()
	add_child(collision_shape)

# Refresh editing status
func status_playback_stop(active: bool):
	on_edit = true

func setup_for_widget(widget: Widget, node: ClassNode):
	class_node = node
	update_collision_shape(widget)

func update_collision_shape(widget: Widget):
	var rect = widget.get_rect_bound()
	
	# No bounds case
	if rect.size == Vector2.ZERO:
		return
	
	# Make a rect shape
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	collision_shape.shape = shape
	collision_shape.position = rect.position + rect.size * 0.5

func _on_mouse_entered():
	if not is_selected:
		modulate = Color(1.2, 1.2, 1.2, 0.3)  # Highlight

func _on_mouse_exited():
	if not is_selected:
		modulate = Color.WHITE

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Multi Select
			var multi_select = Input.is_key_pressed(KEY_CTRL)
			set_selected(!is_selected, multi_select)

func set_selected(selected: bool, multi_select: bool = false):
	is_selected = selected
	if selected:
		modulate = Color(1.5, 1.5, 1.5, 0.5)  # Select color
	else:
		modulate = Color.WHITE

	widget_selected.emit(class_node, selected)
