# main_editor.gd
extends Control

@export var file: String = ""  

@onready var panel_control: PanelControl = %PanelControl
var current_window: Window

var parser = preload("res://editor/utils/parse.gd").new()
var editor_signals: EditorEventBus

func _enter_tree() -> void:
	Engine.register_singleton("EditorSignals", EditorEventBus.new())
	editor_signals = Engine.get_singleton("EditorSignals") as EditorEventBus

func _ready() -> void:
	editor_signals.request_detach.connect(_on_request_detach)
	#_run_parser()

func _run_parser() -> void:
	parser.file = file if file != "" else PersistenceEditor.clase_path

	if not parser.parse_persistence():
		push_error("Error al parsear el archivo de persistencia.")
		return

	editor_signals.class_index_changed.emit(parser.class_index)

	var content_node: Node2D = parser.instantiate_content()




func _on_request_detach() -> void:
	if current_window and is_instance_valid(current_window):
		current_window.popup_centered()
		return

	var detach_scene: PackedScene = panel_control.detach_window
	if detach_scene == null:
		push_error("No se asignó ‘detach_window’ en el Inspector de PanelControl.")
		return

	current_window = detach_scene.instantiate() as Window
	get_tree().root.add_child(current_window)
	current_window.close_requested.connect(_on_window_close_requested)
	current_window.popup_centered()

func _on_window_close_requested() -> void:
	if current_window:
		current_window.queue_free()
		current_window = null
