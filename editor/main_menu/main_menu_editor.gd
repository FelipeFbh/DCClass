extends Control

@export var editor_screen: PackedScene

@onready var btn_create_class: Button = %ButtonCreate
@onready var btn_load_class: Button = %ButtonLoad

func _ready():
	btn_create_class.pressed.connect(_create_class)
	btn_load_class.pressed.connect(_select_file)


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
	DisplayServer.file_dialog_show("Open File", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.dcc_class", "*.poodle", "*.zip"], _on_native_dialog_file_selected)

func _on_native_dialog_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if status == false:
		return
	var path := selected_paths[0]
	_on_file_selected(path)
#endregion

#region Process file
func _on_file_selected(path: String) -> void:
	if not path.ends_with(".dcc_class") and not path.ends_with(".poodle") and not path.ends_with(".zip"):
		printerr("Invalid file type: ", path)
		return
	PersistenceEditor.file_path = path
	print("Selected file: ", PersistenceEditor.file_path)
	
	get_tree().change_scene_to_packed(editor_screen)
#endregion

#region Create Class
# Default class for new classes
const DEFAULT_CLASS_PATH: String = "res://editor/utils/new_class.dcc_class"
func _create_class():
	PersistenceEditor.file_path = DEFAULT_CLASS_PATH
	print("Selected file: ", PersistenceEditor.file_path)
	
	get_tree().change_scene_to_packed(editor_screen)
#endregion
