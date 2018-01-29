extends Node

#game settings
var version=0.0008
var game_over=false
var score=0
var level=0
var paused=false
var current_scene=null
var new_scene=null

#player
var shield_max=50
var shield_regen=10
var bullet_damage=10

#enemy
var enemy_health=30
var enemy_bullet_damage=25
var enemy_points=100
#asteroid
var break_pattern = {'big': 'med',
					 'med': 'sm',
					 'sm': 'tiny',
					 'tiny': null}

var ast_damage = {'big': 40,
					 'med': 20,
					 'sm': 15,
					 'tiny': 10}
					
var ast_points = {'big': 10,
					 'med': 15,
					 'sm': 20,
					 'tiny': 40}
					

func _ready():
	var root=get_tree().get_root() #root is always viewport
	current_scene=root.get_child(root.get_child_count()-1)#get main
func goto_scene(path):
	var s=ResourceLoader.load(path)
	new_scene=s.instance()
	get_tree().get_root().add_child(new_scene)#adding to root(viewport)new child-new scene
	get_tree().set_current_scene(new_scene)#set current -sets new scene to current ones(which is var upper)
	current_scene.queue_free() #cleaning old var
	current_scene=new_scene #setting nulled cur_scene to new loaded scene

func new_game():
	game_over=false
	score=0
	level=0
	goto_scene("res://scenes/main.tscn")
#Errors
func fcheck(filepath):
	var file2check=File.new() #to check existence of files (textures for hud bars)
	if !file2check.file_exists(filepath):
		terror()
		return false
	else:
		return true
func terror():
	print ("Error loading texture")
	get_tree().quit()
	return false