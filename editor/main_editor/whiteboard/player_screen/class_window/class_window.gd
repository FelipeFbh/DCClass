class_name ClassWindowEditor
extends Control

var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

#region Whiteboard

@onready var viewport: SubViewport = %SubViewport

# This set the node that will be used as the main node for the whiteboard.
# In this case, it is "visual_widgets" node.
func set_class_node(node: Node) -> void:
	node.reparent(viewport)
#endregion

#region Camera Zoom

@onready var zoom_slider: HSlider = %ZoomSlider
@onready var zoom_button: TextureButton = %ZoomButton
@onready var slide_size: Vector2 = ProjectSettings.get_setting("display/whiteboard/size") as Vector2

func _update_zoom_slider_value() -> void:
	if !is_instance_valid(ClassUIEditor.context) or !is_instance_valid(ClassUIEditor.context.camera):
		return
	var value: float = ClassUIEditor.context.camera.zoom.x
	zoom_slider.set_value_no_signal(value)

func _zoom_slider_value_selected(value: float) -> void:
	if !is_instance_valid(ClassUIEditor.context) or !is_instance_valid(ClassUIEditor.context.camera):
		return
	ClassUIEditor.context.camera.zoom = Vector2(value, value)
	ClassUIEditor.context.camera.update_grid_visibility()

func _zoom_reset() -> void:
	if !is_instance_valid(ClassUIEditor.context) or !is_instance_valid(ClassUIEditor.context.camera):
		return
	var viewport_size := viewport.size
	var zoom := minf(viewport_size.x / slide_size.x, viewport_size.y / slide_size.y)
	ClassUIEditor.context.camera.interpolate_zoom(zoom)

#endregion

#region Playback Controls

@onready var stop_button: Button = %StopButton

@onready var play_icon: Texture2D = get_theme_icon("play", stop_button.theme_type_variation)
@onready var pause_icon: Texture2D = get_theme_icon("pause", stop_button.theme_type_variation)

var is_stopped: bool = true

# Toggle playback stop button.
# If the button is pressed, it will toggle between playing and stopping.
# When playing, the visual widget will begin 
# When stopped, the current  visual widget will be stopped and show his final state.
func _toggle_playback_stop() -> void:
	if is_stopped:
		PersistenceEditor._epilog(PersistenceEditor.Status.PLAYING)
		_bus.seek_play.emit()
		return
	
	_bus_core.stop_widget.emit()
	get_tree().call_group(&"widget_playing", "stop")
	PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)

# 0: playing, 1: stopped
# This is used to update the stup_button icon/state.
func _status_playback_stop(active: bool = is_stopped) -> void:
	is_stopped = active
	if is_stopped:
		stop_button.icon = play_icon
		return
	stop_button.icon = pause_icon

# To disable the stop button.
func _disabled_toggle_stop_button(active: bool) -> void:
	stop_button.disabled = active


#endregion

#region Timeline
@onready var label_time_current: Label = %TimeCurrent
@onready var time_slider: HSlider = %TimeSlider
@onready var debouncer_timer: Timer = %DebouncerTimer

var current_time: float
var final_time: float
var final_time_str: String

var time_slider_drag: bool = false
var was_playing: bool = false


# Setup the time slider and label based on the complete duration of the class.
func _setup_timeline():
	final_time = PersistenceEditor.resources_class.root_tree_structure._node_controller._compute_class_duration()
	time_slider.max_value = final_time
	time_slider.value = 0.0

	var sec_ftotal = final_time
	var sec_f = fmod(final_time, 60)
	var min_ftotal = sec_ftotal / 60
	var min_f = fmod(min_ftotal, 60)
	var hour_f = min_ftotal / 60
	
	var format_str = "%02d : %02d : %02d"

	time_slider.value = current_time
	var sec_total = current_time
	var sec_c = fmod(current_time, 60)
	var min_total = sec_total / 60
	var min_c = fmod(min_total, 60)
	var hour_c = min_total / 60
	var current_time_str = format_str % [hour_c, min_c, sec_c]

	final_time_str = format_str % [hour_f, min_f, sec_f]
	
	label_time_current.text = current_time_str + " / " + final_time_str

