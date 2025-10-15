class_name Widget
extends Node2D


## A widget is a visual element that can be played and reset.
## This class defines the main API for a widget.

## The ZIP file containing the widget assets.
## Use [method ZIPReader.file_exists] to check if a file exists in the ZIP file.
## Use [method ZIPReader.read_file] to get a file from the ZIP file.
static var zip_file: ZIPReader
static var pen_color: Color = Color.WHITE
static var pen_thickness: float = 2.0
static var cam_pos: Vector2 = Vector2.ZERO

# Dir class is the temporary directory where the widget assets are stored. Ex: Audio, Images, etc.
static var dir_class: String

# Selection area for visual nodes that can be selected on whiteborard
var selection_area: SelectionArea

# Bus to manage core signals.
@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")

# The class node that this widget belongs to.
var class_node: ClassNode

# The signal to emit when the widget is finished.
signal widget_finished


## Compute the duration of the widget animation.
func compute_duration() -> float:
	return 0.0

## Called when the node enters the scene tree for the first time.
## It is a good place to initialize the node with the entity's properties
## and instantiate any children.
##
## Custom [param properties] are passed as a dictionary.
func init(_properties: Dictionary) -> void:
	pass

## Called when it's time to play the widget.
## The animation should be played for the given [param duration].
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	pass


## Called when it's time to play the widget and the widget is the first after a seek.
## This is useful to play the current leaf when to current node is a pause. So we omit that pause.
## The animation should be played for the given [param duration].
func play_seek(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	play(_duration, _total_real_time, _duration_leaf)

## Called when the player seeked to a point before the widget was played.
## The widget should be reset to its initial state.
func reset() -> void:
	pass

func stop() -> void:
	pass

## Called when the player seeked to a point after the widget was played.
## The widget should be set to its final state.
func skip_to_end() -> void:
	pass

## Set the speed scale of the widget.
## The [param speed] scale is a multiplier that affects the speed of the widget.
## A speed scale of 1.0 means the widget will play at its normal speed.
func set_speed_scale(_speed: float) -> void:
	pass

## Reset the speed scale of the widget to 1.0.
func reset_speed_scale() -> void:
	set_speed_scale(1.0)

## Delete the widget and renew the visual slide.
func clear():
	pass

## Unclear the widget (useful for visual state restoration)
func unclear():
	pass

## Get bounds as a Rect2 if is a visual widget, return empty Rect otherwise
func get_rect_bound() -> Rect2:
	return Rect2()
	
## Setup selection area for widget inside widget bounds
func _setup_selection_area():
	var rect = get_rect_bound()
	if rect.size != Vector2.ZERO:
		selection_area = SelectionArea.new()
		add_child(selection_area)
		selection_area.setup_for_widget(self, class_node)
		selection_area.widget_selected.connect(_on_widget_selected)

func _on_widget_selected(node: ClassNode, selected: bool):
	# Emitir la señal al sistema de control
	if _bus_core:
		_bus_core.current_node_changed.emit(node)
