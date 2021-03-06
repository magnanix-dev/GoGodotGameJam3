extends Spatial
class_name Generator

export var size = Vector2(30, 30)
export var cell_size = 32

export var pickups_total = 3
export var pickups_distance = 10

export var ground_maximum = 110
export var ground_minimum = 70

export var walkers_maximum = 5
export var walkers_create_chance = 0.02
export var walkers_delete_chance = 0.01
export var walkers_distance = 5
export var walkers_2x_chance = 0.25
export var walkers_3x_chance = 0.0

export var enemy_spawn_chance = 0.11
export var enemy_spawn_minimum = 10
export var enemy_spawn_distance = 10

export var outside_environmental_spawn_chance = 0.05
export var inside_environmental_spawn_chance = 0.05

export var world_material : SpatialMaterial
export var texture_width = 8
export var tile_type_texture = {"ground": 0,"ceiling": 1,"wall": 2}
var texture_tilesize = 1.0 / texture_width

enum tile {ground, ceiling, none}
var grid
var center_point : Vector2
var spawn_point : Vector2
var spawn_dir : Vector2
var exit_point : Vector2
var exit_dir : Vector2
var pickup_points : Array
var enemy_spawn_points : Array
var environmental_inside_spawn_points : Array
var environmental_outside_spawn_points : Array

onready var meshes = $Mesh
#onready var global_light = $DirectionalLight
var gridmap : GridMap

var generate = true
var generate_failed = false

func _ready():
	pass

func _reset():
	generate = true
	generate_failed = false
	grid = []
#	center_point = Vector2.ZERO
#	spawn_point = Vector2.ZERO
#	spawn_dir = Vector2.ZERO
#	exit_point = Vector2.ZERO
#	exit_dir = Vector2.ZERO
	pickup_points = []
	enemy_spawn_points = []
	environmental_inside_spawn_points = []
	environmental_outside_spawn_points = []

func initialize():
	_reset()
	yield(generate_map(), "completed")
	find_center_point()
	find_spawn_point()
	find_pickup_points()
	find_enemy_spawn_points()
	find_environmental_spawn_points()
	# Sanity Checks:
	if enemy_spawn_points.size() < enemy_spawn_minimum || pickup_points.size() < pickups_total || not spawn_point || not exit_point || not center_point || grid[spawn_point.x][spawn_point.y] != tile.ground || grid[exit_point.x][exit_point.y] != tile.ground:
		generate_failed = true
	if not generate_failed:
		var build_meshes = build_map()
		if build_meshes.size():
			generate_mesh(build_meshes[0], build_meshes[1], build_meshes[2], world_material)
		#generate_tilemap()
		yield(get_tree(), "idle_frame")
		#generate_lightmaps()
	else:
		yield(initialize(), "completed")
		yield(get_tree(), "idle_frame")

func generate_tilemap():
	for x in range(size.x):
		for y in range(size.y):
			if grid[x][y] == tile.ground: gridmap.set_cell_item(x, 0, y, 1)
			if grid[x][y] == tile.ceiling: gridmap.set_cell_item(x, 0, y, 0)

func generate_map():
	generate = true
	grid = array2d(size.x, size.y, tile.none)
	var midpoint = Vector2(ceil(size.x/2), ceil(size.y/2))
	var walkers = []
	var removal = []
	var iterations = 0
	# Initial Walker:
	walkers.append(Walker.new(midpoint, Vector2(1, size.x-2), Vector2(1, size.y-2), walkers_distance))
	while generate:
		iterations += 1
		for w in walkers:
			var p = w.step()
			if p:
				grid[p.x][p.y] = tile.ground
				if randf() <= walkers_2x_chance:
					make_2x_room(w)
				if randf() <= walkers_3x_chance:
					make_3x_room(w)
				if randf() <= walkers_create_chance and walkers.size() < walkers_maximum:
					walkers.append(Walker.new(p, Vector2(1, size.x-2), Vector2(1, size.y-2), walkers_distance))
				if randf() <= walkers_delete_chance:
					removal.append(w)
			else:
				removal.append(w)
		if removal.size():
			for w in removal:
				walkers.erase(w)
				make_2x_room(w)
				w.queue_free()
			removal.clear()
		if count_ground() >= ground_maximum or walkers.size() <= 0:
			generate = false
	if not generate and walkers.size():
		for w in walkers:
			make_2x_room(w)
			w.queue_free()
		walkers.clear()
	if count_ground() <= ground_minimum:
		yield(generate_map(), "completed")
	var _x = Vector2(-1, -1)
	var _y = Vector2(-1, -1)
	for x in range(1, size.x-1):
		for y in range(1, size.y-1):
			if grid[x][y] != tile.none:
				if x <= _x.x or _x.x == -1: _x.x = x
				if x >= _x.y or _x.y == -1: _x.y = x
				if y <= _y.x or _y.x == -1: _y.x = y
				if y >= _y.y or _y.y == -1: _y.y = y
	var xdiff = floor((size.x - (_x.y - _x.x))/2) - _x.x
	var ydiff = floor((size.y - (_y.y - _y.x))/2) - _y.x
	var regrid = array2d(size.x, size.y, tile.ceiling)
	for x in range(1, size.x-1):
		for y in range(1, size.y-1):
			if grid[x][y] != tile.none:
				regrid[xdiff+x][ydiff+y] = grid[x][y]
	grid = regrid
	yield(get_tree(), "idle_frame")

