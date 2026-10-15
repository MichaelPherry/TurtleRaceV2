extends CharacterBody2D

#Rabbit animations and markers
@onready var animations = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var stamina_bar = $RabbitUI/StaminaBar
@onready var name_label = $RabbitUI/VBoxContainer/NameLabel
var stamina_bar_style: StyleBoxFlat

#Turtle items and appendages
var base_animation_speed = 0.5
var left_arm = null
var left_arm_instance = null
var left_arm_cooldown_max: float
var left_arm_cooldown = 0
var left_arm_active = false
var left_arm_type = null
var right_arm = null
var right_arm_instance = null
var right_arm_cooldown_max: float
var right_arm_cooldown = 0
var right_arm_active = false
var right_arm_type = null
var head = "bunny_ears"
var head_instance = null
var head_cooldown_max: float
var head_cooldown = 0
var head_active = false
var head_type = null
var shell = null
var shell_instance = null
var shell_cooldown_max: float
var shell_cooldown = 0
var shell_active = false
var shell_type = null
var legs = null
var legs_cooldown_max: float
var legs_cooldown = 0
var legs_instance = null
var legs_active = false
var legs_type = null

var left_ready = false
var right_ready = false
var head_ready = false
var shell_ready = false
var legs_ready = false

#Rabbit stats
var max_stamina = 100
var current_stamina = 100
var stamina_broken = false
var acceleration
var resilience
var max_speed = 300
var current_speed = 200
var normal_height = -50
var height = -50
var max_height = -500
var fire_rate
var projectile_speed
var luck
var stun = 0

#Rabbit effects
var asleep
var projectile_amt = 1

#Rabbit properties
var id = "Rabbit"
var kaput = false
var name_tag = "Rabbit"
var finished = false
var invincible = false
var hit = false
var finish_time = "N/A"
var place = "N/A"
var grounded = true

#Misc
var rng
var seed
var sim_position
var direction = 1
var curr_tick = -1
var tick_rat

#way to put effects on certain items
var item_types = {"Gun" : []}
#way to put effects on turtle when being hit
var rabbit_effects = []

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = seed
	stamina_bar_style = stamina_bar.get_theme_stylebox("fill").duplicate()
	stamina_bar.add_theme_stylebox_override("fill", stamina_bar_style)
	update_stamina_bar()
	
	current_speed = 0
	acceleration = Inventory.server_turtles[id]["base_stats"]["acceleration"]
	resilience = Inventory.server_turtles[id]["base_stats"]["resilience"]
	max_speed = Inventory.server_turtles[id]["base_stats"]["max_speed"]
	fire_rate = Inventory.server_turtles[id]["base_stats"]["fire_rate"]
	projectile_speed = Inventory.server_turtles[id]["base_stats"]["projectile_speed"]
	luck = Inventory.server_turtles[id]["base_stats"]["luck"]
	asleep = false
	
	animation_controller()
	name_label.text = str(name_tag)
	name_label.visible = true
	Inventory.rng_calls += 1
	equip()
	sim_position = global_position
	add_to_group(id)
	add_to_group("players")
	add_to_group("racing")
	add_to_group("not_finished")
	animations.play("Emerging")

	
func _process(delta):
	animations.speed_scale = lerp(0.8, 2.0, clamp(current_speed / max_speed, 0.0, 1.0))
	global_position = global_position.lerp(sim_position, 0.25)

func tick(current_tick, tick_rate):
	if Inventory.race_started == false or Inventory.start == false:
		return
		
	animations.play("Running")
	if stamina_broken == true:
		current_speed = 0
		stamina_replenish()
		return
		
	if hit == true:
		return
	
	if sim_position.y > 9000:
		if grounded == true and height == max_height:
			stop_flying()
			collision.position.y = normal_height
		velocity.y = 0
		return
	
	if grounded == false and height == normal_height:
		start_flying()
	
	if grounded == true and height == max_height:
		stop_flying()
	
	if grounded:
		height = normal_height
	else:
		height = max_height

	#visuals.position.y = height
	collision.position.y = height 
	
	current_speed = min(current_speed + acceleration, max_speed)
	if (sim_position.y < 50 and direction == -1) or asleep:
		sim_position.y += 0
	else:
		sim_position.y += current_speed * tick_rate * direction
	curr_tick = current_tick
	tick_rat = tick_rate
	
	stamina_replenish()

