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
func _status_playback_stop(active : bool = is_stopped ) -> void:
	is_stopped = active
	if is_stopped:
		stop_button.icon = play_icon
		return
	stop_button.icon = pause_icon

# To disable the stop button.
func _disabled_toggle_stop_button(active: bool) -> void:
	stop_button.disabled = active


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

func _process(_delta: float):
	_update_zoom_slider_value()
