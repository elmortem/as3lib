package karma.physic.simple2d {
	import elmortem.types.Vec2;
	import flash.geom.Point;
	import karma.game.senses.ISense;
	
	/**
	 * ...
	 * @author Karma Team
	 */
	public class Physic implements ISense {
		private var _list:Vector.<IBody>;
		private var _applyImpule:Boolean;
		
		public function Physic() {
			_list = new Vector.<IBody>();
			_applyImpule = true;
		}
		public function free():void {
			_list.length = 0;
			_list = null;
		}
		
		public function add(b:IBody):void {
			var idx:int = _list.indexOf(b);
			if (idx >= 0) _list.splice(idx, 1);
			
			if(b.isStatic) {
				_list.push(b);
			} else {
				_list.unshift(b);
			}
		}
		public function remove(b:IBody):void {
			var idx:int = _list.indexOf(b);
			if (idx >= 0) _list.splice(idx, 1);
		}
		
		public function get applyImpulse():Boolean {
			return _applyImpule;
		}
		public function set applyImpulse(v:Boolean):void {
			_applyImpule = v;
		}
		
		public function update(delta:Number):void {
			var i:int;
			var j:int;
			var len:int = _list.length;
			for (i = 0; i < len; i++) {
				var b1:IBody = _list[i];
				if (!b1.enabled) continue;
				if (b1.isStatic) continue;
				b1.update(delta);
				for (j = i + 1; j < len; j++) {
					var b2:IBody = _list[j];
					if (!b2.enabled) continue;
					if (b1.isStatic && b2.isStatic) {
						continue;
					}
					if (b1.group >= 0 && b1.group == b2.group) {
						continue;
					}
					
					var t1:int = b1.type;
					var t2:int = b2.type;
					
					if (t1 == Body.CIRCLE && t2 == Body.CIRCLE) {
						collideCircleToCircle(b1, b2);
					} else if (t1 == Body.CIRCLE && t2 == Body.POINT) {
						collidePointToCircle(b2, b1);
					} else if (t1 == Body.POINT && t2 == Body.CIRCLE) {
						collidePointToCircle(b1, b2);
					}
				}
			}
		}
		
		public function rayTrace(start:Vec2, end:Vec2, filter:Array = null, p:Vec2 = null, radius_mod:Number = 1):IBody {
			var i:int;
			var len:int = _list.length;
			var p1:Vec2 = start.clone();
			var p2:Vec2 = end.clone();
			for (i = 0; i < len; i++) {
				var b:IBody = _list[i];
				if (!b.enabled) continue;
				//if (b.isStatic) continue;
				if (b.type != Body.CIRCLE) continue;
				if (filter != null && filter.indexOf(b.group) >= 0) continue;
				
				//var res:Boolean = Vec2.lineCircleIntersect(p1, p2, b.pos.clone(), b.radius * radius_mod, p);
				var res:Boolean = Vec2.circleBySegment(p1.x, p1.y, p2.x, p2.y, b.pos.x, b.pos.y, b.radius * radius_mod);
				if (res) {
					return b;
				}
			}
			return null;
		}
		
		private function collideCircleToCircle(b1:IBody, b2:IBody):void {
			var a:Number;
			var d:Number;
			var im:Vec2 = new Vec2();
			var dist_pow:Number = b1.pos.distancePowTo(b2.pos);
			if (dist_pow < (b1.radius + b2.radius) * (b1.radius + b2.radius)) {
				if (!b1.collide(b2) || !b2.collide(b1)) return;
				if (b1.isSensor || b2.isSensor) return;
				
				var dist:Number = Math.sqrt(dist_pow);
				if (b1.isStatic) {
					a = b1.pos.angleToRad(b2.pos);
					d = (b1.radius + b2.radius) - dist;
					b2.pos.moveRad(d, a + Math.random() * Math.PI * 0.1);
					if (_applyImpule) {
						//b2.velosity.setXY(0, 0); // ???
						im.setXY(0, 0);
						im.moveRad(b2.velosity.length() * b2.damping, a);
						b2.applyImpulse(im);
					}
				} else if (b2.isStatic) {
					a = b2.pos.angleToRad(b1.pos);
					d = (b1.radius + b2.radius) - dist;
					b1.pos.moveRad(d, a + Math.random() * Math.PI * 0.1);
					if (_applyImpule) {
						//b1.velosity.setXY(0, 0); // ???
						im.setXY(0, 0);
						im.moveRad(b1.velosity.length() * b1.damping, a);
						b1.applyImpulse(im);
					}
				} else {
					a = b2.pos.angleToRad(b1.pos);
					d = ((b1.radius + b2.radius) - dist) * 0.5;
					b1.pos.moveRad(d, a + Math.random() * Math.PI * 0.1);
					b2.pos.moveRad(d, a + Math.PI + Math.random() * Math.PI * 0.1);
					
					if (_applyImpule) {
						//b1.velosity.setXY(0, 0); // ???
						im.setXY(0, 0);
						im.moveRad(b2.velosity.length() * b2.mass * b1.damping, a);
						b1.applyImpulse(im);
						
						//b2.velosity.setXY(0, 0); // ???
						im.setXY(0, 0);
						im.moveRad(b1.velosity.length() * b1.mass * b2.damping, a + Math.PI);
						b2.applyImpulse(im);
					}
				}
			}
		}
		
		private function collidePointToCircle(b1:IBody, b2:IBody):void {
			var p1:Vec2 = new Vec2();
			var res:Boolean = Vec2.lineCircleIntersect(b1.lastPos.clone(), b1.pos.clone(), b2.pos.clone(), b2.radius, p1);
			if (res) {
				if (!b1.collide(b2) || !b2.collide(b1)) {
					return;
				}
				
				if (!b2.isStatic) {
					var a:Number = p1.angleToRad(b2.pos);
					var im:Vec2 = new Vec2();
					im.moveRad(b1.velosity.length() * b2.damping, a);
					b2.applyImpulse(im);
				}
			}
		}
		
		public function getBodiesFromCoord(v:Vec2, filter:Array = null, radius_mod:Number = 1):Array {
			var i:int;
			var len:int = _list.length;
			var res:Array = null;
			for (i = len-1; i >= 0; i--) {
				var b:IBody = _list[i];
				if (filter != null && filter.indexOf(b.group) >= 0) continue;
				
				if (b.type == Body.CIRCLE) {
					var dist_pow:Number = b.pos.distancePowTo(v);
					if (dist_pow < b.radius * b.radius * radius_mod * radius_mod) {
						//return b;
						if (res == null) res = [];
						res.push(b);
					}
				}
			}
			
			return res;
		}
		
		public function get name():String {
			return "physic";
		}
		
		public function getValue(name:String):Object {
			return null;
		}
		
		public function setValue(name:String, value:Object):void {
		}
		
	}

}