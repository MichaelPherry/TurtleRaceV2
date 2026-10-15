extends CanvasLayer


@onready var countdown_label = $Countdown
@onready var gametime_label = $Gametime

var race_time_limit = 30
var race_time_remaining = 30
var race_active = false

signal race_ended_by_time

func _ready():
	gametime_label.visible = false
	await start_countdown()
	race_active = true
	gametime_label.visible = true

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
	tween.tween_property(countdown_label,"scale",Vector2(1.15, 1.15),0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(countdown_label,"modulate:a",0.0,0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished

func show_go():
	countdown_label.text = "GO!"
	countdown_label.modulate.a = 1.0
	countdown_label.scale = Vector2(0.7, 0.7)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(countdown_label,"scale",Vector2(1.2, 1.2),0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(countdown_label,"modulate:a",0.0,0.7).set_delay(0.3)

	await tween.finished

func tick(tick_interval):
	if race_active == false:
		return
	race_time_remaining -= tick_interval
	var formatted_time = format_time(race_time_remaining)
	gametime_label.text = "Time: " + str(formatted_time)
	
	if race_time_remaining <= 0.0:
		race_active = false
		race_ended_by_time.emit()
	
func format_time(time):
	var seconds = int(time) % 60
	var ret_time = "%02d" % [seconds]
	return ret_time
