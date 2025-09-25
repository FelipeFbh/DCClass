extends Control

const WARP_OFFSET := -10
const SQUARED_THRESHOLD := 4.0

@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")
@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _viewport_container: SubViewportContainer = %SubViewportContainer
@onready var _viewport: SubViewport = %SubViewport

var camera: ClassCameraEditor

var _dragging: bool = false
var _warped: bool = false

var _pen_enabled: bool = false
var _pressed: bool = false
var _line: Line2D
var _last_point: Vector2 = Vector2.INF

var _zoom_enabled: bool = false

var _pen_thickness: float = 2.0
var _pen_color: Color = Color.WHITE

var _pen_thickness_history: Array = []
var _current_pen_thickness_index: int = -1

var _pen_color_history: Array = []
var _current_pen_color_index: int = -1

var _node_drag_enabled: bool = false
var _current_node: ClassNode
var _nodes_to_drag: Array[ClassLeaf]
var _node_dragging: bool = false
var _drag_start_pos: Vector2
var _nodes_start_pos: Array[Vector2]

func _ready() -> void:
	_bus.pen_toggled.connect(_on_pen_toggled)
	_bus.pen_thickness_changed.connect(_on_pen_thickness_changed)
	_bus.pen_color_changed.connect(_on_pen_color_changed)
	_bus.drag_toggled.connect(_on_node_drag_enabled)
	_bus_core.current_node_changed.connect(_current_node_changed)


func _gui_input(event):
	if _pen_enabled:
		_handle_drawing(event)
		return
	
	#if _zoom_enabled:
		#_handle_zoom(event)
		#return

	if _node_drag_enabled:
		_handle_node_dragging(event)
		return

	if _node_drag_enabled:
		_handle_node_dragging(event)
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		_dragging = event.is_pressed()
	elif event is InputEventMouseMotion and _dragging:
		get_viewport().set_input_as_handled()
		
		if _warped:
			_warped = false
			return

		if not is_instance_valid(camera):
			camera = _viewport.get_camera_2d()
			if not is_instance_valid(camera):
				printerr("Trying to move but no camera available")
				return

		camera.user_controlled = true
		camera.position -= event.relative

		var mouse_pos: Vector2 = event.global_position
		var view := get_global_rect().grow(WARP_OFFSET)
		_warped = not view.has_point(mouse_pos)

		if mouse_pos.x < view.position.x:
			mouse_pos.x = view.end.x
		elif mouse_pos.x > view.end.x:
			mouse_pos.x = view.position.x
		if mouse_pos.y < view.position.y:
			mouse_pos.y = view.end.y
		elif mouse_pos.y > view.end.y:
			mouse_pos.y = view.position.y

		if _warped:
			Input.warp_mouse(mouse_pos)
			
var _delays: Array[float] = []
var _last_time: float = 0.0

func _on_pen_toggled(active: bool) -> void:
	_pen_enabled = active
	_last_time = Time.get_ticks_msec() / 1000.0

func _on_zoom_toggled(active: bool) -> void:
	_zoom_enabled = active
	_last_time = Time.get_ticks_msec() / 1000.0

func _on_pen_thickness_changed(thickness: float) -> void:
	_pen_thickness = thickness
	
	if is_instance_valid(_line):
		_line.width = _pen_thickness

func _on_pen_color_changed(color: Color) -> void:
	_pen_color = color
	
	if is_instance_valid(_line):
		_line.default_color = _pen_color

func _on_node_drag_enabled(enabled: bool) -> void:
	_node_drag_enabled = enabled

