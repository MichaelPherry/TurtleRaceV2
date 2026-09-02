extends CanvasLayer


@onready var countdown_label = $Countdown


func _ready():
	start_countdown()


func start_countdown():

	await show_countdown_number("3")
	await show_countdown_number("2")
	await show_countdown_number("1")

	await show_go()
	Inventory.start = true

func show_countdown_number(number: String):
	countdown_label.text = number
	countdown_label.modulate.a = 1.0
	countdown_label.scale = Vector2(1.0, 1.0)

	# Make it slightly bigger as it appears
	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		countdown_label,
		"scale",
		Vector2(1.15, 1.15),
		0.8
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		countdown_label,
		"modulate:a",
		0.0,
		0.8
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await tween.finished


func show_go():
	countdown_label.text = "GO!"
	countdown_label.modulate.a = 1.0
	countdown_label.scale = Vector2(0.7, 0.7)

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		countdown_label,
		"scale",
		Vector2(1.2, 1.2),
		0.4
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		countdown_label,
		"modulate:a",
		0.0,
		0.7
	).set_delay(0.3)

	await tween.finished
