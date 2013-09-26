package karma.events {
	import starling.events.Event;
	
	public class KarmaEvent extends Event {
		static public const CREATED:String = "karma.create";
		
		public function KarmaEvent(type:String, bubbles:Boolean = false):void {
			super(type, bubbles);
		}
	}
}