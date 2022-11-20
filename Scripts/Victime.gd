extends KinematicBody2D


var target
var target_pos
const type:Array=["Petit","Moyen","Gros"]
const DISTANCE :=10
var _velocity : = Vector2.ZERO
export var follow_offset:=50

var count=0

export var max_speed : =200

onready var ready=false
var nb_sbire
var is_lead
var color
var default_size
var size
var cursor=false

func _ready():
	randomize()

func _physics_process(delta):
	if ready:
		if target==null && cursor==false :
			queue_free()
			return
		var target_global_position: Vector2
		var secure
		if cursor!=true :
			if is_lead:
				target_global_position=target_pos
				secure=10
			else :
				target_global_position=target.global_position
				secure=target.getBallsize()
		else :
			target_global_position=get_global_mouse_position() 
			secure=10
		
		var to_target = global_position.distance_to(target_global_position)
		if to_target<secure:
			return

		var follow_global_position: Vector2 = (
			target_global_position - (target_global_position - global_position).normalized() * follow_offset
			if to_target > follow_offset
			else global_position
			)
		if not(is_lead):
			size=target.size
		
		_velocity = Steering.arrive_to(
			_velocity,
			global_position,
			follow_global_position,
			max_speed,
			100,
			size*1.5
		)
		
		_velocity = move_and_slide(_velocity)
		$AnimatedSprite.rotation=_velocity.angle()
		
		if get_slide_count()>0 :
			var collision=get_slide_collision(0)
			var body =collision.collider
			if  cursor:
				col(body)
			elif(body.get_name()!="Player" && body.target!=self && body.target!=target):
				add_collision_exception_with(body)

func getBallsize()->int:
	if default_size==1:
		return 50
	elif default_size==2:
		return 70
	else:
		return 100

func createVic(boss):
	target=boss
	target_pos=boss.position
	is_lead = boss.get_name()=="MobTarget"
	
	if is_lead:
		if randi()%10 <=5:
			color="r"
		else:
			color="b"
		init_collisions()
		for i in range(0,nb_sbire):
			var sbireload=load("res://Scenes/Victime.tscn")
			var sbire=sbireload.instance()
			add_child(sbire)
			sbire.createSbire($".")
			var d=getBallsize()+i+5
			if position.x<=0:
				sbire.position.x-=d
			elif position.x>=get_viewport_rect().size.x+1:
				sbire.position.x+=d
			elif position.y<=0:
				sbire.position.y-=d
			elif position.y>=get_viewport_rect().size.y:
				sbire.position.y+=d
		
		for i in get_children():
			if i.is_in_group("Mob"):
				size+=i.size
				i.size=size
				i.ready=true
		ready=true

func createSbire(lead):
	color=lead.color
	createVic(lead)
	init_collisions()

#	initialisation collisions
func init_collisions():
	var s
	s = randi() % 100
	if s>=0 && s<50:
		s=0
	elif s>=50 && s<80:
		s=1
	else:
		s=0
	size=s+1
	default_size=s+1
	$AnimatedSprite.animation = color+String(size)
	$Petit.hide()
	$Petit.set_deferred("disabled", true)
	$Moyen.hide()
	$Moyen.set_deferred("disabled", true)
	$Gros.hide()
	$Gros.set_deferred("disabled", true)
	get_node(type[s]).show()
	get_node(type[s]).set_deferred("disabled", false)

func col(body):
	if body.is_in_group("Mob"):
		if body.cursor==false:
			var mob
			if body.is_lead:
				mob=body
			else:
				mob=body.target
			
			if mob.size<=target.size:
				var mobcol = get_collision_exceptions()
				for m in mobcol:
					remove_collision_exception_with(m)
				
				target.infect(mob)
				target.size+=mob.size
				mob.size=target.size
				target.nb_sbire+=1
			elif mob.color=="b" :
				target.size-=default_size
				target.nb_sbire-=1
				queue_free()

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
