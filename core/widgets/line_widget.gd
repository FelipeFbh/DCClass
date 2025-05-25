class_name LineWidget
extends Widget

const scene = preload("res://core/widgets/line_widget.tscn")

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

signal termino
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	line.show()
	if tween:
		tween.kill()

	var pts = entity.points
	var delays = entity.delays
	
	var count = pts.size()
	if count == 0:
		return
	#var needed := count - 1
	#if delays.size() < needed:
	#	for i in range(delays.size(), needed):
	#		delays.append((_duration_leaf / _total_real_time) * _duration / needed)

	tween = create_tween()
	tween.set_speed_scale(1/(_duration / _total_real_time))
	tween.pause()
	
	for i in range(count):
		tween.tween_callback(Callable(self, "_add_points").bind(i))
		if i < delays.size():
			tween.tween_interval(delays[i])

	#var now = Time.get_ticks_msec() / 1000.0
	tween.play()
	
	await tween.finished
	emit_signal("termino")
	#var finish = Time.get_ticks_msec() / 1000.0
	#print("LineWidget: Play time: ", finish - now, " seconds")

func reset():
	if tween:
		tween.kill()
	line.hide()
	line.clear_points()

func skip_to_end() -> void:
	if tween:
		tween.kill()
	line.points = entity.points
	line.show()

func _add_points(i: int) -> void:
	if not line.points.is_empty() and line.points[-1] == entity.points[i]:
		return # to avoid duplicate points
	line.add_point(entity.points[i])


## Returns the duration of the line in seconds.
func compute_duration() -> float:
	var duration: float = 0.0
	var delays = entity.delays
	if delays.size() > 0:
		for i in range(delays.size()):
			duration += delays[i]
	return duration