func equip():
	for body_part in Inventory.appendages:
		if Inventory.server_turtles[id]["items"][body_part] != null:
			match body_part:
				"head":
					if head_instance == null:
						head = ItemPassivePool.head(Inventory.server_turtles[id]["items"][body_part])
						head_cooldown_max = head.cooldown
						head_cooldown = head_cooldown_max
						head_instance = head.passive_scene.instantiate()
						head_instance.visible = false
						#hat_marker.visible = true
						head_instance.user = self
						#head_anim.add_child(head_instance)


				"shell":
					if shell_instance == null:
						shell = ItemPassivePool.shell(Inventory.server_turtles[id]["items"][body_part])
						shell_cooldown_max = shell.cooldown
						shell_cooldown = shell_cooldown_max
						shell_instance = shell.passive_scene.instantiate()
						shell_instance.user = self
						shell_instance.visible = false
						#belly_anim.add_child(shell_instance)

				"legs":
					if legs_instance == null:
						legs = ItemPassivePool.legs(Inventory.server_turtles[id]["items"][body_part])
						legs_cooldown_max = legs.cooldown
						legs_cooldown = legs_cooldown_max
						legs_instance = legs.passive_scene.instantiate()
						legs_instance.user = self
						legs_instance.visible = false
						#legs_anim.add_child(legs_instance)


				"leftArm":
					if left_arm_instance == null:
						left_arm = ItemPassivePool.arm(Inventory.server_turtles[id]["items"][body_part])
						left_arm_cooldown_max = left_arm.cooldown
						left_arm_cooldown = left_arm_cooldown_max
						left_arm_type = left_arm.type
						if left_arm.stay_in_hand == true:
							left_arm_instance = left_arm.item_scene.instantiate()
							left_arm_instance.user = self
							left_arm_instance.visible = false
							#leftArm_anim.add_child(left_arm_instance)

				"rightArm":
					if right_arm_instance == null:
						right_arm = ItemPassivePool.arm(Inventory.server_turtles[id]["items"][body_part])
						right_arm_cooldown_max = right_arm.cooldown
						right_arm_cooldown = right_arm_cooldown_max
						right_arm_type = right_arm.type
						if right_arm.stay_in_hand == true:
							right_arm_instance = right_arm.item_scene.instantiate()
							right_arm_instance.user = self
							right_arm_instance.visible = false
							#rightArm_anim.add_child(right_arm_instance)

func left_arm_item(user, target, scene):
	if left_arm.stay_in_hand == true:
		left_arm_instance.use_item(target)
	else:
		var instance = scene.instantiate()
		instance.target = target
		instance.user = user
		instance.global_position = user.global_position + Vector2(0, height)
		current_speed = 0
		if instance.ground_trap == true:
			instance.final_position = target_final_position(instance.target)
		#if user.sim_position.x > target.sim_position.x:
			##user.sprite.flip_h = true
			#await get_tree().create_timer(0.5).timeout
			##user.sprite.flip_h = false
		#else:
			#await get_tree().create_timer(0.5).timeout
		current_speed = max_speed
		#moving_animations()
		get_tree().current_scene.add_child(instance)
	
func right_arm_item(user, target, scene):
	if right_arm.stay_in_hand == true:
		right_arm_instance.use_item(target)
	else:
		var instance = scene.instantiate()
		instance.target = target
		instance.user = user
		instance.global_position = user.global_position + Vector2(0, height)
		current_speed = 0
		if instance.ground_trap == true:
			instance.final_position = target_final_position(instance.target)
		#if user.sim_position.x > target.sim_position.x:
			##user.sprite.flip_h = true
			#await get_tree().create_timer(0.5).timeout
			##user.sprite.flip_h = false
		#else:
			#await get_tree().create_timer(0.5).timeout
		current_speed = max_speed
		#moving_animations()
		get_tree().current_scene.add_child(instance)
	
