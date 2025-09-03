extends VSplitContainer

# time that indicates on how many seconds the bottom panel hides
@export var hide_delay: float = 3.0
# fade duration
@export var fade_duration: float = 0.5
# indicates that the process is automatic
@export var auto_start: bool = true

# the elements that will hide from the user
@onready var bottom_panel: PanelContainer = %BottomPanel
@onready var play_button: Button = %StopButton
@onready var whiteboard: Control = %Whiteboard

var is_control_visible: bool = true
var dragging: bool = false

# counts the seconds to hide the bottom panel
var hide_timer: Timer

var tween: Tween

func _ready():
	# starts a new timer
	hide_timer = Timer.new()
	add_child(hide_timer)
	hide_timer.wait_time = hide_delay
	hide_timer.one_shot = true
	hide_timer.timeout.connect(_on_timer_timeout)
	
	bottom_panel.modulate.a = 1.0
	play_button.modulate.a = 1.0
	
	if auto_start:
		start_hide_timer()
	
	whiteboard.gui_input.connect(_on_viewport_input)
	
# resumes or restarts the timer
func start_hide_timer():
	if hide_timer and is_visible:
		hide_timer.start()
	
# Fade out animation
func fade_out_elements():
	if tween:
		tween.kill()
	
	# we make the elements "visible"
	is_control_visible = false
	
	tween = create_tween()
	tween.set_parallel(true) # parallel animations
	
	# Fade out
	tween.tween_property(bottom_panel, "modulate:a", 0.0, fade_duration)
	tween.tween_property(play_button, "modulate:a", 0.0, fade_duration)
	
	tween.finished.connect(_make_elements_invisible, CONNECT_ONE_SHOT)
	
	
# Fade in animation
func fade_in_elements():
	if tween:
		tween.kill()
	
	# we make the elements "visible"
	is_control_visible = true
		
	bottom_panel.visible = true
	play_button.visible = true
	
	# tween creation
	tween = create_tween()
	tween.set_parallel(true) # parallel aniimations
	
	# Fade in
	tween.tween_property(bottom_panel, "modulate:a", 1.0, fade_duration)
	tween.tween_property(play_button, "modulate:a", 1.0, fade_duration)
	
	tween.finished.connect(_make_elements_visible, CONNECT_ONE_SHOT)
	
	start_hide_timer()
	
func _make_elements_invisible():
	bottom_panel.visible = false
	play_button.visible = false
	
	bottom_panel.modulate.a = 0.0
	play_button.modulate.a = 0.0
	
	is_control_visible = false

func _make_elements_visible():
	bottom_panel.visible = true
	play_button.visible = true
	
	bottom_panel.modulate.a = 1.0
	play_button.modulate.a = 1.0
	
	is_control_visible = true
	
# on timeout the elements disappear
func _on_timer_timeout():
	fade_out_elements()

func _on_viewport_input(event: InputEvent):
	
	
	if event is InputEventScreenTouch and event.pressed:
		_handle_touch_input()
	if event is InputEventScreenDrag and event.pressed:
		_make_elements_invisible()
	if event is InputEventMouseButton and event.pressed:
		_handle_touch_input()
	
		
		
# when there's a touch on the screen (mobile)
func _handle_touch_input():
	if not is_control_visible:
		# show with fade in
		fade_in_elements()
	else:
		# if they're already visible
		fade_out_elements()
