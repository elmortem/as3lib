package karma.physic.box2d {
	import karma.game.Entity;
	import karma.game.GameManager;
	
	public class PhysicActor extends Entity {
		protected var physic:Physic;
		
		public function PhysicActor() {
		}
		override public function init(game:GameManager):void {
			super.init(game);
			physic = game.getSense("physic") as Physic;
		}
		override public function free():void {
			physic = null;
			super.free();
		}
	}
}