package elmortem.game {
	import alternativa.engine3d.core.Object3DContainer;
	import elmortem.game.entities.EntityManager3D;
	import elmortem.game.senses.ISense;
	import flash.events.Event;
	
	public class Simulation3D {
		public var entityManager:EntityManager3D;
		public var eventer:Eventer;
		private var senses:Vector.<ISense>;
		public var container:Object3DContainer = null;
		private var isPause:Boolean = false;
		
		public function Simulation3D() {
			entityManager = new EntityManager3D(this);
			eventer = new Eventer();
			senses = new Vector.<ISense>();
		}
		public function free():void {
			entityManager.free();
			entityManager = null;
			
			for (var i:int = 0; i < senses.length; i++) {
				senses[i].free();
			}
			senses = null;
			container = null;
			
			eventer.free();
			eventer = null;
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
			for (var i:int = 0; i < senses.length; i++) {
				if (senses[i].senseName == name) return senses[i];
			}
			return null;
		}
		
		// PAUSE
		public function get pause():Boolean {
			return isPause;
		}
		public function set pause(val:Boolean):void {
			isPause = val;
		}
		
		public function update(delta:Number):void {
			if (!isPause) {
				for (var i:int = 0; i < senses.length; i++) {
					senses[i].update(delta);
				}
				entityManager.update(delta);
				entityManager.render();
			}
			eventer.step();
		}
	}
}