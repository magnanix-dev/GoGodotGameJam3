extends Spatial
class_name Generator

export var size = Vector2(30, 30)
export var cell_size = 32

export var ground_maximum = 110
export var ground_minimum = 70

export var walkers_maximum = 5
export var walkers_create_chance = 0.02
export var walkers_delete_chance = 0.01
export var walkers_distance = 5
export var walkers_2x_chance = 0.5
export var walkers_3x_chance = 0.0

export var ground_material : SpatialMaterial
export var ceiling_material : SpatialMaterial
export var wall_material : SpatialMaterial

enum tile {ground, ceiling, none}
var grid

onready var meshes = $Mesh

var generate = true

# Called when the node enters the scene tree for the first time.
func _ready():
	#randomize()
	#VisualServer.set_debug_generate_wireframes(true)
	#get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	yield(generate_map(), "completed")
	print("Completed!")
	var build_meshes = build_map()
	if build_meshes.size():
		#for build in build_meshes:
		generate_mesh(build_meshes[0], ground_material)
		generate_mesh(build_meshes[1], wall_material)
		generate_mesh(build_meshes[2], ceiling_material)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

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
				if randf() <= walkers_create_chance and walkers.size() < walkers_maximum:
					walkers.append(Walker.new(p, Vector2(1, size.x-2), Vector2(1, size.y-2), walkers_distance))
				if randf() <= walkers_delete_chance:
					removal.append(w)
			else:
				removal.append(w)
		if removal.size():
			for w in removal:
				walkers.erase(w)
				w.queue_free()
			removal.clear()
		if count_ground() >= ground_maximum or walkers.size() <= 0:
			generate = false
	if not generate and walkers.size():
		for w in walkers:
			w.queue_free()
		walkers.clear()
	print("Iterations: ", iterations)
	print("Ground Count: ", count_ground())
	if count_ground() <= ground_minimum:
		print("Failed! - Restarting!")
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

func build_map():
	var ground_verts = PoolVector3Array()
	var wall_verts = PoolVector3Array()
	var ceiling_verts = PoolVector3Array()
	for x in range(0, size.x-1):
		for y in range(0, size.y-1):
			match grid[x][y]:
				tile.ground:
					var z = 0
					ground_verts.append(Vector3(x, z, y))
					ground_verts.append(Vector3(x + 1, z, y))
					ground_verts.append(Vector3(x + 1, z, y + 1))
					ground_verts.append(Vector3(x, z, y + 1))
				tile.ceiling:
					var z = 1
					ceiling_verts.append(Vector3(x, z, y))
					ceiling_verts.append(Vector3(x + 1, z, y))
					ceiling_verts.append(Vector3(x + 1, z, y + 1))
					ceiling_verts.append(Vector3(x, z, y + 1))
					if grid[x][y-1] == tile.ground:
						wall_verts.append(Vector3(x + 1, z - 1, y))
						wall_verts.append(Vector3(x + 1, z, y))
						wall_verts.append(Vector3(x, z, y))
						wall_verts.append(Vector3(x, z - 1, y))
					if grid[x][y+1] == tile.ground:
						wall_verts.append(Vector3(x, z - 1, y + 1))
						wall_verts.append(Vector3(x, z, y + 1))
						wall_verts.append(Vector3(x + 1, z, y + 1))
						wall_verts.append(Vector3(x + 1, z - 1, y + 1))
					if grid[x-1][y] == tile.ground:
						wall_verts.append(Vector3(x, z - 1, y))
						wall_verts.append(Vector3(x, z, y))
						wall_verts.append(Vector3(x, z, y + 1))
						wall_verts.append(Vector3(x, z - 1, y + 1))
					if grid[x+1][y] == tile.ground:
						wall_verts.append(Vector3(x + 1, z - 1, y + 1))
						wall_verts.append(Vector3(x + 1, z, y + 1))
						wall_verts.append(Vector3(x + 1, z, y))
						wall_verts.append(Vector3(x + 1, z - 1, y))
	
	return [ground_verts, wall_verts, ceiling_verts]

func generate_mesh(verts, material = null):
	var mesh_instance = MeshInstance.new()
	meshes.add_child(mesh_instance)
	var mesh = ArrayMesh.new()

	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	
	var uvs = PoolVector2Array()
	var normals = PoolVector3Array()
	var tangents = PoolRealArray()
	var indices = PoolIntArray()
	for n in range(0, verts.size(), 4):
		indices.append(n)
		indices.append(n+2)
		indices.append(n+3)
		indices.append(n)
		indices.append(n+1)
		indices.append(n+2)
		uvs.append(Vector2(0, 0))
		uvs.append(Vector2(1, 0))
		uvs.append(Vector2(1, 1))
		uvs.append(Vector2(0, 1))
	for n in range(0, verts.size()):
		normals.append(Vector3.UP)
		tangents.append_array([-1,0,0,1])

	# Assign arrays to mesh array.
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_TANGENT] = tangents
	arr[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	mesh_instance.mesh = mesh
	if material != null: mesh_instance.material_override = material
	#mesh_instance.create_trimesh_collision()
	#mesh_instance.visible = true

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
