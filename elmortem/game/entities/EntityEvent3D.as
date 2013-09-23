package elmortem.game.entities {
	import flash.events.Event;

	public class EntityEvent3D extends Event {
		public static const ADD:String = "entity3d.add";
		public static const REMOVE:String = "entity3d.remove";
		public static const DEAD:String = "entity3d.dead";
		
		public var entity:Entity3D;
		
		public function EntityEvent3D(entityIn:Entity3D, type:String) {
			entity = entityIn;
			super(type);
		}
	}
}