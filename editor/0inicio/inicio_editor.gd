extends Control

@export var editor_screen: PackedScene

@onready var button_cargar_clase: Button = %ButtonCargar

func _ready():
	button_cargar_clase.pressed.connect(_select_file)

#region Select File

func _select_file():
	if OS.has_feature("android"):
		print("Android detected. Using Android file picker.")
		return
	if OS.has_feature("web"):
		print("Web detected. Using browser file picker.")
		return
	if DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG):
		_native_dialog()
		print("Native dialog support detected. Using native file picker.")
		return
	print("No custom dialog support detected. Using built-in file picker.")
#endregion

#region Native Seleccionando Archivo
func _native_dialog():
	DisplayServer.file_dialog_show("Open File", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.poodle", "*.zip"], _on_native_dialog_file_selected)

func _on_native_dialog_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if status == false:
		return
	var path := selected_paths[0]
	_on_file_selected(path)
#endregion

#region Process file
func _on_file_selected(path: String) -> void:
	if not path.ends_with(".poodle") and not path.ends_with(".zip"):
		printerr("Invalid file type: ", path)
		return
	PersistenceEditor.class_path = path
	print("Selected file: ", PersistenceEditor.class_path)
	
	get_tree().change_scene_to_packed(editor_screen)
#endregion
