extends Node

## Variables
const FILE_PATH = "res://Space_co-op_game/inventory-system/assets/items/meshes/"
enum item_type {Weapon, Consumable, Valuable, Ammunition}

## Items Templates
const items_templates = {
	"pistol" : {
		"id" : 0,
		"name" : "Pistol",
		"desc" : "Good pistol for shooting.",
		"item_type" : item_type.Weapon,
		"number" : 500,
		"automatic" : false,
	},
	"medkit" : {
		"id" : 1,
		"name" : "Med-Kit",
		"desc" : "Cool medkit",
		"item_type" : item_type.Consumable,
		"number" : 25,
	},
	"ammo" : {
		"id" : 2,
		"name" : "Ammunition",
		"desc" : "Universal ammunition for all weapons.",
		"item_type" : item_type.Ammunition,
		"number" : 30,
	},
}
