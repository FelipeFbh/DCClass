class_name LineWidget
extends Widget

const scene = preload("res://core/widgets/entities/line_widget.tscn")
signal termino

@export var entity: LineEntity
var line: Line2D
var tween: Tween

func init(properties: Dictionary) -> void:
	line = scene.instantiate()
	add_child(line)
	if properties.has("position"):
		position = properties["position"]
	line.hide()

func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	line.show()
	if tween:
		tween.kill()

	var pts = entity.points
	var delays = entity.delays
	
	var count = pts.size()
	if count == 0:
		return

	tween = create_tween()
	tween.set_speed_scale(1 / (_duration / _total_real_time))
	
	
	for i in range(count):
		tween.tween_callback(Callable(self, "_add_points").bind(i))
		if i < delays.size():
			tween.tween_interval(delays[i])

	#var now = Time.get_ticks_msec() / 1000.0
	add_to_group(&"playing_widget")
	_bus_core.current_node_changed.emit(class_node)
	tween.play()
	
	await tween.finished
	
	remove_from_group(&"widget_playing")
	add_to_group(&"widget_finished")
	#var finish = Time.get_ticks_msec() / 1000.0
	#print("LineWidget: Play time: ", finish - now, " seconds")
	emit_signal("termino")


func reset():
	if tween:
		tween.kill()
	line.hide()
	line.clear_points()
	remove_from_group(&"widget_playing")
	remove_from_group(&"widget_finished")
	emit_signal("termino")


func stop() -> void:
	skip_to_end()
	

func skip_to_end() -> void:
	if tween:
		tween.kill()
	line.points = entity.points
	line.show()
	add_to_group(&"widget_finished")
	emit_signal("termino")

func _add_points(i: int) -> void:
	if not line.points.is_empty() and line.points[-1] == entity.points[i]:
		return # to avoid duplicate points
	line.add_point(entity.points[i])

func clear():
	reset()


## Returns the duration of the line in seconds.
func compute_duration() -> float:
	var duration: float = 0.0
	var delays = entity.delays
	if delays.size() > 0:
		for i in range(delays.size()):
			duration += delays[i]
	return duration
