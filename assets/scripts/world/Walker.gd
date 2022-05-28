extends Node
class_name Walker

export var can_reverse = true
export var turn_chance = 0.25
export var max_dist = 10

var x = {"min": 0, "max": 30}
var y = {"min": 0, "max": 30}
var pos = Vector2.ZERO
var dir = Vector2.RIGHT
var steps = []
var dist = 0
var direction = {
	Vector2.RIGHT: [Vector2.DOWN, Vector2.UP],
	Vector2.LEFT: [Vector2.UP, Vector2.DOWN],
	Vector2.UP: [Vector2.RIGHT, Vector2.LEFT],
	Vector2.DOWN: [Vector2.LEFT, Vector2.RIGHT],
}

func _init(start, size_x, size_y, distance):
	x.min = size_x.x
	x.max = size_x.y
	y.min = size_y.x
	y.max = size_y.y
	assert(not out_of_bounds(start))
	pos = start
	max_dist = distance

func step():
	if randf() <= turn_chance or dist >= max_dist:
		change_direction()
	var target = pos + dir
	#print(target.x, ", ", target.y)
	if not out_of_bounds(target):
		dist += 1
		pos = target
		return pos
	else:
		change_direction()
		step()

func change_direction():
	var turn = direction[dir].duplicate()
	if can_reverse: turn.append(dir * -1)
	turn.shuffle()
	dir = turn.pop_front()
	while out_of_bounds(pos + dir):
		dir = turn.pop_front()

func out_of_bounds(target):
	var _x = target.x
	var _y = target.y
	if _x <= x.min || _x >= x.max || _y <= y.min || _y >= y.max:
		return true
	else:
		return false
