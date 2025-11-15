extends Node

var file_path: String

var core_signals: CoreEventBus
var editor_signals: EditorEventBus

var resources_class: ResourcesClassEditor
var clipboard: Array[ClassNode] = []

enum Status {
	STOPPED = 0,
	PLAYING = 1,
	RECORDING_PEN = 10,
	RECORDING_AUDIO = 11,
	RECORDING_DRAG = 100,
	RECORDING_RESIZE = 101
}

var _status: Status

enum Events {
	SEEK_PANEL = 51,
	SEEK_SLIDE_TIME = 52,
	EDIT_VISUALS = 101,
	EDIT_AUDIO = 102
}

func _setup():
	core_signals.tree_play_finished.connect(_tree_play_finished)
	core_signals.pause_playback_widget.connect(_pause_playback_widget)

func _tree_play_finished():
	_epilog(Status.STOPPED)

func _pause_playback_widget():
	_epilog(Status.STOPPED)

func _epilog_events(event: Events, params = []):

	if event == Events.SEEK_PANEL:
		editor_signals.seek_time_slide.emit(params[0])
	
	elif event == Events.EDIT_AUDIO:
		editor_signals.setup_timeline.emit()

# Update the status of the editor
func _epilog(status: Status = _status):
	_status = status
	if status == Status.STOPPED:
		_stopped()

	elif status == Status.PLAYING:
		_playing()

	elif status == Status.RECORDING_PEN:
		_recording_pen()

	elif status == Status.RECORDING_AUDIO:
		_recording_audio()

	elif status == Status.RECORDING_DRAG:
		_recording_drag()

	elif status == Status.RECORDING_RESIZE:
		_recording_resize()

func _stopped():
	editor_signals.disabled_toggle_audio_button.emit(false)
	editor_signals.disabled_toggle_pen_button.emit(false)
	editor_signals.disabled_toggle_audio_button.emit(false)
	editor_signals.disabled_toggle_edit_button.emit(false)
	editor_signals.disabled_toggle_insert_button.emit(false)
	editor_signals.disabled_toggle_select_item_index.emit(false)
	editor_signals.disabled_toggle_stop_button.emit(false)
	editor_signals.disabled_toggle_drag_button.emit(false)
	editor_signals.disabled_toggle_resize_button.emit(false)
	editor_signals.status_playback_stop.emit(true)
	editor_signals.update_timer_slider_by_time.emit()

func _playing():
	editor_signals.disabled_toggle_audio_button.emit(true)
	editor_signals.disabled_toggle_pen_button.emit(true)
	editor_signals.disabled_toggle_edit_button.emit(true)
	editor_signals.disabled_toggle_insert_button.emit(true)
	editor_signals.disabled_toggle_select_item_index.emit(true)
	editor_signals.disabled_toggle_stop_button.emit(true)
	editor_signals.disabled_toggle_drag_button.emit(true)
	editor_signals.status_playback_stop.emit(false)

func _recording_pen():
	editor_signals.disabled_toggle_stop_button.emit(true)
	editor_signals.disabled_toggle_audio_button.emit(true)
	editor_signals.disabled_toggle_drag_button.emit(true)
	editor_signals.disabled_toggle_resize_button.emit(true)

func _recording_audio():
	editor_signals.disabled_toggle_stop_button.emit(true)
	editor_signals.disabled_toggle_pen_button.emit(true)
	editor_signals.disabled_toggle_drag_button.emit(true)
	editor_signals.disabled_toggle_resize_button.emit(true)

func _recording_drag():
	editor_signals.disabled_toggle_stop_button.emit(true)
	editor_signals.disabled_toggle_audio_button.emit(true)
	editor_signals.disabled_toggle_pen_button.emit(true)
	editor_signals.disabled_toggle_resize_button.emit(true)

func _recording_resize():
	editor_signals.disabled_toggle_stop_button.emit(true)
	editor_signals.disabled_toggle_audio_button.emit(true)
	editor_signals.disabled_toggle_pen_button.emit(true)
	editor_signals.disabled_toggle_drag_button.emit(true)

func clipboard_clear_files():
	pass
