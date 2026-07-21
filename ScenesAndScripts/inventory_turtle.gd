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

var shell = null
var legs = null
var belly = null
var head = null
var face = null
var left_arm = null
var right_arm = null
var current_frame = 0

var local_id = Inventory.local_turtle.keys()[0]

func _ready():
	equip()

func equip():
	for body_part in Inventory.appendages:
		if Inventory.local_turtle[local_id]["items"][body_part] != null:
			match body_part:
				"leftArm":
					left_arm = ItemPassivePool.arm(Inventory.local_turtle[local_id]["items"][body_part])
					if leftArm_anim.sprite_frames.has_animation(left_arm.name):
						leftArm_anim.play(left_arm.name)
						leftArm_anim.frame = current_frame
						leftArm_anim.pause()

				"rightArm":
					right_arm = ItemPassivePool.arm(Inventory.local_turtle[local_id]["items"][body_part])
					if rightArm_anim.sprite_frames.has_animation(right_arm.name):
						rightArm_anim.play(right_arm.name)
						rightArm_anim.frame = current_frame
						rightArm_anim.pause()

				"head":
					head = ItemPassivePool.head(Inventory.local_turtle[local_id]["items"][body_part])
					if head_anim.sprite_frames.has_animation(head.name):
						head_anim.play(head.name)
						head_anim.frame = current_frame
						head_anim.pause()

				"shell":
					shell = ItemPassivePool.shell(Inventory.local_turtle[local_id]["items"][body_part])
					if belly_anim.sprite_frames.has_animation(shell.name):
						belly_anim.play(shell.name)
						belly_anim.frame = current_frame
						belly_anim.pause()
						
				"legs":
					legs = ItemPassivePool.legs(Inventory.local_turtle[local_id]["items"][body_part])
					if legs_anim.sprite_frames.has_animation(legs.name):
						legs_anim.play(legs.name)
						legs_anim.frame = current_frame
						legs_anim.pause()

func hover():
	current_frame = shell_anim.frame
	shell_anim.frame = current_frame
	shell_anim.play("default")
	face_anim.frame = current_frame
	face_anim.play("default")
	if legs != null:
		legs_anim.frame = current_frame
		legs_anim.play(legs.name)
	else:
		legs_anim.frame = current_frame
		legs_anim.play("default")
		
	if shell != null:
		belly_anim.frame = current_frame
		belly_anim.play(shell.name)
	else:
		belly_anim.frame = current_frame
		belly_anim.play("default")
		
	if head != null:
		head_anim.frame = current_frame
		head_anim.play(head.name)
	else:
		head_anim.frame = current_frame
		head_anim.play("default")
		
	if left_arm != null:
		leftArm_anim.frame = current_frame
		leftArm_anim.play(left_arm.name)
	else:
		leftArm_anim.frame = current_frame
		leftArm_anim.play("default")
		
	if right_arm != null:
		rightArm_anim.frame = current_frame
		rightArm_anim.play(right_arm.name)
	else:
		rightArm_anim.frame = current_frame
		rightArm_anim.play("default")
	
func unhover():
	shell_anim.pause()
	face_anim.pause()
	legs_anim.pause()
	belly_anim.pause()
	head_anim.pause()
	leftArm_anim.pause()
	rightArm_anim.pause()
	current_frame = shell_anim.frame
