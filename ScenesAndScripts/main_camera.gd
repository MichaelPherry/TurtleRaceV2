extends Camera2D

@export var min_zoom: float = 0.01
@export var max_zoom: float = 0.225
@export var zoom_speed: float = 5

func _ready():
	print("ready")
	make_current()

func _process(delta):
	var players = get_tree().get_nodes_in_group("players")
	
	if players.size() <= 1:
		return
	
	var min_pos = players[0].global_position
	var max_pos = players[0].global_position
	
	for p in players:
		min_pos.y = min(min_pos.y, p.global_position.y)
		max_pos.y = max(max_pos.y, p.global_position.y)
	
	var y_pos = (min_pos.y + max_pos.y) / 2
	var x_pos = 4720
	#lobal_position = global_position.lerp(center, delta * 5)
	global_position = Vector2(x_pos, y_pos)
	var width = max_pos.x - min_pos.x
	var height = max_pos.y - min_pos.y + 300
	var largest_distance = max(width, height)
	var target_zoom =  clamp(1 / (largest_distance / 500.0), min_zoom, max_zoom)
	print(target_zoom)
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), delta * zoom_speed)
	
