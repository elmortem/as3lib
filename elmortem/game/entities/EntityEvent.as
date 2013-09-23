package elmortem.game.entities {
	import flash.events.Event;

	public class EntityEvent extends Event {
		public static const ADD:String = "entity.add";
		public static const REMOVE:String = "entity.remove";
		public static const DEAD:String = "entity.dead";
		
		public var entity:Entity;
		
		public function EntityEvent(entityIn:Entity, type:String) {
			entity = entityIn;
			super(type);
		}
	}
}