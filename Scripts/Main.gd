extends Node

var start=false

var maxsize=0

func _ready():
	randomize()
	$hud/Score.hide()
	$Player.hide()
	$"hud/game over".hide()
	$hud/musique2.stop()
	$"hud/game over/musique2".stop()
	$hud/menu/musique.play()

func _process(delta):
	if start:
		if $Player.size>maxsize:
			maxsize=$Player.size
		$hud/Score.text="Taille    "+String($Player.size)

func _input(event):
	if start==false:
		if event is InputEventMouseButton:
			new_game()

func new_game():
	$Spawn.position=get_viewport().size/2
	$Player.start($Spawn.position)
	$Player.nb_sbire=0
	$Player.start=true
	$hud/Score.visible=true
	$hud/menu.hide()
	$"hud/game over".hide()
	$hud/menu/musique.stop()
	$"hud/game over/musique2".stop()
	$hud/musique2.play()
	start=true
	$StartTimer.start()



func _on_StartTimer_timeout():
	$MobTimer.start()


func _on_MobTimer_timeout():
	if int(rand_range(0,10)>=3):
		
		var mobload=load("res://Scenes/Victime.tscn")
		var mob=mobload.instance()
		var direction = $MobPath/MobSpawn.rotation + PI / 2
		$MobPath/MobSpawn.offset=randi()
		direction += rand_range(-PI / 4, PI / 4)
		mob.rotation = direction
		
		$MobPath/MobTarget.position = $Player.get_global_mouse_position()
		if($MobPath/MobSpawn.position.y<=get_viewport().size.y/2):
			$MobPath/MobTarget.position.y += get_viewport().size.y
		else:
			$MobPath/MobTarget.position.y -= get_viewport().size.y
		if($MobPath/MobSpawn.position.x<=get_viewport().size.x/2):
			$MobPath/MobTarget.position.x += get_viewport().size.x
		else:
			$MobPath/MobTarget.position.x -= get_viewport().size.x
		
		add_child(mob)
		mob.position=$MobPath/MobSpawn.position
		
		mob.nb_sbire=int(rand_range($Player.nb_sbire,$Player.nb_sbire+2))
		mob.createVic($MobPath/MobTarget)
		print(mob.position)
		print($MobPath/MobTarget.position)
		
	else:
		$MobTimer.start()


func gameover():
	$Player.start=false
	get_tree().call_group("Mob", "queue_free")
	$MobTimer.stop()
	$hud/menu.hide()
	$hud/Score.hide()
	if $Player.size>maxsize:
			maxsize=$Player.size
	$"hud/game over/Score2".text="Taille maximum atteinte   "+String(maxsize)
	$"hud/game over".visible=true
	$hud/musique2.stop()
	$hud/menu/musique.play()
	$"hud/game over/musique2".play()
	start=false