func make_2x_room(w):
	if not w.out_of_bounds(Vector2(w.pos.x-1, w.pos.y-1)):
		grid[w.pos.x-1][w.pos.y-1] = tile.ground
	if not w.out_of_bounds(Vector2(w.pos.x, w.pos.y-1)):
		grid[w.pos.x][w.pos.y-1] = tile.ground
	if not w.out_of_bounds(Vector2(w.pos.x-1, w.pos.y)):
		grid[w.pos.x-1][w.pos.y] = tile.ground

func make_3x_room(w):
	if not w.out_of_bounds(Vector2(w.pos.x-1, w.pos.y-1)):
		grid[w.pos.x-1][w.pos.y-1] = tile.ground
	if not w.out_of_bounds(Vector2(w.pos.x, w.pos.y-1)):
		grid[w.pos.x][w.pos.y-1] = tile.ground
	if not w.out_of_bounds(Vector2(w.pos.x+1, w.pos.y-1)):
		grid[w.pos.x+1][w.pos.y-1] = tile.ground
	if not w.out_of_bounds(Vector2(w.pos.x-1, w.pos.y)):
		grid[w.pos.x-1][w.pos.y] = tile.ground
	if not w.out_of_bounds(Vector2(w.pos.x+1, w.pos.y)):
		grid[w.pos.x+1][w.pos.y] = tile.ground
	if not w.out_of_bounds(Vector2(w.pos.x-1, w.pos.y+1)):
		grid[w.pos.x-1][w.pos.y+1] = tile.ground
	if not w.out_of_bounds(Vector2(w.pos.x, w.pos.y+1)):
		grid[w.pos.x][w.pos.y+1] = tile.ground
	if not w.out_of_bounds(Vector2(w.pos.x+1, w.pos.y+1)):
		grid[w.pos.x+1][w.pos.y+1] = tile.ground

func find_center_point():
	var start = Vector2(floor(size.x/2), floor(size.y/2))
	var end = start
	var found = false
	var offset = 0
	while not found:
		for n in range(-offset, offset):
			if start.x+n <= 0 || start.x+n >= size.x:
				found = true
				break
			if grid[start.x+n][start.y+n] == tile.ground:
				found = true
				end = Vector2(start.x+n, start.y+n)
				break
		offset += 1
	center_point = end

func find_spawn_point():
	var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	dirs.shuffle()
	var dir = dirs.pop_front()
	var found = false
	var pos = center_point
	var end = pos
	while not found:
		if pos.x+dir.x <= 0 || pos.x+dir.x >= size.x || pos.y+dir.y <= 0 || pos.y+dir.y >= size.y:
			found = true
			break
		pos = pos + dir
		if grid[pos.x][pos.y] == tile.ceiling:
			found = true
			end = pos - dir
			break
	spawn_point = end
	spawn_dir = dir
	dir *= -1
	found = false
	pos = center_point
	end = pos
	while not found:
		if pos.x+dir.x <= 0 || pos.x+dir.x >= size.x || pos.y+dir.y <= 0 || pos.y+dir.y >= size.y:
			found = true
			break
		pos = pos + dir
		if grid[pos.x][pos.y] == tile.ceiling:
			found = true
			end = pos - dir
			break
	if end.distance_to(spawn_point) > 4:
		exit_point = end
		exit_dir = dir

func find_pickup_points():
	var tiles = []
	var removals = []
	var viable_tiles = []
	for x in range(0, size.x-1):
		for y in range(0, size.y-1):
			if grid[x][y] == tile.ground:
				var wallcount = 0
				if grid[x+1][y] == tile.ceiling: wallcount += 1
				if grid[x-1][y] == tile.ceiling: wallcount += 1
				if grid[x][y+1] == tile.ceiling: wallcount += 1
				if grid[x][y-1] == tile.ceiling: wallcount += 1
				if wallcount <= 1: tiles.append([Vector2(x, y).distance_squared_to(spawn_point), Vector2(x,y)])
	for n in range(pickups_total):
		tiles.sort_custom(self, "sort_by_distance")
		var tile = tiles.pop_front()
		viable_tiles.append(tile[1])
		for t in tiles:
			if t[1].distance_squared_to(tile[1]) <= pickups_distance:
				removals.append(t)
		if removals.size() > 0:
			for r in removals:
				tiles.erase(r)
	pickup_points = viable_tiles

