class_name AudioWidget
extends Widget

@export var entity: AudioEntity
var audio: AudioStreamPlayer


func init(_properties: Dictionary) -> void:
	var data
	
	# Case: Keep data in the .dcc file
	# This is intended to be used only for reproducing the class.
	if zip_file != null:
		if !zip_file.file_exists(entity.audio_path):
			push_error("Audio file not found: " + entity.audio_path)
			return
		data = zip_file.read_file(entity.audio_path)
		
	# Case: Decompress the .dcc file
	# This is intended to be used only for editing the class.
	else:
		var relative_path: String = entity.audio_path
		var audio_disk_path: String = dir_class.path_join(relative_path)
		if not FileAccess.file_exists(audio_disk_path):
			push_error("Audio file not found: " + audio_disk_path)
			return
		var f := FileAccess.open(audio_disk_path, FileAccess.READ)
		if f == null:
			push_error("No se pudo abrir: " + audio_disk_path)
			return
		data = f.get_buffer(f.get_length())
		f.close()
	
	var packet_sequence := AudioStreamOggVorbis.load_from_buffer(data)
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.bus = &"AudioWidget"
	audio.stream = packet_sequence

# Serialize to a dictionary format(.json) for saving.
func serialize() -> Dictionary:
	return entity.serialize()

func _ready():
	add_to_group(&"speed_scale_handler")

# Play the audio file.
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	# Check if another audio is playing to wait for it to finish
	var audio_current_playing = get_tree().get_nodes_in_group("audio_playing")
	
	if audio_current_playing.size() > 0:
		var sigs: Array[Signal] = [audio_current_playing[0].audio.finished, _bus_core.stop_widget]
		var state = SignalsCore.await_any_once(sigs)
		if !state._done:
			await state.completed
			if state._signal_source == _bus_core.stop_widget:
				return
	
	# Now play this audio
	var sigs: Array[Signal] = [audio.finished, _bus_core.stop_widget]
	var state = SignalsCore.await_any_once(sigs)
	_bus_core.current_node_changed.emit(class_node)
	audio.play()
	
	add_to_group(&"audio_playing")
	add_to_group(&"widget_playing")
	emit_signal("widget_finished")
	if !state._done:
		await state.completed
		reset()

# Play the audio file from a specific time.
func seek_and_play(_seek_time: float) -> void:
	# Check if another audio is playing to wait for it to finish
	var audio_current_playing = get_tree().get_nodes_in_group("audio_playing")
	
	if audio_current_playing.size() > 0:
		var sigs: Array[Signal] = [audio_current_playing[0].audio.finished, _bus_core.stop_widget]
		var state = SignalsCore.await_any_once(sigs)
		if !state._done:
			await state.completed
			if state._signal_source == _bus_core.stop_widget:
				return
	
	# Now play this audio
	var sigs: Array[Signal] = [audio.finished, _bus_core.stop_widget]
	var state = SignalsCore.await_any_once(sigs)
	_bus_core.current_node_changed.emit(class_node)
	# Border case: if the seek time is zero or the audio is already at the end, we finish immediately to avoid unnecessary courutines problems.
	if is_zero_approx(_seek_time - compute_duration()):
		emit_signal("widget_finished")
		return
	audio.play(_seek_time)
	add_to_group(&"audio_playing")
	add_to_group(&"widget_playing")
	emit_signal("widget_finished")
	if !state._done:
		await state.completed
		reset()
	

# Stop the audio.
func stop():
	reset()
	emit_signal("widget_finished")

# Reset the audio player. This mean set to the initial state and remove from playing groups.
func reset():
	audio.stop()
	remove_from_group(&"audio_playing")
	remove_from_group(&"widget_playing")

# Skip to the end of the audio.
func skip_to_end():
	reset()
	emit_signal("widget_finished")


func _clear():
	pass

func set_speed_scale(_speed: float) -> void:
	audio.pitch_scale = _speed

## Returns the duration of the audio in seconds.
func compute_duration() -> float:
	return audio.stream.get_length()
