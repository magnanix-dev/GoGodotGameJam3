extends Position3D
class_name Weapon

export var settings : Resource

var allow_primary = true
var allow_secondary = true

var primary_timer : Timer
var secondary_timer : Timer

var primary_list = []
var primary_dead_list = []
var secondary_list = []
var secondary_dead_list = []

onready var primary_pool = $Primary
onready var secondary_pool = $Secondary

func _ready():
	primary_timer = Timer.new()
	primary_timer.connect("timeout", self, "_on_primary_timer_timeout")
	secondary_timer = Timer.new()
	secondary_timer.connect("timeout", self, "_on_secondary_timer_timeout")
	add_child(primary_timer)
	add_child(secondary_timer)
	init_primary(64)
	init_secondary(64)

func _process(delta):
	clean_lists()

func init_primary(amount):
	if settings.primary_object:
		for n in range(amount):
			var b = settings.primary_object.instance()
			b.active = false
			b.settings = settings.primary_settings
			b.weapon = self
			primary_dead_list.push_back(b)
			primary_pool.add_child(b)

func init_secondary(amount):
	if settings.secondary_object:
		for n in range(amount):
			var b = settings.secondary_object.instance()
			b.active = false
			b.settings = settings.secondary_settings
			b.weapon = self
			secondary_dead_list.push_back(b)
			secondary_pool.add_child(b)

func primary(pos, dir):
	if allow_primary:
		allow_primary = false
		primary_timer.start(settings.primary_cooldown)
		fire_primary(pos, dir, settings.primary_evolutions + owner.primary_evolutions)

func fire_primary(pos, dir, evolutions = []):
	var b = primary_dead_list[0]
	primary_dead_list.pop_front()
	b.call_func = "fire_secondary"
	b.evolutions = evolutions
	primary_list.append(b)
	b.move(pos, dir)
	b.execute()

func secondary(pos, dir):
	if allow_secondary:
		allow_secondary = false
		secondary_timer.start(settings.secondary_cooldown)
		fire_secondary(pos, dir, settings.secondary_evolutions + owner.secondary_evolutions)

func fire_secondary(pos, dir, evolutions = []):
	var b = secondary_dead_list[0]
	secondary_dead_list.pop_front()
	b.call_func = "fire_secondary"
	b.evolutions = evolutions
	secondary_list.append(b)
	b.move(pos, dir)
	b.execute()

func _on_primary_timer_timeout():
	allow_primary = true
	
func _on_secondary_timer_timeout():
	allow_secondary = true

func clean_lists():
	var removals = []
	for i in range(primary_list.size()):
		if not primary_list[i].active:
			removals.push_back(i)
			primary_dead_list.push_back(primary_list[i])
	for i in range(removals.size()):
		primary_list.remove(removals[i])
	removals.clear()
	for i in range(secondary_list.size()):
		if not secondary_list[i].active:
			removals.push_back(i)
			secondary_dead_list.push_back(secondary_list[i])
	for i in range(removals.size()):
		secondary_list.remove(removals[i])
