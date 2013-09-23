package elmortem.game.senses.physic {
	import com.greensock.TweenLite;
	import elmortem.game.senses.ISense;
	import elmortem.types.Vec2;
	import elmortem.utils.AngleUtils;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public class GravityManager extends EventDispatcher implements ISense {
		private var normal:Vec2;
		private var normalAngle:Number;
		private var force:Vec2;
		private var force_power:Number = -1;
		private var force_delta:Number = 0;
		private var list:/*IGravity*/Array;
		
		public function GravityManager(x:Number, y:Number) {
			normal = new Vec2(0, 1);
			normalAngle = normal.angle();
			force = new Vec2();
			setGravity(x, y);
			list = [];
		}
		
		public function get senseName():String {
			return "gravityManager";
		}
		
		public function free():void {
			force = null;
			list = null;
		}
		
		public function add(a:IGravity):void {
			list.push(a);
		}
		public function remove(a:IGravity):void {
			var i:int = list.indexOf(a);
			if (i >= 0) list.splice(i, 1);
		}
		public function clear():void {
			list = [];
		}
		
		public function update(delta:Number):void {
			var g:Vec2 = new Vec2(force.x, force.y);
			g.mult(delta);
			for (var i:int = 0; i < list.length; i++) {
				list[i].applyGravity(g);
			}
		}
		
		public function set gravity(v:Vec2):void {
			setGravity(v.x, v.y);
		}
		public function get gravity():Vec2 {
			return force;
		}
		public function setGravity(x:Number, y:Number):void {
			force.setXY(x, y);
			
			force_power = force.length();
			
			var a:Number = AngleUtils.normal(force.angle());
			force_delta = AngleUtils.delta(normalAngle, a);
			
			dispatchEvent(new GravityEvent(force, GravityEvent.CHANGE));
		}
		public function get power():Number {
			return force_power;
		}
		public function set power(val:Number):void {
			force.normalize();
			force.mult(val);
			force_power = val;
			
			dispatchEvent(new GravityEvent(force, GravityEvent.CHANGE));
		}
		public function get angleDelta():Number {
			return force_delta;
		}
		
		public function getVec(v:Vec2):Vec2 {
			var u:Vec2 = v.clone();
			if(force_delta != 0) u.rotate(-force_delta);
			return u;
		}
		public function setVecX(v:Vec2, x:Number):void {
			if(force_delta != 0) v.rotate(-force_delta);
			v.x = x;
			if(force_delta != 0) v.rotate(force_delta);
		}
		public function setVecY(v:Vec2, y:Number):void {
			if(force_delta != 0) v.rotate(-force_delta);
			v.y = y;
			if(force_delta != 0) v.rotate(force_delta);
		}
	}
}