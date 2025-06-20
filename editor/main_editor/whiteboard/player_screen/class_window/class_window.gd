class_name ConceptClassWindowEditor
extends Control

var find_group_by_timestamp: Callable
var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")


#region Index Tree
@onready var index_tree_parent: Control = %LeftPanel

func set_index_tree(tree: Tree) -> void:
	index_tree_parent.add_child(tree)
	%LeftSplit.split_offset = tree.size.x + 10
	tree.scroll_horizontal_enabled = true
#endregion

#region Whiteboard

@onready var viewport: SubViewport = %SubViewport

func set_class_node(node: Node) -> void:
	node.reparent(viewport)

#endregion

#region Playback
@onready var current_time_label: Label = %CurrentTimeLabel
@onready var time_slider: PlayerSliderEditor = %TimeSlider
@onready var total_time_label: Label = %TotalTimeLabel
@onready var stopwatch: StopwatchEditor = %Stopwatch

func set_total_time(total_time: int) -> void:
	var total_time_string := _get_time_string(total_time)
	total_time_label.text = total_time_string
	time_slider.max_value = floorf(total_time)

func _get_time_string(time: int) -> String:
	var minutes := time / 60
	var seconds := time % 60
	return str(minutes).lpad(2, "0") + ":" + str(seconds).lpad(2, "0")
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

@onready var play_button: Button = %PlayPauseButton

@onready var stop_button: Button = %StopButton
@onready var play_icon: Texture2D = get_theme_icon("play", stop_button.theme_type_variation)
@onready var pause_icon: Texture2D = get_theme_icon("pause", stop_button.theme_type_variation)

var is_stopped: bool = true

func _toggle_playback_stop() -> void:
	if is_stopped:
		PersistenceEditor._epilog(PersistenceEditor.Status.PLAYING)
		_bus.seek_play.emit()
		return
	
	_bus_core.stop_widget.emit()
	get_tree().call_group(&"widget_playing", "stop")
	PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)

func _status_playback_stop(active : bool = is_stopped ) -> void:
	is_stopped = active
	if is_stopped:
		stop_button.icon = pause_icon
		return
	stop_button.icon = play_icon


func _tree_play_finished():
	is_stopped = true
	stop_button.icon = pause_icon


func _disabled_toggle_stop_button(active: bool) -> void:
	stop_button.disabled = active


#endregion

#region Speed Controls

@onready var speed_slider: HSlider = %SpeedSlider
@onready var speed_button: TextureButton = %SpeedButton
@onready var pitch_shift: AudioEffectPitchShift = AudioServer.get_bus_effect(AudioServer.get_bus_index(&"AudioWidget"), 0)

func _speed_slider_value_selected(value: float) -> void:
	Engine.time_scale = value
	get_tree().call_group(&"speed_scale_handler", &"set_speed_scale", value)
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index(&"AudioWidget"), 0, not is_equal_approx(value, 1.0))
	pitch_shift.pitch_scale = 1.0 / value

#endregion

#region UI

@onready var fullscreen_button: Button = %FullscreenButton
@onready var center_camera_button: Button = %RecenterCameraButton
@onready var enter_fullscreen_icon: Texture2D = get_theme_icon("enter", fullscreen_button.theme_type_variation)
@onready var exit_fullscreen_icon: Texture2D = get_theme_icon("exit", fullscreen_button.theme_type_variation)
@onready var panels: Array[Control] = [%LeftPanel, %BottomPanel, %RightPanel]
@onready var panel_visible: Array[bool] = [panels[0].visible, panels[1].visible, panels[2].visible]

func _toggle_fullscreen(toggled_on: bool) -> void:
	for i in panels.size():
		panels[i].visible = not toggled_on and panel_visible[i]
	fullscreen_button.icon = exit_fullscreen_icon if toggled_on else enter_fullscreen_icon
	if !is_instance_valid(ClassUIEditor.context) or !is_instance_valid(ClassUIEditor.context.camera): return
	if ClassUIEditor.context.camera.user_controlled: return
	call_deferred(&"_zoom_reset")

func _toggle_camera_button(user_controlled_camera: bool) -> void:
	center_camera_button.visible = user_controlled_camera

#endregion

#region Mod Tabs

@onready var mod_tabs: TabContainer = %ModTabContainer
@onready var right_panel: PanelContainer = %RightPanel

func setup_mods() -> void:
	if add_mod_tabs():
		right_panel.show()
		mod_tabs.current_tab = 1
		right_panel.size.x = 300
		panel_visible[2] = true
	mod_tabs.set_tab_hidden(0, true)

func add_mod_tabs() -> int:
	var tab_idx: int = 0
	for mod in ModLoader.mods_loaded:
		for scene in mod.player_scenes:
			var instance = scene.instantiate()
			if !is_instance_valid(instance):
				continue
			mod_tabs.add_child(instance)
			tab_idx += 1
			# mod_tabs.set_tab_hidden(tab_idx, true)
	return tab_idx

#endregion

func _ready():
	if !is_instance_valid(ClassUIEditor.context):
		printerr("ClassUIEditor context is not valid")
	else:
		ClassUIEditor.context.stopwatch = stopwatch
		ClassUIEditor.context.camera.user_controlled_changed.connect(_toggle_camera_button)
		get_tree().process_frame.connect(_zoom_reset, CONNECT_ONE_SHOT)
	fullscreen_button.toggled.connect(_toggle_fullscreen)
	center_camera_button.pressed.connect(func(): ClassUIEditor.context.camera.user_controlled = false)
	
	#play_button.pressed.connect(_toggle_playback)
	stop_button.pressed.connect(_toggle_playback_stop)
	_bus_core.tree_play_finished.connect(_tree_play_finished)
	_bus.disabled_toggle_stop_button.connect(_disabled_toggle_stop_button)
	_bus.status_playback_stop.connect(_status_playback_stop)
	

	#time_slider.value_selected.connect(_slider_value_selected)
	zoom_slider.value_changed.connect(_zoom_slider_value_selected)
	zoom_button.pressed.connect(_zoom_reset)
	speed_button.pressed.connect(func(): speed_slider.value = 1.0)
	speed_slider.value_changed.connect(_speed_slider_value_selected)

func _process(_delta: float):
	#time_slider.change_value(stopwatch.running_time)
	#current_time_label.text = _get_time_string(floori(stopwatch.running_time))
	_update_zoom_slider_value()