# Update the time slider and label based on the current time.
func _update_time_control():
	time_slider.value = current_time
	var sec_total = current_time
	var sec_c = fmod(current_time, 60)
	var min_total = sec_total / 60
	var min_c = fmod(min_total, 60)
	var hour_c = min_total / 60

	var format_str = "%02d : %02d : %02d"
	var current_time_str = format_str % [hour_c, min_c, sec_c]
	
	label_time_current.text = current_time_str + " / " + final_time_str

# Seek the time slider by the current node given.
func _seek_time_slide(_current_node: ClassNode):
	current_time = PersistenceEditor.resources_class.root_tree_structure._node_controller._compute_current_time(_current_node._node_controller)
	_update_time_control()

# Begin to drag the time slider.
func _on_time_slider_drag_started() -> void:
	time_slider_drag = true
	if PersistenceEditor._status == PersistenceEditor.Status.PLAYING:
		was_playing = true
	else:
		was_playing = false
	_bus_core.stop_widget.emit()
	get_tree().call_group(&"widget_playing", "stop")
	PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)

# Ended to drag the time slider.
func _on_time_slider_drag_ended(value_changed: bool) -> void:
	time_slider_drag = false
	debouncer_timer.start()
	await debouncer_timer.timeout
	if was_playing:
		PersistenceEditor._epilog(PersistenceEditor.Status.PLAYING)
		_bus.seek_play.emit()
		return

# When the value changed of the time slider, we update the class by the current time.
func _on_time_slider_value_changed(value: float) -> void:
	# We use a debouncer timer to avoid too many updates while dragging.
	if time_slider_drag:
		debouncer_timer.start()

# Trigger when the debouncer timer timeout.
func _on_debouncer_timer_timeout() -> void:
	_update_timer_slider_by_time()

# Update the timer slider and the current node by the time slider value.
func _update_timer_slider_by_time():
	var seeked_node: NodeController = PersistenceEditor.resources_class.root_tree_structure._node_controller._seek_node_time(time_slider.value)
	_bus_core.current_node_changed.emit(seeked_node._class_node)
	_bus.seek_node.emit(seeked_node._class_node)
	if !time_slider_drag:
		_seek_time_slide(PersistenceEditor.resources_class._current_node)

#endregion


func _ready():
	if !is_instance_valid(ClassUIEditor.context):
		printerr("ClassUIEditor context is not valid")
	else:
		get_tree().process_frame.connect(_zoom_reset, CONNECT_ONE_SHOT)
	
	stop_button.pressed.connect(_toggle_playback_stop)
	
	_bus.disabled_toggle_stop_button.connect(_disabled_toggle_stop_button)
	_bus.status_playback_stop.connect(_status_playback_stop)
	
	zoom_slider.value_changed.connect(_zoom_slider_value_selected)
	zoom_button.pressed.connect(_zoom_reset)
	
	_setup_timeline()
	_bus.setup_timeline.connect(_setup_timeline)
	_bus.seek_time_slide.connect(_seek_time_slide)
	
	
	time_slider.drag_started.connect(_on_time_slider_drag_started)
	time_slider.value_changed.connect(_on_time_slider_value_changed)
	debouncer_timer.timeout.connect(_on_debouncer_timer_timeout)
	time_slider.drag_ended.connect(_on_time_slider_drag_ended)
	
	_bus.update_timer_slider_by_time.connect(_update_timer_slider_by_time)
	

func _process(_delta: float):
	_update_zoom_slider_value()
	if !is_stopped:
		current_time += _delta
		if current_time >= final_time:
			current_time = final_time
		_update_time_control()
