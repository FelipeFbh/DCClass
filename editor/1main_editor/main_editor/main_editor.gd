extends Control

@export var file: String = ""
@onready var parse_class: ParseClassEditor = $ParseClass
@onready var metadata : MetadataEditor = %Metadata
@onready var panel_control: PanelControl = %PanelControl
var current_window: WindowWhiteboard

@onready var editor_signals: EditorEventBus = Engine.get_singleton(&"EditorSignals")

func _enter_tree() -> void:
	Engine.register_singleton(&"EditorSignals", EditorEventBus.new())
	Engine.register_singleton(&"CoreSignals", CoreEventBus.new())

func _ready() -> void:
	editor_signals.request_detach.connect(_on_request_detach)
	metadata._setup_metadata_class(parse_class.class_index)
	panel_control._setup_parse_class(parse_class)




func _on_request_detach() -> void:
	if current_window and is_instance_valid(current_window):
		current_window.popup_centered()
		return

	var detach_scene: PackedScene = panel_control.detach_window
	
	current_window = detach_scene.instantiate() as WindowWhiteboard
	#current_window.get_node("UI").get_node("PlayClass").parse_class = parse_class
	current_window.get_node("UI").context.parse_class = parse_class

	get_tree().root.add_child(current_window)
	current_window.close_requested.connect(_on_window_close_requested)
	current_window.popup_centered()
	

func _on_window_close_requested() -> void:
	if current_window:
		current_window.queue_free()
		current_window = null
