extends Resource
class_name PlayerSettings

export (String) var name = ""

export (PackedScene) var mesh
export (int) var health = 8

export (Resource) var primary_settings = null
export (Resource) var secondary_settings = null
export (Resource) var tertiary_settings = null
