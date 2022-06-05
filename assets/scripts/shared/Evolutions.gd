extends Node
#class_name Evolutions

var evolutions = {
	"sequence": {
		"active": false, 
		"possible": ["primary", "secondary"],
		"count": 2, 
		"delay": 0.5,
		"title": "Sequence",
		"details": "Relics will deploy sequentially.",
		"increment": {"count": 1, "delay": -0.05}
	},
	"burst": {
		"active": false, 
		"possible": ["primary", "secondary"],
		"count": 1,
		"spread": 10,
		"title": "Buckshot",
		"details": "Relics will deploy shells.",
		"increment": {"count": 3}
	},
	"bounce": {
		"active": false, 
		"possible": ["primary", "secondary"],
		"count": 0,
		"title": "Bounce",
		"details": "Relics bounce off hit surfaces.",
		"increment": {"count": 1}
	},
	"pierce": {
		"active": false, 
		"possible": ["primary", "secondary"],
		"count": 0,
		"title": "Pierce",
		"details": "Relics pierce soft targets.",
		"increment": {"count": 1}
	},
	"charge": {
		"active": false, 
		"possible": ["primary", "secondary"],
		"incompatible": ["auto", "charge"],
		"limit": 0, 
		"multiplier": 1, 
		"scale": 0.75,
		"title": "Charge",
		"details": "Hold fire to charge relic damage!",
		"increment": {"limit": 0.5, "multiplier": 0.5, "scale": 0.0}
	},
	"auto": {
		"active": false,
		"possible": ["primary", "secondary"],
		"incompatible": ["charge", "auto"],
		"title": "Full Auto",
		"details": "Hold fire and the relic never stops shooting!"
	},
	"hefty": {
		"active": false,
		"possible": ["primary", "secondary", "player"],
		"count": 0,
		"title": "Hefty",
		"details": "Increases the relic damage, or health.",
		"increment": {"count": 1}
	},
	"slim": {
		"active": false,
		"possible": ["primary", "secondary", "player"],
		"count": 0,
		"title": "Slim",
		"details": "Increases the relic speed.",
		"increment": {"count": 1}
	}
}

func get_random_evolution(type = "primary"):
	var incompatible = []
	var check_evolutions = []
	var check_behaviours = []
	match type:
		"primary":
			check_evolutions = Global.primary_evolutions
			check_behaviours = Global.player_settings.primary_settings.behaviours
		"secondary":
			check_evolutions = Global.secondary_evolutions
			check_behaviours = Global.player_settings.secondary_settings.behaviours
	if check_evolutions != null:
		for x in check_evolutions:
			var _x = check_evolutions[x]
			if _x.active and _x.has("incompatible"):
				incompatible.append_array(_x.incompatible)
	if check_behaviours != null:
		for x in check_behaviours:
			var behaviour = x[0]
			if evolutions[behaviour].has("incompatible"):
				incompatible.append(behaviour)
				incompatible.append_array(evolutions[behaviour].incompatible)
	var _e = null
	var evo = []
	for e in evolutions:
		var evolution = evolutions[e]
		if evolution.possible.has(type) and not incompatible.has(e):
			evo.append([e, evolution])
	if evo.size():
		evo.shuffle()
		_e = evo.pop_front()
	return _e # Array (name, evolution)
