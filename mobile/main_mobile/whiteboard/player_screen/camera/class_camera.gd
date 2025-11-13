class_name ClassCameraMobile
extends Camera2D

## Emitted when the user starts or stops controlling the camera.
signal user_controlled_changed(value: bool)

const KEY_MOVEMENT_SPEED = 20
const ZOOM_CHANGE_SPEED = 0.005
const MIN_ZOOM = 0.8
const MAX_ZOOM = 2.0
# The max recent points
const MAX_RECENT = 30
const CONTENT_MARGIN = 200
const DISTANCE_THRESHOLD = 800
const VERTICAL_THRESHOLD = 800
const ADD_THRESHOLD = 10

# Exports
@export var background: BackgroundMobile

# References
@onready var whiteboard_size: Vector2 = ProjectSettings.get_setting("display/whiteboard/size") as Vector2

# State var
var velocity := Vector2.ZERO
var tween: Tween
var time_scale: float = 1.0
# Recent points drawn, it has a limit for optimization purposes
var recent_content: Array[Vector2] = []
# The zoom the cam uses
var fixed_zoom: float = 0.0
var required_zoom: float = 0.0

# Content bound vars
var min_x: float = 0
var min_y: float = 0
var max_x: float = whiteboard_size.x
var max_y: float = whiteboard_size.y
var content_bounds: Rect2 =  Rect2(
		Vector2(min_x, min_y),
		Vector2(max_x - min_x, max_y - min_y)
	)
var center: Vector2 = content_bounds.get_center()

# Properties
var user_controlled: bool = false:
	set(value):
		user_controlled = value
		if not value:
			_recenter()
		elif is_instance_valid(tween):
			tween.kill()
		user_controlled_changed.emit(value)

func _ready() -> void:
	# sets the initial zoom
	fixed_zoom = init_zoom(0.5)
	zoom = Vector2.ONE * fixed_zoom
	# follows the content
	_recenter()

func _process(_delta):
	if not user_controlled and not recent_content.is_empty():
		# the most expensive function since it acts on each frame
		_follow_content()
	
	# Handles zoom input
	var zoom_input := Input.get_axis("camera_zoom_out", "camera_zoom_in")
	if is_zero_approx(zoom_input):
		return
	zoom_input = zoom_input * ZOOM_CHANGE_SPEED * time_scale + 1.0
	zoom *= zoom_input
	zoom = zoom.clamp(Vector2.ONE * MIN_ZOOM, Vector2.ONE * MAX_ZOOM)
	
	# Changes to follow the recent content
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

# The size of the visible content
func init_zoom(multiplier: float) -> float:
	var viewport_size = get_viewport().get_visible_rect().size
	
	var target_zoom_x = (whiteboard_size.x * multiplier) / viewport_size.x
	var target_zoom_y = (whiteboard_size.y * multiplier) / viewport_size.y
	
	var target_zoom = min(target_zoom_x, target_zoom_y)
	return clamp(target_zoom, MIN_ZOOM, MAX_ZOOM)
	
func _enter_tree():
	if is_instance_valid(ClassUIMobile.context):
		ClassUIMobile.context.camera = self
	
func set_speed_scale(_speed: float) -> void:
	time_scale = 1.0 / _speed
	if is_instance_valid(tween) and tween.is_valid():
		tween.set_speed_scale(time_scale)
	
## Move the camera to the target position in global coordinates
func move_to(target_position: Vector2, target_zoom: float = -1.0) -> void:
	if user_controlled:
		return
		
	if is_instance_valid(tween):
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT).set_parallel().set_speed_scale(time_scale)
	tween.tween_property(self, ^"global_position", target_position, 5.0)
	
	if target_zoom > 0.0:
		tween.tween_property(self, ^"zoom", Vector2.ONE * target_zoom, 5.0)

# Puts the camera on the recent content
func _recenter():
	if not recent_content.is_empty():
		position = recent_content.back()
	else:
		position = whiteboard_size / 2
	
	if required_zoom: 
		zoom = Vector2.ONE * required_zoom
	else:
		zoom = Vector2.ONE * fixed_zoom

