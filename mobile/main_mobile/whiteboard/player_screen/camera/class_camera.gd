class_name ClassCameraMobile
extends Camera2D

## Emitted when the user starts or stops controlling the camera.
signal user_controlled_changed(value: bool)

const KEY_MOVEMENT_SPEED = 20
const ZOOM_CHANGE_SPEED = 0.005
const GRID_ZOOM_THRESHOLD = 0.85
const MIN_ZOOM = 0.5
const MAX_ZOOM = 3.0

var velocity := Vector2.ZERO
var tween: Tween
var time_scale: float = 1.0
var user_controlled: bool = false:
	set(value):
		user_controlled = value
		if not value:
			_recenter()
		elif is_instance_valid(tween):
			tween.kill()
		user_controlled_changed.emit(value)

@export var background: BackgroundMobile
@onready var whiteboard_size: Vector2 = ProjectSettings.get_setting("display/whiteboard/size") as Vector2

# Cámara con seguimiento de contenido
var recent_content: Array[Vector2] = []
var max_recent: int = 10

func _enter_tree():
	if is_instance_valid(ClassUIMobile.context):
		ClassUIMobile.context.camera = self

func set_speed_scale(_speed: float) -> void:
	time_scale = 1.0 / _speed
	if is_instance_valid(tween) and tween.is_valid():
		tween.set_speed_scale(time_scale)

func _ready() -> void:
	# var mobile_zoom = quarter_zoom()
	# zoom = Vector2.ONE * mobile_zoom
	_recenter()

func _process(_delta):
	# if not user_controlled and not recent_content.is_empty():
		# _follow_content()
		
	var zoom_input := Input.get_axis("camera_zoom_out", "camera_zoom_in")
	if is_zero_approx(zoom_input):
		return
	zoom_input = zoom_input * ZOOM_CHANGE_SPEED * time_scale + 1.0
	zoom *= zoom_input
	zoom = zoom.clamp(Vector2.ONE * MIN_ZOOM, Vector2.ONE * MAX_ZOOM)
	return
	
	if Input.is_action_just_pressed("camera_recenter") and user_controlled:
		user_controlled = false
		return
		
	var input := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if input.is_zero_approx():
		velocity = velocity.move_toward(Vector2.ZERO, 1.0)
	else:
		user_controlled = true
		velocity = velocity.move_toward(input * KEY_MOVEMENT_SPEED, 0.6)
	position += velocity * zoom

# The size of the visible content is a quarter of the whiteboard
func quarter_zoom() -> float:
	var viewport_size = get_viewport().get_visible_rect().size
	
	var target_zoom_x = (whiteboard_size.x * 0.5) / viewport_size.x
	var target_zoom_y = (whiteboard_size.y * 0.5) / viewport_size.y
	
	var target_zoom = min(target_zoom_x, target_zoom_y)
	
	return clamp(target_zoom, MIN_ZOOM, MAX_ZOOM)

# Follows the most recent content
func _follow_content():
	if recent_content.is_empty():
		return
	
	var most_recent = recent_content.back()
	
	if is_instance_valid(tween):
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_speed_scale(time_scale)
	tween.tween_property(self, "global_position", most_recent, 0.3)

## Move the camera to the target position in global coordinates
func move_to(target_position: Vector2, target_zoom: float = -1.0) -> void:
	if user_controlled:
		return
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT).set_parallel().set_speed_scale(time_scale)
	tween.tween_property(self, ^"global_position", target_position, 1.0)
	if target_zoom > 0.0:
		tween.tween_property(self, ^"zoom", Vector2.ONE * target_zoom, 1.0)

func _recenter():
	if not recent_content.is_empty():
		position = recent_content.back()
	else:
		position = whiteboard_size / 2
		
	# var target_center = whiteboard_size / 2
	# position = target_center

func add_recent_content(position: Vector2):
	recent_content.append(position)
	
	if recent_content.size() > max_recent:
		recent_content.pop_front()
	
	if not user_controlled:
		_follow_content()

# Empties the list
func clear_recent():
	recent_content.clear()

func interpolate_zoom(target_zoom: float):
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT).set_speed_scale(time_scale)
	tween.tween_property(self, ^"zoom", Vector2.ONE * target_zoom, 1.0)

func reset_zoom():
	interpolate_zoom(quarter_zoom())
