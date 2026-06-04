extends Resource
class_name Item

@export var name: String
@export var description: String
@export var body_part: String
@export var icon: Texture2D
@export var cooldown: int
@export var item_scene: PackedScene
@export var ground_trap: bool
@export var active: bool
@export var animation: bool


func apply(user, target, name):
	if item_scene:
		user.call(name, user, target, item_scene)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
