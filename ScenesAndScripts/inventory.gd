extends Node

#Format grabbed from server
#	"id" : {
#		"items" : {
#		"leftArm" : null,
#		"rightArm" : null,
#		"head" : null,
#		"shell" : null,
#		"legs" : null,
#		"slot" : integer
#		},
#		"base_stats" : {
#			"acceleration" : integer,
#			"resilience" : percentage,
#			"max_speed" : integer,
#			"fire_rate" : integer,
#			"projectile_speed" : integer,
#			"luck" : integer
#		},
#		"econ" : {
#			"gold" : integer,
#			"turtle1_stock" : integer,
#			"turtle2_stock" : integer,
#			"turtle3_stock" : integer,
#			"turtle4_stock" : integer
#		}
#	}

var appendages = ["head", "shell", "legs", "leftArm", "rightArm"]
var stats = ["acceleration", "resilience", "max_speed", "fire_rate", "projectile_speed", "luck"]
var econ = ["gold"]
var what_pos = {}
var race_order = []

var rng_calls = 0
var mode
var id_list
var id_name_list
var seed
var local_turtle = {}
var server_turtles = {}
var start_time
var projectiles = []
var end_items = []
var race_started = false
var start = false
var tick_controller_ref

var item_1
var item_2
var item_3

#currently not in use
func reset_turtles():
	var server_keys = server_turtles.keys()
	for id in server_keys:
		for body_part in appendages:
			server_turtles[id][body_part] = null
		server_turtles[id]["slot"] = null
		
func set_turtles(turtles):
	var server_keys = turtles.keys()
	for id in server_keys:
		for body_part in appendages:	
			server_turtles.get_or_add(id, {}).get_or_add("items", {})[body_part] = turtles[id]["build"]["items"][body_part]
		for stat in stats:
			server_turtles.get_or_add(id, {}).get_or_add("base_stats", {})[stat] = turtles[id]["build"]["base_stats"][stat]
		for security in econ:
			server_turtles.get_or_add(id, {}).get_or_add("econ", {})[security] = turtles[id]["build"]["econ"][security]
		server_turtles[id]["slot"] = turtles[id]["slot"]
	var temp = 2
	
func seconds_to_ticks(seconds, tick_rate):
	return round (seconds / tick_rate)
	
func wait_ticks(user, amt_of_seconds_to_wait):
	var amt_of_ticks_to_wait = seconds_to_ticks(amt_of_seconds_to_wait, user.tick_rat)
	var target_tick = user.curr_tick + amt_of_ticks_to_wait
	while user.curr_tick < target_tick:
		await tick_controller_ref.tick_sig

func dupe_remover(duped_list):
	var unique_list = []
	for element in duped_list:
		if element not in unique_list:
			unique_list.append(element)
	return unique_list