func find_enemy_spawn_points():
	var tiles = []
	var viable_tiles = []
	for x in range(0, size.x-1):
		for y in range(0, size.y-1):
			if grid[x][y] == tile.ground:
				tiles.append(Vector2(x,y))
	var iterations = 0
	while viable_tiles.size() < enemy_spawn_minimum and iterations < 100:
		if viable_tiles.size() >= enemy_spawn_minimum:
			break
		for t in tiles:
			if t.distance_squared_to(spawn_point) >= enemy_spawn_distance and randf() <= enemy_spawn_chance:
				viable_tiles.append(t)
		iterations += 1
	enemy_spawn_points = viable_tiles

func find_environmental_spawn_points():
	var tiles = []
	var inside_tiles = []
	var outside_tiles = []
	for x in range(0, size.x-1):
		for y in range(0, size.y-1):
			tiles.append({"x": x, "y": y, "type": grid[x][y]})
	tiles.shuffle()
	for t in tiles:
		if t.type == tile.ground:
			if randf() <= inside_environmental_spawn_chance:
				inside_tiles.append(Vector2(t.x,t.y))
		if t.type == tile.ceiling:
			if randf() <= outside_environmental_spawn_chance:
				outside_tiles.append(Vector2(t.x,t.y))
	environmental_inside_spawn_points = inside_tiles
	environmental_outside_spawn_points = outside_tiles
	

func sort_by_distance(a, b):
	if a[0] > b[0]:
		return true
	return false

func visualize_points():
	var center = MeshInstance.new()
	center.mesh = CubeMesh.new()
	center.mesh.size = Vector3(1, 1, 1)
	center.translation = Vector3(center_point.x+0.5, 0.625, center_point.y+0.5)
	var m = SpatialMaterial.new()
	m.albedo_color = Color.green
	center.set_surface_material(0, m)
	meshes.add_child(center)
	var spawn = MeshInstance.new()
	spawn.mesh = CubeMesh.new()
	spawn.mesh.size = Vector3(1, 1, 1)
	spawn.translation = Vector3(spawn_point.x+0.5, 0.75, spawn_point.y+0.5)
	m = SpatialMaterial.new()
	m.albedo_color = Color.blue
	spawn.set_surface_material(0, m)
	meshes.add_child(spawn)
	for p in pickup_points:
		var pickup = MeshInstance.new()
		pickup.mesh = CubeMesh.new()
		pickup.mesh.size = Vector3(1, 1, 1)
		pickup.translation = Vector3(p.x+0.5, 0.825, p.y+0.5)
		m = SpatialMaterial.new()
		m.albedo_color = Color.red
		pickup.set_surface_material(0, m)
		meshes.add_child(pickup)

