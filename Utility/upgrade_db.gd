extends Node


const ICON_PATH = "res://Textures/Items/Upgrades/"
const WEAPON_PATH = "res://Textures/Items/Weapons/"
const SKILL_PATH = "res://Textures/Items/Skills/"
const UPGRADE_PATH = "res://Textures/Items/Upgrades/"

const UPGRADES = {
	"icespear1": {
		"icon": SKILL_PATH + "TFT11_Item_InkshadowSnake.png",
		"displayname": "Verdant Arrow",
		"details": "A spear of ice is thrown at a random enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"icespear2": {
		"icon": SKILL_PATH + "TFT11_Item_InkshadowSnake.png",
		"displayname": "Verdant Arrow",
		"details": "An addition Verdant Arrow is thrown",
		"level": "Level: 2",
		"prerequisite": ["icespear1"],
		"type": "weapon"
	},
	"icespear3": {
		"icon": SKILL_PATH + "TFT11_Item_InkshadowSnake.png",
		"displayname": "Verdant Arrow",
		"details": "Verdant Arrows now pass through another enemy and do + 3 damage",
		"level": "Level: 3",
		"prerequisite": ["icespear2"],
		"type": "weapon"
	},
	"icespear4": {
		"icon": SKILL_PATH + "TFT11_Item_InkshadowSnake.png",
		"displayname": "Verdant Arrow",
		"details": "An additional 2 Verdant Arrows are thrown",
		"level": "Level: 4",
		"prerequisite": ["icespear3"],
		"type": "weapon"
	},
	"javelin1": {
		"icon": SKILL_PATH + "XerathArcaneBarrage2 copy.png",
		"displayname": "Wraith Grasp",
		"details": "A magical Wraith will follow you attacking enemies in a straight line",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"javelin2": {
		"icon": SKILL_PATH + "XerathArcaneBarrage2 copy.png",
		"displayname": "Wraith Grasp",
		"details": "The Wraith will now attack an additional enemy per attack",
		"level": "Level: 2",
		"prerequisite": ["javelin1"],
		"type": "weapon"
	},
	"javelin3": {
		"icon": SKILL_PATH + "XerathArcaneBarrage2 copy.png",
		"displayname": "Wraith Grasp",
		"details": "The Wraith will attack another additional enemy per attack",
		"level": "Level: 3",
		"prerequisite": ["javelin2"],
		"type": "weapon"
	},
	"javelin4": {
		"icon": SKILL_PATH + "XerathArcaneBarrage2 copy.png",
		"displayname": "Wraith Grasp",
		"details": "The Wraith now does + 5 damage per attack and causes 20% additional knockback",
		"level": "Level: 4",
		"prerequisite": ["javelin3"],
		"type": "weapon"
	},
	"tornado1": {
		"icon": SKILL_PATH + "TFT11_Item_InkshadowPig.png",
		"displayname": "Whisp",
		"details": "A Whisp is created and random heads somewhere in the players direction",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"tornado2": {
		"icon": SKILL_PATH + "TFT11_Item_InkshadowPig.png",
		"displayname": "Whisp",
		"details": "An additional Whisp is created",
		"level": "Level: 2",
		"prerequisite": ["tornado1"],
		"type": "weapon"
	},
	"tornado3": {
		"icon": SKILL_PATH + "TFT11_Item_InkshadowPig.png",
		"displayname": "Whisp",
		"details": "The Whisp cooldown is reduced by 0.5 seconds",
		"level": "Level: 3",
		"prerequisite": ["tornado2"],
		"type": "weapon"
	},
	"tornado4": {
		"icon": SKILL_PATH + "TFT11_Item_InkshadowPig.png",
		"displayname": "Whisp",
		"details": "An additional Whisp is created and the knockback is increased by 25%",
		"level": "Level: 4",
		"prerequisite": ["tornado3"],
		"type": "weapon"
	},
	"dash1": {
		"icon": SKILL_PATH + "YasuoW copy.png",
		"displayname": "Swift Escape",
		"details": "Increases dash distance by 50 units",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"dash2": {
		"icon": SKILL_PATH + "YasuoW copy.png",
		"displayname": "Swift Escape",
		"details": "Increases dash speed by 50 units and damage by 10",
		"level": "Level: 2",
		"prerequisite": ["dash1"],
		"type": "weapon"
	},
	"dash3": {
		"icon": SKILL_PATH + "YasuoW copy.png",
		"displayname": "Swift Escape",
		"details": "Reduces dash cooldown by 0.1 seconds",
		"level": "Level: 3",
		"prerequisite": ["dash2"],
		"type": "weapon"
	},
	"dash4": {
		"icon": SKILL_PATH + "YasuoW copy.png",
		"displayname": "Swift Escape",
		"details": "Further increases dash speed by 50 units and adds an additional knockback effect",
		"level": "Level: 4",
		"prerequisite": ["dash3"],
		"type": "weapon"
	},
	"slash1": {
		"icon": UPGRADE_PATH + "3864 copy.png",
		"displayname": "Razor Edge",
		"details": "Grants a basic slash attack with standard damage and range",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"slash2": {
		"icon": UPGRADE_PATH + "3864 copy.png",
		"displayname": "Razor Edge",
		"details": "Increases slash damage by 20 and range by 50 units",
		"level": "Level: 2",
		"prerequisite": ["slash1"],
		"type": "weapon"
	},
	"slash3": {
		"icon": UPGRADE_PATH + "3864 copy.png",
		"displayname": "Razor Edge",
		"details": "Further increases slash damage by 20 and reduces cooldown by 0.2 seconds",
		"level": "Level: 3",
		"prerequisite": ["slash2"],
		"type": "weapon"
	},
	"slash4": {
		"icon": UPGRADE_PATH + "3864 copy.png",
		"displayname": "Razor Edge",
		"details": "Adds a bleeding effect that deals damage over time",
		"level": "Level: 4",
		"prerequisite": ["slash3"],
		"type": "weapon"
	},
	"explosion1": {
		"icon": SKILL_PATH + "AurelionSolR copy.png",
		"displayname": "Detonate",
		"details": "Unleashes a basic explosion with set damage and radius",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"explosion2": {
		"icon": SKILL_PATH + "AurelionSolR copy.png",
		"displayname": "Detonate",
		"details": "Increases explosion radius by 50 units and damage by 10",
		"level": "Level: 2",
		"prerequisite": ["explosion1"],
		"type": "weapon"
	},
	"explosion3": {
		"icon": SKILL_PATH + "AurelionSolR copy.png",
		"displayname": "Detonate",
		"details": "Adds a stun effect to all enemies hit by the explosion",
		"level": "Level: 3",
		"prerequisite": ["explosion2"],
		"type": "weapon"
	},
	"explosion4": {
		"icon": SKILL_PATH + "AurelionSolR copy.png",
		"displayname": "Detonate",
		"details": "Further increases explosion damage by 20 and adds a fire effect that burns the area",
		"level": "Level: 4",
		"prerequisite": ["explosion3"],
		"type": "weapon"
	},
		"armor1": {
		"icon": ICON_PATH + "3105 copy.png",
		"displayname": "Armor",
		"details": "Reduces Damage By 1 point",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"armor2": {
		"icon": ICON_PATH + "3105 copy.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 2",
		"prerequisite": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "223068 copy.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 3",
		"prerequisite": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "223068 copy.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 4",
		"prerequisite": ["armor3"],
		"type": "upgrade"
	},
	"speed1": {
		"icon": ICON_PATH + "3005 copy.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by 50% of base speed",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "3005 copy.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 2",
		"prerequisite": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "3005 copy.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 3",
		"prerequisite": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "3005 copy.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased an additional 50% of base speed",
		"level": "Level: 4",
		"prerequisite": ["speed3"],
		"type": "upgrade"
	},
	"tome1": {
		"icon": ICON_PATH + "Ryze_P copy.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"tome2": {
		"icon": ICON_PATH + "Ryze_P copy.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 2",
		"prerequisite": ["tome1"],
		"type": "upgrade"
	},
	"tome3": {
		"icon": ICON_PATH + "Ryze_P copy.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 3",
		"prerequisite": ["tome2"],
		"type": "upgrade"
	},
	"tome4": {
		"icon": ICON_PATH + "Ryze_P copy.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 4",
		"prerequisite": ["tome3"],
		"type": "upgrade"
	},
	"scroll1": {
		"icon": ICON_PATH + "3865 copy.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"scroll2": {
		"icon": ICON_PATH + "3865 copy.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 2",
		"prerequisite": ["scroll1"],
		"type": "upgrade"
	},
	"scroll3": {
		"icon": ICON_PATH + "3865 copy.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 3",
		"prerequisite": ["scroll2"],
		"type": "upgrade"
	},
	"scroll4": {
		"icon": ICON_PATH + "3865 copy.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 4",
		"prerequisite": ["scroll3"],
		"type": "upgrade"
	},
	"ring1": {
		"icon": ICON_PATH + "1082 copy.png",
		"displayname": "Ring",
		"details": "Your spells now spawn 1 more additional attack",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"ring2": {
		"icon": ICON_PATH + "1082 copy.png",
		"displayname": "Ring",
		"details": "Your spells now spawn an additional attack",
		"level": "Level: 2",
		"prerequisite": ["ring1"],
		"type": "upgrade"
	},
	"food": {
		"icon": ICON_PATH + "226667 copy.png",
		"displayname": "Food",
		"details": "Heals you for 20 health",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	}
}

