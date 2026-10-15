extends Node2D

#@onready var results = $Results/Panel/Timelist
@onready var name_list = $Results/Panel/HBoxContainer/Namelist
@onready var time_list = $Results/Panel/HBoxContainer/Timelist
@onready var tick_controller = $TickController
@onready var race_timer = $CanvasLayer

var finished_turts = []
var turtles 
var time_elapsed = 0.0
var first_finish_time = 15
var already_finished

func _ready():
	Inventory.race_complete = false
	already_finished = false
	#Inventory.what_pos = {}
	Inventory.rng_calls = 0
	race_timer.race_ended_by_time.connect(end_race_by_time)
	#NetworkManager.send_message("Unready", NetworkManager.sessionID)
	var finished = get_tree().get_nodes_in_group("finished")
	for turt in finished:
		turt.remove_from_group("finished")
	$Results.visible = false
	finished_turts = []
	Inventory.tick_controller_ref = tick_controller

func _process(delta):
	NetworkManager.send_message("keepingServerUp", "keepingServerUp")
	time_elapsed += delta
	turtles = get_tree().get_nodes_in_group("players")

	if already_finished == true:
			return
			
func _on_finish_line_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
	if body.is_in_group("not_finished"):
		body.add_to_group("finished")
		body.finished = true
		body.place = get_tree().get_nodes_in_group("finished").size()
		var end_time = format_time(time_elapsed)
		body.finish_time = end_time
		body.remove_from_group("not_finished")
		body.remove_from_group("racing")
		
	if get_tree().get_nodes_in_group("not_finished").size() == 1:
		if race_timer.race_time_remaining > 6:
			race_timer.race_time_remaining = 6
		
	if get_tree().get_nodes_in_group("not_finished").size() == 0:
		setting_up_results()

func end_race_by_time():
	if race_timer.race_time_remaining > 0.0 or already_finished == true:
		return

	var placements = [1, 2, 3, 4]
	
	for turt in get_tree().get_nodes_in_group("finished"):
		placements.erase(turt.place) 
	
	var turtles = get_tree().get_nodes_in_group("not_finished")
	turtles.sort_custom(func(a, b): return a.global_position.y > b.global_position.y)
	
	for turt in turtles:
		turt.place = placements.pop_front()
		turt.finish_time = "N/A"
		turt.remove_from_group("not_finished")
		turt.remove_from_group("racing")

		
	setting_up_results()


func setting_up_results():
	Inventory.race_complete = true
	already_finished = false
	$CanvasLayer.visible = false
	$HUD.visible = false
	for num in range(2):
		var name_label = Label.new()
		name_list.add_child(name_label)
		var time_label = Label.new()
		time_list.add_child(time_label)

	var results = {1: [], 2: []}

	for turt in get_tree().get_nodes_in_group("players"):
		var place_in_word
		match int(turt.place):
			1:
				place_in_word = "first"
			2:
				place_in_word = "second"
		var wanted_name_label = name_list.get_child(int(turt.place) - 1)
		var wanted_time_label = time_list.get_child(int(turt.place) - 1)
		wanted_name_label.text = str(turt.place) + "     "  + turt.name_tag + "     " 
		wanted_time_label.text = turt.finish_time#+ str(turt.curr_tick) 
		wanted_name_label.add_theme_font_size_override("font_size", 36)
		wanted_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		wanted_time_label.add_theme_font_size_override("font_size", 36)
		wanted_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	Inventory.server_turtles.erase(Inventory.boss_id)
	Inventory.start = false
	await get_tree().create_timer(0.1).timeout
	$Results.visible = true

func format_time(time):
	var minutes = floor(int(time) / 60)
	var seconds = int(time) % 60
	var mi_seconds = int((time - int(time)) * 100)
	var ret_time = "%02d:%02d.%02d" % [minutes, seconds, mi_seconds]
	return ret_time
