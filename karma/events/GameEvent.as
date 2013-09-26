package karma.events {
	import starling.events.Event;
	
	public class GameEvent extends Event {
		
		public function GameEvent(type:String, data:Object = null, bubbles:Boolean = false):void {
			super(type, bubbles, data);
		}
	}
}