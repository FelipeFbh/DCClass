@tool
# 1. class name: fill the class name
class_name AudioEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that holds the reference to an audio file

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export_file() var audio_path: String

# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_class_name() -> String:
	return "AudioEntity"

func get_editor_name() -> String:
	return "Audio: " + audio_path

func serialize() -> Dictionary:
	return {
		"entity_id": entity_id,
		"entity_type": get_class_name(),
		"audio_path": audio_path,
		"duration": duration
	}

func load_data(data: Dictionary) -> void:
	audio_path = data["audio_path"]
	duration = data["duration"]

func self_delete() -> void:
	var path_tmp: String = "user://tmp/class_editor/"

	if audio_path != "":
		DirAccess.remove_absolute(path_tmp + audio_path)
	audio_path = ""

func tmp_to_persistent() -> void:
	var path_tmp: String = "user://tmp/class_editor/"
	var path_audio : String = "resources/audio/"
	var path_persistent: String = path_audio + str(entity_id) + ".ogg"
	if audio_path != "":
		if FileAccess.file_exists(path_tmp + audio_path):
			DirAccess.copy_absolute(path_tmp + audio_path, path_tmp + path_persistent)
			audio_path = path_persistent
		else:
			push_error("Audio file does not exist: " + path_tmp + audio_path)

		
	audio_path = path_persistent

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