func build_map():
	# Potention Change: Do a search through verts[] for existing Vec3s, if there - change the index provided to indices - in an attempt to merge the quads into a solid mesh.
	var verts = PoolVector3Array()
	var uvs = PoolVector2Array()
	var normals = PoolVector3Array()
	var ground_uvs = calc_uv(tile_type_texture["ground"])
	var ceiling_uvs = calc_uv(tile_type_texture["ceiling"])
	var wall_uvs = calc_uv(tile_type_texture["wall"])
	
	for x in range(0, size.x-1):
		for y in range(0, size.y-1):
			match grid[x][y]:
				tile.ground:
					var z = 0
					verts.append(Vector3(x, z, y))
					normals.append(Vector3.UP)
					verts.append(Vector3(x + 1, z, y))
					normals.append(Vector3.UP)
					verts.append(Vector3(x + 1, z, y + 1))
					normals.append(Vector3.UP)
					verts.append(Vector3(x, z, y + 1))
					normals.append(Vector3.UP)
					uvs.append(ground_uvs[0])
					uvs.append(ground_uvs[1])
					uvs.append(ground_uvs[2])
					uvs.append(ground_uvs[3])
				tile.ceiling:
					var z = 1
					var z_height = 1
					verts.append(Vector3(x, z, y))
					normals.append(Vector3.UP)
					verts.append(Vector3(x + 1, z, y))
					normals.append(Vector3.UP)
					verts.append(Vector3(x + 1, z, y + 1))
					normals.append(Vector3.UP)
					verts.append(Vector3(x, z, y + 1))
					normals.append(Vector3.UP)
					uvs.append(ceiling_uvs[0])
					uvs.append(ceiling_uvs[1])
					uvs.append(ceiling_uvs[2])
					uvs.append(ceiling_uvs[3])
					if grid[x][y-1] == tile.ground:
						verts.append(Vector3(x + 1, z - z_height, y))
						normals.append(Vector3.FORWARD)
						verts.append(Vector3(x + 1, z, y))
						normals.append(Vector3.FORWARD)
						verts.append(Vector3(x, z, y))
						normals.append(Vector3.FORWARD)
						verts.append(Vector3(x, z - z_height, y))
						normals.append(Vector3.FORWARD)
						uvs.append(wall_uvs[0])
						uvs.append(wall_uvs[1])
						uvs.append(wall_uvs[2])
						uvs.append(wall_uvs[3])
					if grid[x][y+1] == tile.ground:
						verts.append(Vector3(x, z - z_height, y + 1))
						normals.append(Vector3.BACK)
						verts.append(Vector3(x, z, y + 1))
						normals.append(Vector3.BACK)
						verts.append(Vector3(x + 1, z, y + 1))
						normals.append(Vector3.BACK)
						verts.append(Vector3(x + 1, z - z_height, y + 1))
						normals.append(Vector3.BACK)
						uvs.append(wall_uvs[0])
						uvs.append(wall_uvs[1])
						uvs.append(wall_uvs[2])
						uvs.append(wall_uvs[3])
					if grid[x-1][y] == tile.ground:
						verts.append(Vector3(x, z - z_height, y))
						normals.append(Vector3.RIGHT)
						verts.append(Vector3(x, z, y))
						normals.append(Vector3.RIGHT)
						verts.append(Vector3(x, z, y + 1))
						normals.append(Vector3.RIGHT)
						verts.append(Vector3(x, z - z_height, y + 1))
						normals.append(Vector3.RIGHT)
						uvs.append(wall_uvs[0])
						uvs.append(wall_uvs[1])
						uvs.append(wall_uvs[2])
						uvs.append(wall_uvs[3])
					if grid[x+1][y] == tile.ground:
						verts.append(Vector3(x + 1, z - z_height, y + 1))
						normals.append(Vector3.LEFT)
						verts.append(Vector3(x + 1, z, y + 1))
						normals.append(Vector3.LEFT)
						verts.append(Vector3(x + 1, z, y))
						normals.append(Vector3.LEFT)
						verts.append(Vector3(x + 1, z - z_height, y))
						normals.append(Vector3.LEFT)
						uvs.append(wall_uvs[0])
						uvs.append(wall_uvs[1])
						uvs.append(wall_uvs[2])
						uvs.append(wall_uvs[3])
	
	return [verts, uvs, normals]

func generate_mesh(verts, uvs, normals, material = null):
	var mesh_instance = MeshInstance.new()
	var mesh = ArrayMesh.new()

	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	
	var tangents = PoolRealArray()
	var indices = PoolIntArray()
	for n in range(0, verts.size(), 4):
		indices.append(n)
		indices.append(n+2)
		indices.append(n+3)
		indices.append(n)
		indices.append(n+1)
		indices.append(n+2)
	#for n in range(0, verts.size()):
	#	tangents.append_array([-1,0,0,1])

	# Assign arrays to mesh array.
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_NORMAL] = normals
	#arr[Mesh.ARRAY_TANGENT] = tangents
	arr[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	mesh_instance.mesh = mesh
	if material != null: mesh_instance.material_override = material
	mesh_instance.create_trimesh_collision()
	mesh_instance.visible = true
	mesh_instance.use_in_baked_light = true
	meshes.add_child(mesh_instance)
	mesh_instance.owner = $"."

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

func generate_lightmaps():
	var gi_probe := GIProbe.new()
	gi_probe.name = "GI_Probe"
	gi_probe.global_transform.origin = Vector3(center_point.x, 0, center_point.y)
	gi_probe.set_extents(Vector3(size.x * 1.5, size.x+size.y, size.y * 1.5))
	add_child(gi_probe)
	gi_probe.bake()

func calc_uv(tile_id):
	var row = tile_id / texture_width
	var col = tile_id % texture_width
	
	var border_offset = 0.025
	
	return [
		texture_tilesize * Vector2(col + border_offset, row + border_offset),
		texture_tilesize * Vector2(col + border_offset, row + 1 - border_offset),
		texture_tilesize * Vector2(col + 1 - border_offset, row + border_offset),
		texture_tilesize * Vector2(col + 1 - border_offset, row + 1 - border_offset),
	]
