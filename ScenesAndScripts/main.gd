extends Node2D

@onready var results = $Results/Panel/Timelist
@onready var tick_controller = $TickController

var finished_turts = []
var turtles 
var time_elapsed = 0.0
var first_finish_time = 15

func _ready():
	$Bass.play()
	$Organ.play()
	$Piano.play()
	$Trumpet.play()
	$Whistle.play()
	Inventory.rng_calls = 0
	NetworkManager.send_message("Unready", NetworkManager.sessionID)
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
	turtles.sort_custom(func(a,b): return a.id < b.id)
		
	for turtle in turtles:
		Inventory.what_pos[turtle.name_tag] = turtle.global_position.y
	var order = Inventory.what_pos.keys().map(func(k): return [k, Inventory.what_pos[k]])
	order.sort_custom(func(a, b): return a[1] > b[1])
	Inventory.race_order = order
	
	if str(order[0][0]) == turtles[0].name_tag:
		if $Organ.volume_db < 0:
			$Organ.volume_db = -20
			$Piano.volume_db = -80
			$Trumpet.volume_db = -80
			$Whistle.volume_db = -80
	elif str(order[0][0]) == turtles[1].name_tag:
		if $Piano.volume_db < 0:
			$Piano.volume_db = -20
			$Organ.volume_db = -80
			$Trumpet.volume_db = -80
			$Whistle.volume_db = -80
	elif str(order[0][0]) == turtles[2].name_tag:
		if $Trumpet.volume_db < 0:
			$Trumpet.volume_db = -20
			$Organ.volume_db = -80
			$Piano.volume_db = -80
			$Whistle.volume_db = -80
	elif str(order[0][0]) == turtles[3].name_tag:
		if $Whistle.volume_db < 0:
			$Whistle.volume_db = -20
			$Organ.volume_db = -80
			$Piano.volume_db = -80
			$Trumpet.volume_db = -80


func _on_finish_line_body_exited(body):
	if body.is_in_group("racing"):
		body.add_to_group("finished")
		body.finished = true
		body.place = get_tree().get_nodes_in_group("finished").size()
		if body.place == 1:
			pass
			
		var end_time = format_time(time_elapsed)
		body.finish_time = end_time
		body.remove_from_group("racing")
		
	if get_tree().get_nodes_in_group("racing").size() == 0:
		for num in range(4):
			var label = Label.new()
			results.add_child(label)
		
					
		for turt in get_tree().get_nodes_in_group("players"):
			var temp = results.get_children()
			var wanted_label = results.get_child(int(turt.place))
			wanted_label.text = turt.name_tag + "     " + turt.finish_time + "     " + str(turt.curr_tick) 
			 
		await get_tree().create_timer(0.1).timeout
		$Results.visible = true
		

func format_time(time):
	var minutes = floor(int(time) / 60)
	var seconds = int(time) % 60
	var mi_seconds = int((time - int(time)) * 100)
	var ret_time = "%02d:%02d.%02d" % [minutes, seconds, mi_seconds]
	return ret_time
