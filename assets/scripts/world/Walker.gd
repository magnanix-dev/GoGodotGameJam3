extends Node
class_name Walker

export var viable_directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
export var turn_chance = 0.25
export var max_dist = 10

var x = {"min": 0, "max": 30}
var y = {"min": 0, "max": 30}
var pos = Vector2.ZERO
var dir = Vector2.RIGHT
var steps = []
var dist = 0

func _init(start, size_x, size_y):
	x.min = size_x.x
	x.max = size_x.y
	y.min = size_y.x
	y.max = size_y.y
	assert(not out_of_bounds(start))
	pos = start

func step():
	if randf() <= turn_chance or dist >= max_dist:
		change_direction()
	var target = pos + dir
	if not out_of_bounds(target):
		dist += 1
		pos = target
		return pos
	else:
		change_direction()
		step()

func change_direction():
	dist = 0
	var directions = viable_directions.duplicate()
	directions.erase(dir)
	directions.shuffle()
	dir = directions.pop_front()
	while out_of_bounds(pos + dir):
		dir = directions.pop_front()

func out_of_bounds(target):
	var _x = target.x
	var _y = target.y
	if _x < x.min || _x > x.max || _y < y.min || _y > y.max:
		return true
	else:
		return false
