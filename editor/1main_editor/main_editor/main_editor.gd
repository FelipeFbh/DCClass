extends Control

@export var window_whiteboard: PackedScene

@export var file: String = ""
@onready var parse_class: ParseClassEditor = %ResourceClass
@onready var metadata: MetadataEditor = %Metadata
@onready var panel_control: PanelControl = %PanelControl
var _window_whiteboard: WindowWhiteboard

@onready var core_signals: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var editor_signals: EditorEventBus = Engine.get_singleton(&"EditorSignals")

func _enter_tree() -> void:
	Engine.register_singleton(&"EditorSignals", EditorEventBus.new())
	Engine.register_singleton(&"CoreSignals", CoreEventBus.new())

func _ready() -> void:
	editor_signals.request_detach.connect(_on_request_detach)
	metadata._setup_metadata_class(parse_class.class_index)
	panel_control._setup_parse_class(parse_class)


func _on_request_detach() -> void:
	if _window_whiteboard and is_instance_valid(_window_whiteboard):
		return
	
	_window_whiteboard = window_whiteboard.instantiate() as WindowWhiteboard
	_window_whiteboard.get_node("UI").context.parse_class = parse_class

	get_tree().root.add_child(_window_whiteboard)
	
	_window_whiteboard.close_requested.connect(_on_window_close_requested)
	

func _on_window_close_requested() -> void:
	if _window_whiteboard:
		_window_whiteboard.queue_free()
		_window_whiteboard = null
		core_signals.stop_widget.emit()
