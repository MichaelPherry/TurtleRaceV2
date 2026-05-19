extends Node2D

@onready var turtle_scene = preload("res://ScenesAndScripts/turtle.tscn")
@onready var results = $Results/Panel/Timelist

var finished_turts = []
var amount_of_players = 4
var id_names = [NetworkManager.sessionID ,"2","3","4",]
var start_pos = [[Vector2(2700,820)],[Vector2(4050,820)],[Vector2(5380,820)],[Vector2(6750,820)]]
var time_elapsed = 0.0

func _ready():
	spawn_player(amount_of_players)
	var finished = get_tree().get_nodes_in_group("finished")
	for turt in finished:
		turt.remove_from_group("finished")
	$Results.visible = false
	finished_turts = []

func _process(delta):
	time_elapsed += delta
	
func spawn_player(num_of_players):
	for i in range(num_of_players):
		var player = turtle_scene.instantiate()
		player.id = id_names[i]
		player.global_position = start_pos[i][0]
		add_child(player)

func _on_finish_line_body_exited(body):
	if body.is_in_group("racing"):
		body.add_to_group("finished")
		body.finished = true
		body.place = get_tree().get_nodes_in_group("finished").size()
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
			wanted_label.text = turt.id + "     " + turt.finish_time
			 
		await get_tree().create_timer(0.3).timeout
		#get_tree().paused = true
		await get_tree().create_timer(0.1).timeout
		$Results.visible = true

func format_time(time):
	var minutes = floor(int(time) / 60)
	var seconds = int(time) % 60
	var mi_seconds = int((time - int(time)) * 100)
	var ret_time = "%02d:%02d.%02d" % [minutes, seconds, mi_seconds]
	return ret_time
