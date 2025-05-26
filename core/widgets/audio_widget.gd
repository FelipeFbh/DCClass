class_name AudioWidget
extends Widget

@export var entity: AudioEntity
var audio: AudioStreamPlayer

signal termino


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

func _ready():
	_bus_core.clear_widget.connect(_clear)
	add_to_group(&"speed_scale_handler")


func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	var sigs: Array[Signal] = [audio.finished, _bus_core.stop_widget]
	var state = SignalsCore.await_any_once(sigs)
	audio.play()
	add_to_group(&"widget_playing")
	emit_signal("termino")
	if !state._done:
		await state.completed
		stop()
		remove_from_group(&"widget_playing")


func is_audio() -> bool:
	return true

func stop():
	audio.stop()

func reset():
	audio.stop()

func skip_to_end():
	reset()


func _clear():
	pass

func set_speed_scale(_speed: float) -> void:
	audio.pitch_scale = _speed

## Returns the duration of the audio in seconds.
func compute_duration() -> float:
	return audio.stream.get_length()
