class_name ClassAudioRecord
extends Node


var parse_class: ParseClassEditor
@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

var record_effect : AudioEffectRecord = AudioServer.get_bus_effect(AudioServer.get_bus_index("ClassRecord"), 0)
var record_data : AudioStreamWAV

@onready var mic_stream := $AudioRecordStream


func record() -> void:
	if record_effect.is_recording_active():
		record_effect.set_recording_active(false)
		record_data = record_effect.get_recording()
		#mic_stream.stop()
		save_recording(record_data)

	else:
		record_data = null
		#if not mic_stream.playing:
			#mic_stream.play()
		record_effect.set_recording_active(true)

func play_recording() -> void:
	var new_audiostream = AudioStreamPlayer.new()
	new_audiostream.stream = record_data
	add_child(new_audiostream)

func save_recording(_record_data : AudioStreamWAV) -> void:
	var path_tmp: String = "user://tmp/class_editor/"
	var path_audio = "resources/audio/"
	var index_new_entity = parse_class.entities.size()

	var path_wav = path_tmp + path_audio + str(index_new_entity) + ".wav"
	_record_data.save_to_wav(path_wav)
	var path_ogg = path_tmp + path_audio + str(index_new_entity) + ".ogg"
	
	var absolute_path_wav = ProjectSettings.globalize_path(path_wav)
	var absolute_path_ogg = ProjectSettings.globalize_path(path_ogg)
	
	var args = ["-y", "-i", absolute_path_wav, "-c:a", "libvorbis", absolute_path_ogg]
	var exit_code = OS.execute("ffmpeg", args, [], false, false)
	if exit_code != 0:
		push_error("FFmpeg Error: %d" % exit_code)

	
	DirAccess.remove_absolute(absolute_path_wav)
	
	var new_data = {
		"audio_path": path_audio + str(index_new_entity) + ".ogg",
		"duration": _record_data.get_length()
	}
	var new_audio_entity = AudioEntity.new()
	new_audio_entity.load_data(new_data)
	
	var new_entity_properties = []
	_bus.emit_signal("add_class_leaf_entity", new_audio_entity, new_entity_properties)
