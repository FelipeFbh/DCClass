extends Control

const WARP_OFFSET := -10
const SQUARED_THRESHOLD := 25.0

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

var _node_drag_enabled: bool = false
var _current_node: ClassNode
var _node_dragging: bool = false
var _drag_start_pos: Vector2
var _node_start_pos: Vector2

func _ready() -> void:
	_bus.pen_toggled.connect(_on_pen_toggled)
	_bus.drag_toggled.connect(_on_node_drag_enabled)
	_bus_core.current_node_changed.connect(_current_node_changed)


func _gui_input(event):
	if _pen_enabled:
		_handle_drawing(event)
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
			#print(entity.serialize())


func _handle_node_dragging(event: InputEvent) -> void:
	if not _current_node:
		return
	if event is InputEventMouseButton:
		_dragging = event.is_pressed()
		var controller = _current_node._node_controller
		# Take note of the initial positions
		if controller is LeafController and not controller.is_audio():
			var widget = controller.leaf_value
			_drag_start_pos = _viewport.get_camera_2d().get_global_mouse_position()
			_node_start_pos = widget.position
		else:
			return
	elif event is InputEventMouseMotion and _dragging:
		if not is_instance_valid(_viewport) or not _current_node:
			return
		var controller = _current_node._node_controller
		# Check if current node is a Visual Widget
		if controller is not LeafController or controller.is_audio():
			print("No Hoja o No visual")
			return

		var widget = controller.leaf_value
		var pos: Vector2 = _viewport.get_camera_2d().get_global_mouse_position()
		var offset: Vector2 = pos - _drag_start_pos

		widget.position = _node_start_pos + offset


func _new_line() -> Line2D:
	var l := Line2D.new()
	l.width = 2.0
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	return l

func _current_node_changed(node: ClassNode) -> void:
	_current_node = node
