class_name AudioWidget
extends Widget

@export var entity: AudioEntity
var audio: AudioStreamPlayer

signal termino

func init(_properties: Dictionary) -> void:
	#if !zip_file.file_exists(entity.audio_path):
	#	push_error("Audio file not found: " + entity.audio_path)
	#	return
	#var data := zip_file.read_file(entity.audio_path)
	var relative_path := entity.audio_path
	var audio_disk_path := dir_class.path_join(relative_path)
	if not FileAccess.file_exists(audio_disk_path):
		push_error("Audio file not found: " + audio_disk_path)
		return
	var f := FileAccess.open(audio_disk_path, FileAccess.READ)
	if f == null:
		push_error("No se pudo abrir: " + audio_disk_path)
		return
	var data := f.get_buffer(f.get_length())
	f.close()
	
	var packet_sequence := AudioStreamOggVorbis.load_from_buffer(data)
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.bus = &"AudioWidget"
	audio.stream = packet_sequence

func serialize() -> Dictionary:
	return entity.serialize()

func _ready():
	add_to_group(&"speed_scale_handler")


func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	var audio_current_playing = get_tree().get_nodes_in_group("audio_playing")
	
	if audio_current_playing.size() > 0:
		var sigs: Array[Signal] = [audio_current_playing[0].audio.finished, _bus_core.stop_widget]
		var state = SignalsCore.await_any_once(sigs)
		if !state._done:
			await state.completed
			if state._signal_source == _bus_core.stop_widget:
				return
	
	var sigs: Array[Signal] = [audio.finished, _bus_core.stop_widget]
	var state = SignalsCore.await_any_once(sigs)
	_bus_core.current_node_changed.emit(class_node)
	audio.play()
	
	add_to_group(&"audio_playing")
	add_to_group(&"widget_playing")
	emit_signal("termino")
	if !state._done:
		await state.completed
		reset()

func seek(_seek_time: float) -> void:
	var audio_current_playing = get_tree().get_nodes_in_group("audio_playing")
	
	if audio_current_playing.size() > 0:
		var sigs: Array[Signal] = [audio_current_playing[0].audio.finished, _bus_core.stop_widget]
		var state = SignalsCore.await_any_once(sigs)
		if !state._done:
			await state.completed
			if state._signal_source == _bus_core.stop_widget:
				return
	
	var sigs: Array[Signal] = [audio.finished, _bus_core.stop_widget]
	var state = SignalsCore.await_any_once(sigs)
	_bus_core.current_node_changed.emit(class_node)
	if is_zero_approx(_seek_time - compute_duration()):
		emit_signal("termino")
		return
	audio.play(_seek_time)
	add_to_group(&"audio_playing")
	add_to_group(&"widget_playing")
	emit_signal("termino")
	if !state._done:
		await state.completed
		reset()
	

func stop():
	reset()
	emit_signal("termino")


func reset():
	audio.stop()
	remove_from_group(&"audio_playing")
	remove_from_group(&"widget_playing")

func skip_to_end():
	reset()
	emit_signal("termino")


func _clear():
	pass

func set_speed_scale(_speed: float) -> void:
	audio.pitch_scale = _speed

## Returns the duration of the audio in seconds.
func compute_duration() -> float:
	return audio.stream.get_length()
