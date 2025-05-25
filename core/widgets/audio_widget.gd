class_name AudioWidget
extends Widget

@export var entity: AudioEntity
var audio: AudioStreamPlayer

func init(_properties: Dictionary) -> void:
	if !zip_file.file_exists(entity.audio_path):
		push_error("Audio file not found: " + entity.audio_path)
		return
	var data := zip_file.read_file(entity.audio_path)
	var packet_sequence := AudioStreamOggVorbis.load_from_buffer(data)
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.bus = &"AudioWidget"
	audio.stream = packet_sequence

func serialize() -> Dictionary:
	return entity.serialize()
	

signal termino
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	audio.play()
	emit_signal("termino")



func is_audio() -> bool:
	return true

func reset():
	audio.stop()

func skip_to_end():
	reset()

func _ready():
	_bus_core.clear_widget.connect(_clear)
	add_to_group(&"speed_scale_handler")

func _clear():
	pass

func set_speed_scale(_speed: float) -> void:
	audio.pitch_scale = _speed

## Returns the duration of the audio in seconds.
func compute_duration() -> float:
	return audio.stream.get_length()
