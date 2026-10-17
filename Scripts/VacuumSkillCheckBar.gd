extends ProgressBar

var tween: Tween
var progress := 0.0

func reset() -> void:
	progress = 0
	value = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(get_parent().visible == true):
		progress = clamp(progress + delta * 40, 0.0, max_value)
	_animate_to_target()

func _animate_to_target() -> void:
	value = lerp(value, progress, 0.2)
