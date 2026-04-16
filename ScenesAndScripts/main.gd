extends Node2D

@onready var turtle_scene = preload("res://ScenesAndScripts/turtle.tscn")
var finished_turts = []
var amount_of_players = 4
var id_names = ["1","2","3","4",]
var start_pos = [[Vector2(2700,820)],[Vector2(4050,820)],[Vector2(5380,820)],[Vector2(6750,820)]]
var time_elapsed = 0.0

func _ready():
	spawn_player(amount_of_players)
	$Results.visible = false
	finished_turts = []

func _process(delta):
	time_elapsed += delta
	
func spawn_player(num_of_players):
	for i in range(num_of_players):
		var player = turtle_scene.instantiate()
		player.id = id_names[i - 1]
		player.global_position = start_pos[i - 1][0]
		add_child(player)

func _on_finish_line_body_exited(body):
	if body.is_in_group("racing"):
		finished_turts.append(body)
		body.finished = true
		body.remove_from_group("racing")
		
	if get_tree().get_nodes_in_group("racing").size() == 0:
		await get_tree().create_timer(0.3).timeout
		#get_tree().paused = true
		await get_tree().create_timer(0.1).timeout
		$Results.visible = true

func format_time(time):
	var minutes = (time)
