package karma.events {
	import karma.game.Entity;
	import starling.events.Event;
	
	public class EntityEvent extends Event {
		public static const ADD:String = "entity.add";
		public static const REMOVE:String = "entity.remove";
		public static const DEAD:String = "entity.dead";
		
		public var entity:Entity;
		
		public function EntityEvent(type:String, entity:Entity, bubbles:Boolean = false):void {
			super(type, bubbles);
			this.entity = entity;
		}
	}
}