extends Node2D

var ghosts
var parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ghosts = get_tree().get_nodes_in_group("Ghosts")
	parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouseposition = get_local_mouse_position()
	rotation += mouseposition.angle()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		get_node("Succ").visible = true
		get_node("SuccCollider").visible = true
	else:
		get_node("Succ").visible = false
		get_node("SuccCollider").visible = true

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Ghosts")):
		parent.get_node("Control").visible = true
