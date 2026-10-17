extends CharacterBody2D

@export var speed := 300
@onready var _animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	if velocity.x != 0 or velocity.y != 0:
		_animated_sprite.play("default")	
	else:
		_animated_sprite.stop()
	if velocity.x < 0:
		_animated_sprite.flip_h = true
	if velocity.x > 0:
		_animated_sprite.flip_h = false
	move_and_slide()
