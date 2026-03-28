class_name ClassUIEditor
extends Node

static var context: ClassContextEditor = ClassContextEditor.new()

@onready var class_scene: ClassSceneEditor = %PlayClass
@onready var window: ClassWindowEditor = $ClassWindow


func _ready():
	class_scene._setup_play()
	print("ClassScene._ready")
	_setup_scene()

func _setup_scene():
	window.set_class_node(class_scene)

class ClassContextEditor:
	var camera: ClassCameraEditor