func _handle_drawing(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not is_instance_valid(_viewport):
			return
		var pos: Vector2 = _viewport.get_camera_2d().get_global_mouse_position()
		

		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var now = Time.get_ticks_msec() / 1000.0

			if not _pressed:
				_pressed = true
				_line = _new_line()
				_viewport.add_child(_line)
				_line.add_point(pos)
				_last_point = pos


				_delays.clear()
				var delta_time = now - _last_time
				if delta_time > 10:
					delta_time = 10
				_delays.append(delta_time)
				_last_time = now
			else:
				_line.set_point_position(_line.get_point_count() - 1, pos)

				if _last_point.distance_squared_to(pos) > SQUARED_THRESHOLD:
					_line.add_point(pos)
					var delta_time = now - _last_time
					if delta_time > 5:
						delta_time = 5
					_delays.append(delta_time)
					_last_time = now
					_last_point = pos

		elif _pressed:
			_line.add_point(pos)
			_pressed = false

			var now = Time.get_ticks_msec() / 1000.0
			var delta_time = now - _last_time
			if delta_time > 10:
				delta_time = 10
			_delays.append(delta_time)

			var entity := LineEntity.new()
			entity.points = _line.points
			
			var _position_origin: Vector2 = _line.points[0]
			for i in range(entity.points.size()):
				entity.points[i] -= _position_origin
			
			entity.delays = _delays.duplicate()
			entity.duration = entity.compute_duration()
			var new_entity_properties = [
									{
										"position:x": _position_origin.x,
										"position:y": _position_origin.y,
										"property_type": "PositionEntityProperty"
									}
								]

			_bus.emit_signal("add_class_leaf_entity", entity, new_entity_properties)

			var parent = _line.get_parent()

			parent.remove_child(_line)
			_line.queue_free()
			_line = null

func handle_pen_thickness(entity: PenThicknessEntity):
	entity.apply_config(self)
	_save_pen_thickness_to_history("thickness", entity.thickness)

func handle_pen_color(entity: PenColorEntity):
	entity.apply_config(self)
	_save_pen_color_to_history("color", entity.color)
	
func _save_pen_thickness_to_history(type: String, value: float):
	_pen_thickness_history.append({
		"type": type,
		"value": value,
		"time": Time.get_ticks_msec()
	})
	_current_pen_thickness_index = _pen_thickness_history.size() - 1
	
func _save_pen_color_to_history(type: String, color: Color):
	_pen_thickness_history.append({
		"type": type,
		"color": color,
		"time": Time.get_ticks_msec()
	})
	_current_pen_color_index = _pen_color_history.size() - 1


func _handle_node_dragging(event: InputEvent) -> void:
	if not _current_node:
		return
	
	# Start Drag case
	if event is InputEventMouseButton:
		if event.pressed:
			_nodes_start_pos.clear()
			_nodes_to_drag.clear()
			var controller = _current_node._node_controller
			
			# Case when current node is a Leaf and is not an audio
			if controller is LeafController and not controller.is_audio():
				_nodes_to_drag.append(_current_node)
				var widget = controller.leaf_value
				_nodes_start_pos.append(widget.position)
			# Case when current node is a Group and his TreeItem is collapsed
			elif controller is GroupController:
				# Get all nodes added to the skipped visual group
				for node_controller in get_tree().get_nodes_in_group(&"skipped_on_collapsed"):
					if node_controller is LeafController:
						_nodes_to_drag.append(node_controller._class_node)
						var widget = node_controller.leaf_value
						_nodes_start_pos.append(widget.position)
			else:
				return
			# Take note of the initial positions
			_dragging = true
			_drag_start_pos = _viewport.get_camera_2d().get_global_mouse_position()
		else:
			# Execute after release button and save pos prop of nodes
			if _dragging:
				_dragging = false
				var pos: Vector2 = _viewport.get_camera_2d().get_global_mouse_position()
				var offset: Vector2 = pos - _drag_start_pos
				for i in range(len(_nodes_to_drag)):
					var node = _nodes_to_drag[i]
					var node_pos = _nodes_start_pos[i]
					node.set_property_by_type("PositionEntityProperty", {
						"position": node_pos + offset
					})
			return
	# Dragging case
	elif event is InputEventMouseMotion and _dragging:
		if not is_instance_valid(_viewport) or not _current_node:
			return
		var controller = _current_node._node_controller
		
		# Check if current node is a Visual Widget
		if controller is LeafController and controller.is_audio():
			print("No visual")
			return

		# Get an drag offset to apply to all nodes by its own origin previous to the drag
		var pos: Vector2 = _viewport.get_camera_2d().get_global_mouse_position()
		var offset: Vector2 = pos - _drag_start_pos

		for i in range(len(_nodes_to_drag)):
			var ctrl = _nodes_to_drag[i]._node_controller
			var widget = ctrl.leaf_value
			widget.position = _nodes_start_pos[i] + offset


func _new_line() -> Line2D:
	var l := Line2D.new()
	l.width = 4.0
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	l.antialiased = true
	return l

func _current_node_changed(node: ClassNode) -> void:
	_current_node = node
	