func invin_frames(stamina_damage = 0, projectile_keywords = null):
	if stamina_broken:
		return
	invincible = true
	hit = true
	var temp_effects = rabbit_effects.duplicate()
	if projectile_keywords != null:
		projectile_keywords.append_array(temp_effects)
	elif temp_effects.size() > 0:
		projectile_keywords = temp_effects
	
	if projectile_keywords != null:
		#var unique_projectile_keywords = Inventory.dupe_remover(projectile_keywords)
		for word in projectile_keywords:
			if word == "Ruthless":
				stamina_damage *= 2
			if word == "Divine":
				resilience = resilience * 1.5

	current_stamina -= stamina_damage
	update_stamina_bar()
	var sped = sim_position.y
	#current_speed = min(current_speed, current_speed * resilience)
	sim_position.y -= current_speed * tick_rat
	var sprite = $Visuals
	animations.modulate = Color(1, 1, 1, 0.2)
	await get_tree().create_timer(0.1).timeout
	animations.modulate = Color(1, 1, 1, 1) 
	await get_tree().create_timer(0.1).timeout
	animations.modulate = Color(1, 1, 1, 0.2)
	await get_tree().create_timer(0.1).timeout
	animations.modulate = Color(1, 1, 1, 1) 
	await get_tree().create_timer(0.1).timeout
	animations.modulate = Color(1, 1, 1, 0.2)
	await get_tree().create_timer(0.1).timeout
	animations.modulate = Color(1, 1, 1, 1) 
	sim_position.y = sped
	hit = false
	await Inventory.wait_ticks(self, 0.2)
	invincible = false

func update_stamina_bar():
	var percent = current_stamina / max_stamina
	stamina_bar.value = current_stamina
	
	if current_stamina >= 50:
		stamina_bar_style.bg_color = Color.YELLOW.lerp(Color.GREEN, (percent - 0.5) * 2.0)
	else:
		stamina_bar_style.bg_color = Color.RED.lerp(Color.YELLOW, percent * 2.0)

func stamina_replenish():
	if stamina_broken == false:
		if current_stamina > 0:
			current_stamina += resilience * tick_rat
			current_stamina = min(current_stamina, max_stamina)
		else:
			stamina_broken = true
			kaput = true
	
	if stamina_broken == true:
		if current_stamina < 100:
			if self.is_in_group("racing"):
				self.remove_from_group("racing")
			current_stamina += max((resilience / 2) * tick_rat, 10 * tick_rat)
			current_stamina = min(current_stamina, max_stamina)
		else:
			add_to_group("racing")
			stamina_broken = false
			kaput = false
	update_stamina_bar()

func animation_controller():
	var action = "Running"

	
func target_final_position(target):
	var max = 7500
	var min = 1000
	var final_position
	if (target.sim_position.y + min) > max:
		final_position = Vector2(target.sim_position.x, max)
	else:
		Inventory.rng_calls += 1
		var simpx = target.sim_position.x
		var targy = target.sim_position.y + min
		var randy_targ = rng.randi_range(targy, max)
		final_position = Vector2(simpx, randy_targ)
		#print(final_position.y, " final ", curr_tick, " ", rng.state, " targs ", targy, " randy targ ", randy_targ)
	return final_position
	
func start_flying():
	var tween = create_tween()
	tween.tween_property($Visuals, "position:y", max_height, 1.0)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	
func stop_flying():
	var tween = create_tween()
	tween.tween_property($Visuals, "position:y", -250, 1.0)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)

func go_asleep(how_long, appendage = null):
	asleep = true
	kaput = true
	await Inventory.wait_ticks(self, how_long)
	kaput = false
	asleep = false
