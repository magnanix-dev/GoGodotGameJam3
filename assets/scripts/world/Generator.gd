extends Node
class_name Generator

export var size = Vector2(30, 30)
export var cell_size = 32

export var ground_maximum = 110

export var walkers_maximum = 5
export var walkers_create_chance = 0.1
export var walkers_delete_chance = 0.1
export var walkers_2x_chance = 0.5
export var walkers_3x_chance = 0.0


enum tile {ground, wall, none}
var grid

var generate = true

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(generate_map(), "completed")
	print("Completed!")

func generate_map():
	grid = array2d(size.x, size.y, tile.none)
	var midpoint = Vector2(ceil(size.x/2), ceil(size.y/2))
	var walkers = []
	var removal = []
	var iterations = 0
	# Initial Walker:
	walkers.append(Walker.new(midpoint, Vector2(0, size.x), Vector2(0, size.y)))
	while generate:
		iterations += 1
		for w in walkers:
			var p = w.step()
			grid[p.x][p.y] = tile.ground
			if randf() <= walkers_create_chance and walkers.size() < walkers_maximum:
				walkers.append(Walker.new(p, Vector2(0, size.x), Vector2(0, size.y)))
			if randf() <= walkers_delete_chance:
				removal.append(w)
		if removal.size():
			for w in removal:
				walkers.erase(w)
				w.queue_free()
			removal.clear()
		if count_ground() >= ground_maximum:
			generate = false
	if not generate and walkers.size():
		for w in walkers:
			w.queue_free()
		walkers.clear()
	print(iterations)
	yield(get_tree(), "idle_frame")

func count_ground():
	var ground_count = 0
	for x in size.x:
		for y in size.y:
			if grid[x][y] == tile.ground:
				ground_count += 1
	return ground_count

func array2d(w, h, v = false):
	var a = []
	for x in range(w):
		a.append([])
		a[x].resize(h)
		if v:
			for y in range(h):
				a[x][y] = v
	return a
