package elmortem.game.senses.physic {
	import elmortem.game.entities.Entity;
	import elmortem.game.senses.physic.Physic;
	import elmortem.game.Simulation;
	import elmortem.types.Vec2;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class PhysicActor extends Entity {
		protected var physic:Physic;
		
		public function PhysicActor() {
		}
		override public function init(sim:Simulation):void {
			super.init(sim);
			physic = sim.getSense("physic") as Physic;
		}
		override public function free():void {
			physic = null;
			super.free();
		}
		
		override public function update(delta:Number):void {
			super.update(delta);
		}
	}
}