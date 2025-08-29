extends VSplitContainer

# time that indicates on how many seconds the bottom panel hides
@export var hide_delay: float = 3.0
# fade duration
@export var fade_duration: float = 0.5
# indicates that the process is automatic
@export var auto_start: bool = true
# implementation for android
@export var show_on_tap: bool = true

# the elements that will hide from the user
@onready var whiteboard: VSplitContainer = %BottomSplit
@onready var bottom_panel: PanelContainer = %BottomPanel
@onready var play_button: Button = %StopButton

# counts the seconds to hide the bottom panel
var hide_timer: Timer
# Para detectar si el mouse/touch está sobre el panel
var is_mouse_over: bool = false

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
	
	# Desktop devices
	var is_desktop = not OS.has_feature("mobile") and not OS.has_feature("web")
	
	if is_desktop:
		whiteboard.mouse_entered.connect(_on_mouse_entered)
		whiteboard.mouse_exited.connect(_on_mouse_exited)
		bottom_panel.mouse_entered.connect(_on_mouse_entered)
		bottom_panel.mouse_exited.connect(_on_mouse_exited)
		play_button.mouse_entered.connect(_on_mouse_entered)
		play_button.mouse_exited.connect(_on_mouse_exited)

	
	var is_touch = OS.has_feature("mobile") or OS.has_feature("web")
	
	# For Android and touch devices
	if is_touch and show_on_tap:
		# Detectar toques en cualquier lugar de la pantalla
		if show_on_tap:
			get_viewport().gui_input.connect(_on_touch_input)
	
# resumes or restarts the timer
func start_hide_timer():
	if hide_timer and (bottom_panel.visible and play_button.visible):
		hide_timer.start()
	
# Fade out animation
func fade_out_elements():
	if tween:
		tween.kill()
	
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
	bottom_panel.visible = true
	play_button.visible = true
	
	# tween creation
	tween = create_tween()
	tween.set_parallel(true) # parallel aniimations
	
	# Fade in
	tween.tween_property(bottom_panel, "modulate:a", 1.0, fade_duration)
	tween.tween_property(play_button, "modulate:a", 1.0, fade_duration)
	
func _make_elements_invisible():
	bottom_panel.visible = false
	play_button.visible = false
	
	bottom_panel.modulate.a = 0.0
	play_button.modulate.a = 0.0
	
# on timeout the elements disappear
func _on_timer_timeout():
	fade_out_elements()

# when the mouse enters the timer stops
# and shows the elements again (desktop)
func _on_mouse_entered():
	is_mouse_over = true
	hide_timer.stop()
	fade_in_elements()

# when the mouse exists resumes the timer (desktop)
func _on_mouse_exited():
	is_mouse_over = false
	start_hide_timer()

# when there's a touch on the screen (mobile)
func _on_touch_input(event: InputEvent):
	if event is InputEventScreenTouch and event.pressed:
		if not (bottom_panel.visible and play_button.visible):
			# show with fade in
			fade_in_elements()
			start_hide_timer()
		else:
			# if they're already visible
			start_hide_timer()
