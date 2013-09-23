package elmortem.game.senses.physic {
	import elmortem.types.Vec2;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public class GravityEvent extends Event {
		static public const CHANGE:String = "gravity.change";
		public var gravity:Vec2;
		
		public function GravityEvent(gravity:Vec2, type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this.gravity = gravity.clone();
		} 
		
		public override function clone():Event {
			return new GravityEvent(gravity, type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("GravityEvent", "gravity", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}