class_name ClassWindowMobile
extends Control

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: MobileEventBus = Engine.get_singleton(&"MobileSignals")

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
	if !is_instance_valid(ClassUIMobile.context) or !is_instance_valid(ClassUIMobile.context.camera):
		return
	var value: float = ClassUIMobile.context.camera.zoom.x
	zoom_slider.set_value_no_signal(value)

func _zoom_slider_value_selected(value: float) -> void:
	if !is_instance_valid(ClassUIMobile.context) or !is_instance_valid(ClassUIMobile.context.camera):
		return
	ClassUIMobile.context.camera.user_controlled = true
	ClassUIMobile.context.camera.zoom = Vector2(value, value)

func _zoom_reset() -> void:
	if !is_instance_valid(ClassUIMobile.context) or !is_instance_valid(ClassUIMobile.context.camera):
		return
	var viewport_size := viewport.size
	var zoom := minf(viewport_size.x / slide_size.x, viewport_size.y / slide_size.y)
	ClassUIMobile.context.camera.interpolate_zoom(zoom)

#endregion

#region Time

@onready var time_slider: HSlider = %TimeSlider
@onready var current_time_label: Label = %CurrentTimeLabel
@onready var total_time_label: Label = %TotalTimeLabel

#endregion

#region Playback Controls

@onready var stop_button: Button = %StopButton
@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton

@onready var play_icon: Texture2D = get_theme_icon("play", stop_button.theme_type_variation)
@onready var pause_icon: Texture2D = get_theme_icon("pause", stop_button.theme_type_variation)

var is_stopped: bool = true
	
# Toggle playback stop button.
# If the button is pressed, it will toggle between playing and stopping.
# When playing, the visual widget will begin 
# When stopped, the current  visual widget will be stopped and show his final state.
func _toggle_playback_stop() -> void:
	if is_stopped:
		PersistenceMobile._epilog(PersistenceMobile.Status.PLAYING)
		_bus.seek_play.emit()
		return
	
	_bus_core.stop_widget.emit()
	get_tree().call_group(&"widget_playing", "stop")
	PersistenceMobile._epilog(PersistenceMobile.Status.STOPPED)
	
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

#region Volume Controls

@export var bus_name: String = "Master"
var volume_icons_texture: Texture2D = preload("res://assets/sprites/ui/sheet_white1x.png")
var bus_index: int

@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_button: TextureButton = %VolumeButton
@onready var no_vol_icon: Texture2D
@onready var vol_icon: Texture2D

var no_vol_region: Rect2 = Rect2(0,350,50,50)
var vol_region: Rect2 = Rect2(0,300,50,50)
var prev_vol: float = 0.5

# volume slider changes
func _volume_controls() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	
	var act_vol = AudioServer.get_bus_volume_db(bus_index)
	var act_vol_linear = db_to_linear(act_vol)
	
	volume_slider.value = act_vol_linear
	_update_volume_icon(act_vol_linear)
	
	volume_slider.value_changed.connect(_on_volume_changed)
	volume_button.pressed.connect(_toggle_mute)

# volume change signal
func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	_update_volume_icon(value)

# changing icon according to volume
func _update_volume_icon(volume: float):
	var region: Rect2
	
	if volume == 0:
		region = no_vol_region
	else:
		region = vol_region
		
	var texture = AtlasTexture.new()
	texture.atlas = volume_icons_texture
	texture.region = region
	
	volume_button.texture_normal = texture

# mutes the audio
func _toggle_mute():
	var act_vol = volume_slider.value
	
	if act_vol > 0:
		# save volume
		volume_slider.set_meta("prev_vol", act_vol)
		# mute
		volume_slider.value = 0
	else:
		# restore the volume
		var vol = volume_slider.get_meta("prev_vol", 0.5)
		volume_slider.value = vol
		
#endregion

#region Recenter

@onready var center_camera_button: Button = %RecenterCameraButton

func _toggle_camera_button(user_controlled_camera: bool) -> void:
	center_camera_button.visible = user_controlled_camera

#endregion

@onready var control_panel: ControlPanelMobile = %"Control Panel"

func _setup():
	control_panel._setup()

func _ready():
	if !is_instance_valid(ClassUIMobile.context):
		printerr("ClassUIMobile context is not valid")
	else:
		get_tree().process_frame.connect(_zoom_reset, CONNECT_ONE_SHOT)
		
	stop_button.pressed.connect(_toggle_playback_stop)
	_bus.disabled_toggle_stop_button.connect(_disabled_toggle_stop_button)
	_bus.status_playback_stop.connect(_status_playback_stop)
	
	center_camera_button.pressed.connect(func (): ClassUIMobile.context.camera.user_controlled = false)
	
	zoom_slider.value_changed.connect(_zoom_slider_value_selected)
	zoom_button.pressed.connect(_zoom_reset)
	
	_volume_controls()
	

func _process(_delta: float):
	_update_zoom_slider_value()
