class_name ClassUIEditor
extends Node

static var context: ClassContextEditor = ClassContextEditor.new()

@onready var class_scene: ClassSceneEditor = $PlayClass
@onready var window: ConceptClassWindowEditor = $ClassWindow


func _ready():
	class_scene._setup_play()
	print("ClassScene._ready")
	_setup_scene()

func _setup_scene():
	window.set_class_node(class_scene)
	#window.set_index_tree()
	#class_scene.compute_duration()
	#window.set_total_time(ceili(class_scene.total_duration))
	#window.setup_mods()
	#window.stopwatch.start()
	#class_scene.play()

class ClassContextEditor:
	var camera: ClassCameraEditor
	var stopwatch: StopwatchEditor
