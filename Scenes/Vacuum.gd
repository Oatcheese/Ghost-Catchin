extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouseposition = get_local_mouse_position()
	rotation += mouseposition.angle() + 30
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pass
