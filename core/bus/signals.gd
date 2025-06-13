@tool
class_name SignalsCore
extends Node

# Return a AnySignalCore that will emit when any of the signals in the array are emitted and then disconnect.
# But the data will be stored in the class. [_done, _signal_source, _signal_value]
static func await_any(signals: Array[Signal]) -> Variant:
	var watcher := AnySignalCore.new()
	for sig in signals:
		watcher.add_signal(sig)
	return watcher

# Return a AnySignalCore that will emit when any of the signals in the array are emitted and keeping the connection.
static func await_any_once(signals: Array[Signal]) -> Variant:
	var watcher := AnySignalCore.new()
	for sig in signals:
		watcher.add_signal_once(sig)
	return watcher

# A class to manage multiple signals.
class AnySignalCore:
	signal completed(value)

	var _done := false
	var _entries := []
	var _signal_source
	var _signal_value

	# Called when the signal is emitted
	# it will keep all signals connections and emit the completed signal and store the states
	func add_signal(sig: Signal) -> void:
		var fun_connected = func(value = null) -> void:
			_on_signal(sig, value)
		sig.connect(fun_connected)
		_entries.append([sig, fun_connected])

	# Called when the signal is emitted and if a signal is received
	# it will keep all signals and emit the completed signal and store the states
	func _on_signal(sig: Signal, value = null) -> void:
		if _done:
			return
		_done = true
		
		_signal_source = sig
		_signal_value = value
		emit_signal("completed", value)

	#Add a signal that will emit when the signal is emitted and then disconnect the rest if the signal is received
	func add_signal_once(sig: Signal) -> void:
		var fun_connected = func(value = null) -> void:
			_on_signal_once(sig, value)
		sig.connect(fun_connected)
		_entries.append([sig, fun_connected])

	# Called when the signal is emitted and if a signal is received
	# it will disconnect all signals and emit the completed signal and store the states
	func _on_signal_once(sig: Signal, value = null) -> void:
		if _done:
			return
		_done = true
		
		_signal_source = sig
		_signal_value = value
		emit_signal("completed", value)

		_disconnect_all()

	# Disconnect all signals
	func _disconnect_all():
		for entry in _entries:
			var signal_entry: Signal = entry[0]
			var fun_connected = entry[1]
			if fun_connected != null and signal_entry.is_connected(fun_connected):
				signal_entry.disconnect(fun_connected)
		_entries.clear()

	# Reset the states of the class
	func restart():
		_done = false
		_signal_source = null
		_signal_value = null
