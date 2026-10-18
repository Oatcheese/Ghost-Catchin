extends ProgressBar

var target := 0.0

func reset() -> void:
	target = 0.0
	value = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent() != null and get_parent().visible:
		value = lerp(value, target, 0.15)
	else:
		value = 0.0
		target = 0.0
