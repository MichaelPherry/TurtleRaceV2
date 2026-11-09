extends Label

var search_elapsed: float = 0.0
var search_timer_active: bool = false


func start_search_timer():
	search_elapsed = 0.0
	search_timer_active = true
	self.visible = true
	self.text = "Searching: 00:00"


func _process(delta):
	if not search_timer_active:
		return

	search_elapsed += delta
	var total_seconds = int(search_elapsed)
	self.text = "Searching: %02d:%02d" % [total_seconds / 60, total_seconds % 60]


func stop_search_timer():
	search_timer_active = false
	self.visible = false