# Follows the center of gravity of the most recent content
func _follow_content(cam_velocity: float = 1.0, zoom_velocity: float = 1.0):
	if recent_content.is_empty():
		return
	
	# actual zoom
	var viewport_size = get_viewport().get_visible_rect().size
	var visible_size = viewport_size / zoom
	
	var required_zoom_x = visible_size.x / (content_bounds.size.x + CONTENT_MARGIN * 2)
	var required_zoom_y = visible_size.y / (content_bounds.size.y + CONTENT_MARGIN * 2)
	required_zoom = min(required_zoom_x, required_zoom_y)
	required_zoom = clamp(required_zoom, MIN_ZOOM, MAX_ZOOM)
	
	if is_instance_valid(tween):
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true).set_speed_scale(time_scale)
	tween.tween_property(self, ^"global_position", center, cam_velocity)
	tween.tween_property(self, "zoom", Vector2.ONE * required_zoom, zoom_velocity) 
	
# Adds points to the whiteboard
func add_recent_content(line_pos: Vector2):
	# Checks if the new point is visible
	if not recent_content.is_empty():
		var last_pos = recent_content.back()
		
		# If visible, we stay the same
		# If not, we move
		if !is_inside_cam(line_pos.x, line_pos.y):
			if last_pos.distance_to(line_pos) >= DISTANCE_THRESHOLD:
				_discard_half_points()
				_discard_half_points()
				_reset_bounds()
				
			if abs(last_pos.y - line_pos.y) >= VERTICAL_THRESHOLD:
				recent_content.clear()
				recent_content.append(line_pos)
				_reset_bounds()
				
			# If the zoom is already max
			if zoom.x <= MIN_ZOOM + 0.01 or zoom.y <= MIN_ZOOM + 0.01:
				# We move to the new content bounds
				_discard_half_points()
				_reset_bounds()
	
	# Adds new point, the more distance added, the less precise and more efficient is
	if recent_content.is_empty() or recent_content.back().distance_to(line_pos) > ADD_THRESHOLD:
		if recent_content.is_empty():
			min_x = line_pos.x
			min_y = line_pos.y
			max_x = line_pos.x
			max_y = line_pos.y
		else:
			# everytime we add, we modify the bounds
			min_x = min(min_x, line_pos.x)
			min_y = min(min_y, line_pos.y)
			max_x = max(max_x, line_pos.x)
			max_y = max(max_y, line_pos.y)
		
		_center_of_mass()
		recent_content.append(line_pos)
		
		# checks the limit points allowed to save
		if recent_content.size() > MAX_RECENT:
			recent_content.pop_front()
			
		# follows content
		if not user_controlled:
			_follow_content()
	
# Reset bounds
func _reset_bounds():
	var size = recent_content.size()
	min_x = recent_content[size-1].x
	min_y = recent_content[size-1].y
	max_x = recent_content[size-1].x
	max_y = recent_content[size-1].y
	
	# New bounds
	for point in recent_content:
		min_x = min(min_x, point.x)
		min_y = min(min_y, point.y)
		max_x = max(max_x, point.x)
		max_y = max(max_y, point.y)
	
	_center_of_mass()
	
# Discards half of the old point on the recent lines list
func _discard_half_points():
	if recent_content.size() < 2:
		return
	
	var half_size = recent_content.size() / 2
	var new_recent = recent_content.slice(half_size)
	recent_content = new_recent

# Checks if a point is inside the bounds of the camera
func is_inside_cam(point_x: float, point_y: float) -> bool:
	if (point_x - CONTENT_MARGIN > min_x and point_x + CONTENT_MARGIN < max_x) and (point_y - CONTENT_MARGIN > min_y and point_y + CONTENT_MARGIN < max_y):
		return true
	else:
		return false

# Gets the center of mass of the content
func _center_of_mass():
	if recent_content.is_empty():
		content_bounds = Rect2(
			Vector2(0, 0),
			whiteboard_size
		)
	else:
		var width = max(max_x - min_x, 100.0)
		var height = max(max_y - min_y, 100.0)
		
		content_bounds = Rect2(
			Vector2(min_x, min_y),
			Vector2(width, height)
		)
	
	center = content_bounds.get_center()
	
# Empties the list
func clear_recent():
	recent_content.clear()

func interpolate_zoom(target_zoom: float):
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT).set_speed_scale(time_scale)
	tween.tween_property(self, ^"zoom", Vector2.ONE * target_zoom, 1.0)

func reset_zoom():
	interpolate_zoom(fixed_zoom)
