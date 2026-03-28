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
@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton
@onready var volume_button: TextureButton = %VolumeButton
@onready var volume_slider: HSlider = %VolumeSlider
@onready var recenter: Button = %RecenterCameraButton
@onready var go_back: Button = %GoBackButton

@onready var whiteboard: Control = %Whiteboard

var hover_elements = [bottom_panel, play_button, next_button, prev_button, go_back, volume_button, volume_slider, recenter]
var is_control_visible: bool = true
var is_mouse_over: bool = false

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
	# alpha color channel set to fully visible
	bottom_panel.modulate.a = 1.0
	play_button.modulate.a = 1.0
	
	if auto_start:
		start_hide_timer()
		
	# handles the inputs over the whiteboard
	whiteboard.gui_input.connect(_on_viewport_input)
	
	# handles hovering over a set of elements
	_setup_hover_detection(hover_elements)

func _setup_hover_detection(hover_on: Array):
	for element in hover_on:
		if (element):
			element.mouse_entered.connect(_on_element_mouse_entered)
			element.mouse_exited.connect(_on_element_mouse_exited)

# mouse on an element
func _on_element_mouse_entered():
	is_mouse_over = true
	reset_hide_timer()

# mouse out of an element
func _on_element_mouse_exited():
	is_mouse_over = false
	
	if is_control_visible: 
		start_hide_timer()

# resumes the timer
func start_hide_timer():
	if hide_timer and is_control_visible and not is_mouse_over:
		hide_timer.start()

# restart/stops the timer
func reset_hide_timer():
	if hide_timer:
		hide_timer.stop()
		if is_control_visible:
			hide_timer.start()
	
# Fade out animation of the control panel
func fade_out_elements():
	if tween:
		tween.kill()
	
	# we make the elements "visible"
	is_control_visible = false
	
	tween = create_tween()
	tween.set_parallel(true) # parallel animations
	
	# Fade out animation
	tween.tween_property(bottom_panel, "modulate:a", 0.0, fade_duration)
	tween.tween_property(play_button, "modulate:a", 0.0, fade_duration)
	tween.tween_property(prev_button, "modulate:a", 0.0, fade_duration)
	tween.tween_property(next_button, "modulate:a", 0.0, fade_duration)
	tween.tween_property(go_back, "modulate:a", 0.0, fade_duration)
	tween.tween_property(recenter, "modulate:a", 0.0, fade_duration)
	
	tween.finished.connect(_make_elements_invisible, CONNECT_ONE_SHOT)
	
	
# Fade in animation of the control panel
func fade_in_elements():
	if tween:
		tween.kill()
	
	# we make the elements "visible"
	is_control_visible = true
		
	bottom_panel.visible = true
	play_button.visible = true
	prev_button.visible = true
	next_button.visible = true
	recenter.visible = true
	go_back.visible = true
	
	# tween creation
	tween = create_tween()
	tween.set_parallel(true) # parallel aniimations
	
	# Fade in animation
	tween.tween_property(bottom_panel, "modulate:a", 1.0, fade_duration)
	tween.tween_property(play_button, "modulate:a", 1.0, fade_duration)
	tween.tween_property(prev_button, "modulate:a", 1.0, fade_duration)
	tween.tween_property(next_button, "modulate:a", 1.0, fade_duration)
	tween.tween_property(go_back, "modulate:a", 1.0, fade_duration)
	tween.tween_property(recenter, "modulate:a", 1.0, fade_duration)
	
	tween.finished.connect(_make_elements_visible, CONNECT_ONE_SHOT)
	
	start_hide_timer()
	
# Makes elements invisible
func _make_elements_invisible():
	bottom_panel.visible = false
	play_button.visible = false
	prev_button.visible = false
	next_button.visible = false
	recenter.visible = false
	go_back.visible = false
	
	bottom_panel.modulate.a = 0.0
	play_button.modulate.a = 0.0
	prev_button.modulate.a = 0.0
	next_button.modulate.a = 0.0
	recenter.modulate.a = 0.0
	go_back.modulate.a = 0.0
	
	is_control_visible = false

# Make elements visible
func _make_elements_visible():
	bottom_panel.visible = true
	play_button.visible = true
	prev_button.visible = true
	next_button.visible = true
	recenter.visible = true
	go_back.visible = true
	
	bottom_panel.modulate.a = 1.0
	play_button.modulate.a = 1.0
	prev_button.modulate.a = 1.0
	next_button.modulate.a = 1.0
	recenter.modulate.a = 1.0
	go_back.modulate.a = 1.0
	
	is_control_visible = true
	
# on timeout the elements disappear
func _on_timer_timeout():
	fade_out_elements()

# handles the types of inputs available
func _on_viewport_input(event: InputEvent):
	# screen touch (mobile)
	if event is InputEventScreenTouch and event.pressed:
		_handle_input()
	# screen drag (mobile)
	if event is InputEventScreenDrag:
		_make_elements_invisible()
	# screen click (desktop)
	if event is InputEventMouseButton and event.pressed:
		_handle_input()
		
# handles the input according to panel visibility
func _handle_input():
	if not is_control_visible:
		# show with fade in
		fade_in_elements()
	else:
		# if they're already visible
		reset_hide_timer()
