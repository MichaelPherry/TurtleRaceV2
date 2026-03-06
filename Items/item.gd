extends Resource
class_name Item

@export var name: String
@export var description: String
@export var icon: Texture2D
@export var cooldown: int
@export var item_scene: PackedScene

func apply(user, target):
	if item_scene:
		user.call(name, user, target, item_scene)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
