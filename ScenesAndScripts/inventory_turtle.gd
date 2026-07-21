extends Node2D

@onready var visuals = $Visuals
@onready var shadow = $Shadow
@onready var collision = $CollisionShape2D
@onready var shell_anim = $Visuals/Shell
@onready var legs_anim = $Visuals/Legs
@onready var belly_anim = $Visuals/Belly
@onready var head_anim = $Visuals/Head
@onready var face_anim = $Visuals/Face
@onready var leftArm_anim = $Visuals/LeftArm
@onready var rightArm_anim = $Visuals/RightArm

var shell
var legs
var belly
var head
var face
var left_arm
var right_arm

var local_id = Inventory.local_turtle.keys()[0]

func equip():
	for body_part in Inventory.appendages:
		if Inventory.server_turtles[local_id][body_part] != null:
			match body_part:
				"leftArm":
					left_arm = ItemPassivePool.arm(Inventory.server_turtles[local_id][body_part])
					if leftArm_anim.sprite_frames.has_animation(left_arm.name):
						leftArm_anim.play(left_arm.name)

				"rightArm":
					right_arm = ItemPassivePool.arm(Inventory.server_turtles[local_id][body_part])
					if rightArm_anim.sprite_frames.has_animation(right_arm.name):
						rightArm_anim.play(right_arm.name)

				"head":
					head = ItemPassivePool.head(Inventory.server_turtles[local_id][body_part])
					if head_anim.sprite_frames.has_animation(head.name):
						head_anim.play(head.name)

				"shell":
					shell = ItemPassivePool.shell(Inventory.server_turtles[local_id][body_part])
					if belly_anim.sprite_frames.has_animation(shell.name):
						belly_anim.play(shell.name)

				"legs":
					legs = ItemPassivePool.legs(Inventory.server_turtles[local_id][body_part])
					if legs_anim.sprite_frames.has_animation(legs.name):
						legs_anim.play(legs.name)
