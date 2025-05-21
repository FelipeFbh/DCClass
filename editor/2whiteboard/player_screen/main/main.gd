class_name ClassUIEditor
extends Node

static var context: ClassContextEditor

@onready var class_scene: ConceptClassSceneEditor = $ParseAndPlay
@onready var window: ConceptClassWindowEditor = $ClassWindow

func _enter_tree():
	context = ClassContextEditor.new()

func _ready():
	print("ClassScene._ready")
	_setup_scene()

func _setup_scene():
	window.set_class_node(class_scene)
	window.set_index_tree(class_scene.tree_manager.tree)
	#class_scene.compute_duration()
	#window.set_total_time(ceili(class_scene.total_duration))
	#window.setup_mods()
	#window.stopwatch.start()
	class_scene.play()

class ClassContextEditor:
	var camera: ClassCameraEditor
	var stopwatch: StopwatchEditor
