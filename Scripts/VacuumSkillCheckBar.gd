extends ProgressBar

var tween: Tween
var progress = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(get_parent().visible == true):
		progress += delta * 40
	_animate_to_target()

func _animate_to_target() -> void:
	tween = create_tween()
	tween.tween_property(self, "value", progress, 1)
