package elmortem.game.cameras {
	import com.greensock.loading.data.VideoLoaderVars;
	import elmortem.game.entities.Entity;
	import elmortem.game.senses.ISense;
	import elmortem.game.Simulation;
	import elmortem.managers.EventManager;
	import elmortem.types.Vec2;
	import elmortem.utils.NumberUtils;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class Camera2D implements ISense, ICamera {
		static public const EVENT_STOP_FOLLOW_POINTS:String = "Camera2D.StopFollowPoints";
		
		private var sim:Simulation;
		
		private var pos:Vec2;
		private var to:Vec2;
		private var entity:Entity;
		private var points:Array;
		private var pointIdx:int;
		private var rect:Rectangle;
		
		private var vel_to:Vec2;
		private var vel:Vec2;
		private var vel_tmp:Vec2;
		private var speed:Number;
		private var accel:Number;
		
		private var zoom:Number;
		private var scale_now:Number;
		private var scale_to:Number;
		private var scale_speed:Number;
		
		private var width:Number;
		private var height:Number;
		private var width_half:Number;
		private var height_half:Number;
		
		private var is_moving:Boolean;
		
		public function Camera2D(sim:Simulation, width:Number, height:Number) {
			this.sim = sim;
			
			pos = new Vec2();
			to = new Vec2();
			entity = null;
			points = null;
			pointIdx = -1;
			rect = new Rectangle(0, 0, width, height);
			
			vel_to = new Vec2();
			vel = new Vec2();
			vel_tmp = new Vec2();
			speed = 0;
			accel = 1;
			
			zoom = 1;
			scale_now = scale_to = 1;
			scale_speed = 1;
			
			this.width = width;
			this.height = height;
			width_half = width * 0.5;
			height_half = height * 0.5;
			
			is_moving = false;
		}
		
		public function free():void {
			pos = null;
			to = null;
			entity = null;
			points = null;
			vel = null;
			vel_tmp = null;
			sim = null;
		}
		public function get senseName():String {
			return "camera";
		}
		public function update(delta:Number):void {
			delta *= 1.7;
			//
			if (!is_moving) return;
			if (entity != null) {
				if (!entity.alive) {
					entity = null;
					return;
				}
				//if (int(to.x) != int(pos.x) || int(to.y) != int(pos.y)) {
					move(entity.pos.x, entity.pos.y, speed, accel);
				//}
			} else if (points != null) {
				if (int(to.x) == int(pos.x) && int(to.y) == int(pos.y)) {
					pointIdx++;
					if (pointIdx >= points.length) {
						pointIdx = -1;
						points = null;
						EventManager.dispatch(sim, new Event(EVENT_STOP_FOLLOW_POINTS));
						return;
					} else {
						move(points[pointIdx].x, points[pointIdx].y, speed, accel);
						//trace("Camera.followPoints["+pointIdx+"]: ", points[pointIdx].x, points[pointIdx].y, to.x, to.y);
					}
				}
			}
			
			
			if(scale_now != scale_to) {
				scale_now = NumberUtils.approach(delta * scale_speed, scale_now, scale_to);
				//if (scale_now < 0.3) scale_now = -0.35;
				//else if (scale_now > -0.3) scale_now = 0.35;
				if(scale_now != 0) zoom = 1 / scale_now;
			}
			/*if (zoom != zoom_to) {
				move(to.x, to.y);
			}*/
			
			
			
			//vel.x = NumberUtils.approach(delta * 400, vel.x, vel_to.x);
			//vel.y = NumberUtils.approach(delta * 400, vel.y, vel_to.y);
			vel.x = vel_to.x;
			vel.y = vel_to.y;
			
			//trace("Camera2D.vel: "+vel+", vel_to: "+vel_to);
			
			//pos.x = to.x;
			//pos.y = to.y;
			if(points == null) {
				var d:Number = pos.distanceTo(to);
				//trace("Camera2D.d: " + d);
				vel_tmp.x = Math.max(vel.x, vel.x * d / width_half * 2.5);
				vel_tmp.y = Math.max(vel.y, vel.y * d / width_half * 2.5);
				//trace("Camera2D.vel_tmp: "+vel_tmp);
				//vel_tmp.x = vel.x;
				//vel_tmp.y = vel.y;
			} else {
				vel_tmp = vel;
			}
			pos.x = NumberUtils.approach(vel_tmp.x * delta, pos.x, to.x);
			pos.y = NumberUtils.approach(vel_tmp.y * delta, pos.y, to.y);
			/*vel.x *= accel;
			vel.y *= accel;
			if (int(pos.x) == int(to.x) && int(pos.y) == int(to.y)) {
				vel.x = vel_tmp.x;
				vel.y = vel_tmp.y;
			}*/
			if(entity == null && points == null) is_moving = false;
		}
		
		public function get target():Entity {
			return entity;
		}
		public function get isPointFollow():Boolean {
			return points != null;
		}
		public function get isMoving():Boolean {
			return is_moving;
		}
		public function set bounds(r:Rectangle):void {
			rect = r.clone();
		}
		public function get bounds():Rectangle {
			return rect;
		}
		public function get x():int {
			return pos.x;
		}
		public function get y():int {
			return pos.y;
		}
		public function get scale():Number {
			return scale_now;
		}
		public function get dirX():int {
			return NumberUtils.signZero(pos.x - to.x);
		}
		public function get dirY():int {
			return NumberUtils.signZero(pos.y - to.y);
		}
		
		public function getRect():Rectangle {
			return bounds;
		}
		
		public function startPoint(x:Number, y:Number):void {
			move(x, y, speed, accel);
			pos.x = to.x;
			pos.y = to.y;
		}
		public function move(x:Number, y:Number, speed:Number = -1, accel:Number = -1):void {
			to.setXY(x, y);
			to.x = Math.max(rect.left + width_half * zoom, to.x);
			to.x = Math.min(rect.right - width_half * zoom, to.x);
			to.y = Math.max(rect.top + height_half * zoom, to.y);
			to.y = Math.min(rect.bottom - height_half * zoom, to.y);
			to.x = -to.x;
			to.y = -to.y;
			//if (Math.abs(pos.x - to.x) < 150 && Math.abs(pos.y - to.y) < 150) {
			//	return;
			//}
			/*if (Math.abs(pos.x - to.x) < 15 && Math.abs(pos.y - to.y) < 15) {
				if (accel > 0) this.accel = accel;
				if (speed > 0) this.speed = speed;
				return;
			}*/
			
			if (accel > 0) this.accel = accel;
			if (speed > 0) {
				this.speed = speed;
				vel_to.x = to.x - pos.x;
				vel_to.y = to.y - pos.y;
				vel_to.normalize();
				vel_to.mult(speed);
				if (vel_to.x < 0) vel_to.x = -vel_to.x;
				if (vel_to.y < 0) vel_to.y = -vel_to.y;
				//vel_tmp.x = vel.x;
				//vel_tmp.y = vel.y;
			}
			
			is_moving = true;
		}
		public function follow(entity:Entity, speed:Number = -1, accel:Number = -1):void {
			points = null;
			if (entity != null && !entity.alive) entity = null;
			this.entity = entity;
			if (this.entity != null) is_moving = true;
			else is_moving = false;
			
			if (is_moving) {
				move(entity.pos.x, entity.pos.y, speed, accel);
			}
		}
		public function followPoints(points:Array, speed:Number = -1, accel:Number = -1):void {
			entity = null;
			if (points == null || points.length <= 0) {
				this.points = null;
				is_moving = false;
				return;
			}
			this.points = points;
			pointIdx = 0;
			move(points[0].x, points[0].y, speed, accel);
			is_moving = true;
			
			//trace("Camera.followPoints: ", points[0].x, points[0].y, to.x, to.y);
			
		}
		
		public function scaleTo(value:Number, speed:Number = -1):void {
			scale_to = value;
			if (speed > 0) scale_speed = speed;
		}
		
		public function screenToCamera(x:Number, y:Number, v:Vec2 = null):Vec2 {
			if (v == null) {
				v = new Vec2(x * zoom, y * zoom);
			} else {
				v.setXY(x * zoom, y * zoom);
			}
			//var v:Vec2 = new Vec2(x * zoom, y * zoom);
			v.x -= pos.x + width_half * zoom;
			v.y -= pos.y + height_half * zoom;
			//v.x += width_half;
			//v.y += height_half;
			return v;
		}
		public function cameraToScreen(x:Number, y:Number, v:Vec2 = null):Vec2 {
			if (v == null) {
				v = new Vec2(x * zoom, y * zoom);
			} else {
				v.setXY(x * zoom, y * zoom);
			}
			//var v:Vec2 = new Vec2(x * zoom, y * zoom);
			v.x += pos.x + width_half * zoom;
			v.y += pos.y + height_half * zoom;
			return v;
		}
	}
}