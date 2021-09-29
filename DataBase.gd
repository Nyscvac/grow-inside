extends Node

var sound = preload("res://scenes/other/play_audio.tscn") 

var weapons = {
	0 : {
		"id" : 0,
		"icon" : "res://sprites/wep1.png",
		"name" : "Energy rifle",
		"scene" : "res://scenes/weapons/wep1.tscn"
		},
	1 : {
		"id" : 1,
		"icon" : "res://sprites/wep2.png",
		"name" : "heavy_pistol",
		"scene" : "res://scenes/weapons/wep2.tscn"
		},
	2 : {
		"id" : 2,
		"icon" : "res://sprites/enemy_3_ready.png",
		"name" : "heavy_pistol",
		"scene" : "res://scenes/weapons/wep3.tscn"
		}
}

var entities = {
	0 : {
		"id" : 0,
		"icon" : "res://sprites/bullet1.png",
		"name" : "bullet1",
		"scene" : "res://scenes/entities/bullet1.tscn"
		},
	1 : {
		"id" : 1,
		"icon" : "res://sprites/enemy_shot.png",
		"name" : "enemy_bullet",
		"scene" : "res://scenes/entities/enemy_shot.tscn"
		},
	2 : {
		"id" : 2,
		"icon" : "res://sprites/bullet2.png",
		"name" : "bullet2",
		"scene" : "res://scenes/entities/bullet2.tscn"
		},
	3 : {
		"id" : 3,
		"icon" : "res://sprites/emptyItemSign.png",
		"name" : "item_drop",
		"scene" : "res://scenes/other/item_drop.tscn"
		},
	4 : {
		"id" : 4,
		"icon" : "res://sprites/player_stand",
		"name" : "player",
		"scene" : "res://scenes/entities/player.tscn"
		} 
}

var locations = {
	0 : {
		"id" : 0,
		"name" : "jungle",
		"scene" : "res://scenes/levels/level_jungle.tscn"
		}
}

var resources = {
	0 : {
		"id" : 0,
		"icon" : "res://sprites/seed1.png",
		"name" : "common_seed",
		"scene" : "res://scenes/entities/bullet2.tscn",
		"stack_size" : 99
		}
}

var accessories = {
	0 : {
		"id" : 0,
		"icon" : "res://sprites/rebar_boots.png",
		"name" : "rebar_boots",
		"scene" : "res://scenes/entities/bullet2.tscn",
		}
}

var enemies = {
	0 : {
		0 : {
			"id" : 0,
			"name" : "bot_fly",
			"scene" : "res://scenes/enemies/fly_bot.tscn"
			},
		
		1 : {
			"id" : 1,
			"name" : "metal_worm",
			"scene" : "res://scenes/enemies/enemy2.tscn"
			},
		
		2 : {
			"id" : 2,
			"name" : "iron",
			"scene" : "res://scenes/enemies/enemy_3.tscn"
			},
		3 : {
			"id" : 3,
			"name" : "wide_fly_bot",
			"scene" : "res://scenes/enemies/enemy4.tscn"
			},
		4 : {
			"id" : 4,
			"name" : "lil_fatty",
			"scene" : "res://scenes/enemies/enemy5.tscn"
			}
		}
}

var item_actions = {
	"accessories" : ["equip", "delete", "info"],
	"resources" : ["delete", "info"],
	"weapons" : ["equip", "delete"]  
	
}
var item_actions_hub = {
	"accessories" : ["equip", "delete", "put", "info"], 
	"resources" : ["delete", "put", "info"],
	"weapons" : ["equip", "delete", "put", "info"]  
	
}

