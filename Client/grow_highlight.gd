extends TextureButton

var tween: Tween

func _ready():
	pivot_offset = size / 2
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15)
	tween.parallel().tween_property(self, "modulate", Color(1.3, 1.3, 1.3), 0.15)

func _on_mouse_exited():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.15)
