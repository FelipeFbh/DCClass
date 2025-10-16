class_name ClassUIMobile
extends Node

static var context: ClassContextMobile = ClassContextMobile.new()

@onready var class_scene: ClassSceneMobile = %PlayClass
@onready var window: ClassWindowMobile = $ClassWindow


func _ready():
	_setup_scene()

func _setup_scene():
	window.set_class_node(class_scene)
	
func _setup():
	class_scene._setup_play()
	window._setup()
	print("ClassScene._ready")



class ClassContextMobile:
	var camera: ClassCameraMobile
