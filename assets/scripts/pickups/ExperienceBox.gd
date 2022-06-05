extends Spatial

export var exp_drops = 20

onready var mesh = $Mesh
onready var animation = $Mesh/AnimationPlayer
onready var collider = $Collider
onready var hitbox_collider = $HitBox/HitBoxCollider
onready var pickup_collider = $Pickup/PickupCollider

var open = false

func _physics_process(delta):
	if not open:
		mesh.rotate_y(0.7 * delta)

func hit(point, force, damage):
	animation.play("HideEXP")

func pickup(user):
	animation.play("HideEXP")

func open():
	open = true
	var exp_value = Global.experience_value() * 3
	for n in exp_drops:
		var val = (exp_value / exp_drops) * 1.0
		var xp = Global.get_exp_object()
		xp.value = val
		xp.global_transform.origin = global_transform.origin
	collider.disabled = true
	pickup_collider.disabled = true
	hitbox_collider.disabled = true
