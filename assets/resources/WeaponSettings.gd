extends Resource
class_name WeaponSettings

export (String) var name = ""

export var speed : float
export var damage : float

export var speed_variance : float
export var direction_variance : float

export var object : PackedScene
export var hit_object : PackedScene
export var cooldown : float
export (Array, Array) var behaviours
