extends CanvasLayer

@onready var flash_rect = %FlashRect
@onready var animation_player = %FlashAnimation
@onready var camera_sound = %FlashSound

func _ready():
		flash_rect.visible = false
		
func take_screenshot():
	# flash animation
	flash_rect.visible = true
	animation_player.play("screenshot")
	
	await animation_player.animation_finished
	flash_rect.visible = false
