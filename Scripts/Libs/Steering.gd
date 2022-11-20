extends Node

const MASS=2.0

static func follow(velocity: Vector2, global_position: Vector2, target_position: Vector2,speed:int, mass=MASS)->Vector2:
	var desired_velocity = (target_position-global_position).normalized()*speed
	var steering = (desired_velocity-velocity)/mass
	
	
	return velocity+steering

static func arrive_to(velocity: Vector2, global_position: Vector2, target_position: Vector2,speed:int, radius:int, mass=MASS)->Vector2:
	var to_target = global_position.distance_to(target_position)
	var desired_velocity = (target_position-global_position).normalized()*speed
	
	if to_target < radius:
		desired_velocity *= (to_target/radius)*0.8+0.2
	
	var steering = (desired_velocity-velocity)/mass
	
	
	return velocity+steering
