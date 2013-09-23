package elmortem.game {
	import elmortem.game.cameras.ICamera;
	import elmortem.game.entities.EntityManager;
	import elmortem.game.senses.ISense;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Simulation extends EventDispatcher {
		public var entityManager:EntityManager;
		private var senses:Vector.<ISense>;
		private var camera:ICamera;
		private var is_pause:Boolean;
		private var is_dead:Boolean;
		
		public function Simulation() {
			entityManager = new EntityManager(this);
			senses = new Vector.<ISense>();
			camera = null;
			is_pause = false;
			is_dead = false;
		}
		public function free():void {
			if (camera != null) {
				camera.free();
				camera = null;
			}
			
			entityManager.free();
			entityManager = null;
			
			for (var i:int = senses.length-1; i >= 0; i--) {
				senses[i].free();
			}
			senses.length = 0;
			senses = null;
			
			is_dead = true;
		}
		
		// SENSE
		public function addSense(s:ISense):ISense {
			senses.push(s);
			return s;
		}
		public function removeSense(s:ISense):Boolean {
			if (s == null) return false;
			var i:int = senses.indexOf(s);
			if (i >= 0) {
				senses.splice(i, 1);
				return true;
			}
			return false;
		}
		public function removeSenseByName(name:String):Boolean {
			return removeSense(getSense(name));
		}
		public function getSense(name:String):ISense {
			var len:int = senses.length;
			for (var i:int = 0; i < len; i++) {
				if (senses[i].senseName == name) return senses[i];
			}
			return null;
		}
		
		// CAMERA
		public function setCamera(c:ICamera):void {
			camera = c;
		}
		public function getCamera():ICamera {
			return camera;
		}
		
		// PAUSE
		public function get pause():Boolean {
			return is_pause;
		}
		public function set pause(value:Boolean):void {
			entityManager.pause(value);
			is_pause = value;
		}
		
		public function update(delta:Number):void {
			if (!is_pause) {
				var len:int = senses.length;
				for (var i:int = 0; i < len; i++) {
					senses[i].update(delta);
				}
				entityManager.update(delta);
				if (camera != null) camera.update(delta);
				entityManager.render();
			}
		}
		
		public function get isDead():Boolean {
			return is_dead;
		}
	}
}